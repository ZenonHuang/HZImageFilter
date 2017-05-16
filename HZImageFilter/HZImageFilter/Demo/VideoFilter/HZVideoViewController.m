//
//  HZglkViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/2.
//  Copyright © 2017年 zzgo. All rights reserved.
//


#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "Tool.h"
#import "HZVideoViewController.h"


#define ScreenWidth [self.view bounds].size.width
#define ScreenHeight [self.view bounds].size.height

@interface HZVideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate> 
@property (strong, nonatomic)  AVCaptureSession *session;
@property (nonatomic,readwrite,strong) AVCaptureDeviceInput *input;
@property (nonatomic,readwrite,strong) AVCaptureVideoDataOutput *dataOutput;

@property (strong, nonatomic)  CIContext *ciContext;
@property (strong, nonatomic)  EAGLContext *glContext;
@property (nonatomic,readwrite,strong) GLKView *glkView;
@property (nonatomic,readwrite,strong) CIImage *bgImage;
@end

@implementation HZVideoViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    //    self.view.backgroundColor=[UIColor whiteColor];
    
    
    
    
    
    
    //    [self.view addSubview:self.glkView];
    self.view=self.glkView;
    
    
    [self.session addInput:self.input];
    
    //对实时视频帧进行相关的渲染操作,指定代理
    [self.dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.dataOutput];
    
    [self.session commitConfiguration];
    
    NSArray *array = [[self.session.outputs objectAtIndex:0] connections];
    for (AVCaptureConnection *connection in array){
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    [self.session startRunning];
    
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    
    /**  取图片渲染 **/
    // UIImage *image = imageFromSampleBuffer(sampleBuffer);
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    

    
    /**
 
     CGRect rect = [image extent];
         rect.origin.y = 200;
         rect.size.width  = ScreenWidth; //640;
         rect.size.height  = ScreenHeight; //(640.0/480.0)*640;
     CIFilter *filter =[CIFilter filterWithName:@"CISepiaTone"];
     [filter setValue:image forKey:kCIInputImageKey];
     [filter setValue:@0.8 forKey:kCIInputIntensityKey];
     image = filter.outputImage;
     **/
    
    
    
    /** 消色 **/
    CIImage *myImage = image;
    // Allocate memory
    const unsigned int size = 64;
    float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
    float rgb[3], hsv[3], *c =cubeData;
    
    // Populate cube with a simple gradient going from 0 to 1
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size-1); // Red value
                // Convert RGB to HSV
                // You can find publicly available rgbToHSV functions on the Internet
                RGBtoHSV(rgb[0],rgb[1],rgb[2], &hsv[0],&hsv[1],&hsv[2]);
                
                //颜色判断 
                float alpha = (hsv[0] >=85 && hsv[0] <= 155) ? 0.0f:1.0f;
                //饱和度
                if (hsv[1]<0.2) {
                    alpha=1.0f;
                }
                //亮度
                if (hsv[2]<0.2) {
                    alpha=1.0f;
                }
                //blue        float alpha = (hsv[0] > 210 && hsv[0] < 270) ? 0.0f:1.0f;
                // Calculate premultiplied alpha values for the cube
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                c += 4;
            }
        }
    }
    
    // Create memory with the cube data
    NSData *data = [NSData dataWithBytesNoCopy:cubeData
                                        length:size * size * size * sizeof (float) * 4
                                  freeWhenDone:YES];
    
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:@(size) forKey:@"inputCubeDimension"];
    [colorCube setValue:myImage forKey:@"inputImage"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    myImage = colorCube.outputImage;
    
    /** 组合 **/
    CIImage *resulImage = [[CIFilter filterWithName:@"CISourceOverCompositing" 
                                      keysAndValues:kCIInputImageKey,myImage,kCIInputBackgroundImageKey,self.bgImage,nil] 
                           valueForKey:kCIOutputImageKey];
    
    
    if( !(self.glContext == [EAGLContext currentContext])) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    [self.ciContext drawImage:resulImage
                       inRect:CGRectMake(0, 0, ScreenWidth*2, ScreenHeight*2) 
                     fromRect:CGRectMake(0, 0, ScreenWidth*2, ScreenHeight*2) ];
    
    
    
    //    glView.bindDrawable()
    //    ciContext.drawImage(image, inRect:image.extent(), fromRect: image.extent())
    //    glView.display()
    
    // 实时渲染
    //    [self.pixellateFilter setValue:@(sender.value) forKey:@"inputRadius"];
    //    [self.glkView.context presentRenderbuffer:GL_RENDERBUFFER];
    
}

#pragma mark - private

#pragma mark - getter
-(EAGLContext *)glContext{
    if (!_glContext) {
        //        contextWithEAGLContext创建的 context 支持实时渲染，渲染图像的过程始终在 GPU 上进行，并且永远不会复制回 CPU 存储器上
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//es 1 2 3区别？
    }
    return _glContext;
}

-(GLKView *)glkView{
    if (!_glkView) {
        //opengl es 单位是像素
        _glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*2, ScreenHeight*2)
                                          context:self.glContext];
        //    drawableColorFormat  
        //    你的OpenGL上下文有一个缓冲区，它用以存储将在屏幕中显示的颜色。你可以使用其属性来设置缓冲区中每个像素的颜色格式。  
        //    缺省值是GLKViewDrawableColorFormatRGBA8888，即缓冲区的每个像素的最小组成部分(-个像素有四个元素组成 RGBA)使用8个bit(如R使用8个bit)（所以每个像素4个字节 既 4*8 个bit）。这非常好，因为它给了你提供了最广泛的颜色范围，让你的app看起来更好。  
        //    但是如果你的app允许更小范围的颜色，你可以设置为GLKViewDrawableColorFormatRGB565，从而使你的app消耗更少的资源（内存和处理时间）。  
        _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
        
        //    drawableDepthFormat  
        //    你的OpenGL上下文还可以（可选地）有另一个缓冲区，称为深度缓冲区。这帮助我们确保更接近观察者的对象显示在远一些的对象的前面（意思就是离观察者近一些的对象会挡住在它后面的对象）。  
        //    其缺省的工作方式是：OpenGL把接近观察者的对象的所有像素存储到深度缓冲区，当开始绘制一个像素时，它（OpenGL）首先检查深度缓冲区，看是否已经绘制了更接近观察者的什么东西，如果是则忽略它（要绘制的像素，就是说，在绘制一个像素之前，看看前面有没有挡着它的东西，如果有那就不用绘制了）。否则，把它增加到深度缓冲区和颜色缓冲区。  
        //    你可以设置这个属性，以选择深度缓冲区的格式。缺省值是GLKViewDrawableDepthFormatNone，意味着完全没有深度缓冲区。  
        //    但是如果你要使用这个属性（一般用于3D游戏），你应该选择GLKViewDrawableDepthFormat16或GLKViewDrawableDepthFormat24。这里的差别是使用GLKViewDrawableDepthFormat16将消耗更少的资源，但是当对象非常接近彼此时，你可能存在渲染问题（）。  
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24; 
    }
    return _glkView;
}

-(CIContext *)ciContext{
    if (!_ciContext) {
        //CPU渲染
        //[CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
        
        // 创建基于GPU的CIContext对象
        _ciContext = [CIContext contextWithEAGLContext:self.glContext];
    }
    return _ciContext;
}

-(AVCaptureSession *)session{
    if (!_session) {
        
        _session = [[AVCaptureSession alloc] init];
        [_session beginConfiguration];
        //尺寸  todo :自适应尺寸,否则强制宏判断机型
        //AVCaptureSessionPresetiFrame1280x720  AVCaptureSessionPreset1280x720
        [_session setSessionPreset: AVCaptureSessionPreset1920x1080];
    }
    return _session;
}

-(AVCaptureDeviceInput *)input{
    if (!_input) {
        //input
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    }
    return _input;
}


-(AVCaptureVideoDataOutput *)dataOutput{
    if (!_dataOutput) {
        //output
        _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_dataOutput setAlwaysDiscardsLateVideoFrames:YES]; 
        [_dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]//kCVPixelFormatType_32BGRA] 
                                                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; 
    }
    return _dataOutput;
}

-(CIImage *)bgImage{
    if (!_bgImage) {
        _bgImage = [CIImage imageWithCGImage:[UIImage imageNamed:@"test"].CGImage];
    }
    return _bgImage;
}
@end
