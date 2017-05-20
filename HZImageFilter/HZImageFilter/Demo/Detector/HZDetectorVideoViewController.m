//
//  HZDetectorVideoViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/17.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "Tool.h"
#import "HZDetectorVideoViewController.h"
#import "UIImageView+Gif.h"
#import "UIImage+Extension.h"


#define kScreenWidth [self.view bounds].size.width
#define kScreenHeight [self.view bounds].size.height

@interface HZDetectorVideoViewController  ()<AVCaptureVideoDataOutputSampleBufferDelegate> 
@property (nonatomic,readwrite,strong)  AVCaptureSession *session;

@property (nonatomic,readwrite,assign) BOOL isDevicePositionFront; 
@property (nonatomic,readwrite,strong) AVCaptureDeviceInput *backCameraInput;
@property (nonatomic,readwrite,strong) AVCaptureDeviceInput *frontCameraInput;

@property (nonatomic,readwrite,strong) AVCaptureVideoDataOutput *dataOutput;

@property (nonatomic,readwrite,strong) CIContext *ciContext;
@property (nonatomic,readwrite,strong) EAGLContext *glContext;
@property (nonatomic,readwrite,strong) GLKView *glkView;


//@property (nonatomic,readwrite,strong) GLKBaseEffect *glEffect;
@property(nonatomic,assign) int mCount;
@end

@implementation HZDetectorVideoViewController 
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view=self.glkView;    
    
    [self.session beginConfiguration];
    [self.session addInput:self.backCameraInput];
    self.isDevicePositionFront=NO;
    
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
#pragma mark - public
-(void)chanageCamera{
    if (self.isDevicePositionFront) {
        [self changeCameraPositionWithCurrentIsFront:NO];
    }else{
        [self changeCameraPositionWithCurrentIsFront:YES];
    }
}
#pragma mark - private
//切换摄像头方向
- (void)changeCameraPositionWithCurrentIsFront:(BOOL)isFront {
    
    if (isFront) {
        [self.session stopRunning];
        [self.session removeInput:self.backCameraInput];
     
        self.isDevicePositionFront=YES;
        
        if ([self.session canAddInput:self.frontCameraInput]) {
            
            [self.session addInput:self.frontCameraInput];
            
            [self.session commitConfiguration];
            NSArray *array = [[self.session.outputs objectAtIndex:0] connections];
            for (AVCaptureConnection *connection in array){
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }

            [self.session startRunning];
        }
        
    } else {
        [self.session stopRunning];
        [self.session removeInput:self.frontCameraInput];
        self.isDevicePositionFront=NO;
        
        if ([self.session canAddInput:self.backCameraInput]) {
            [self.session addInput:self.backCameraInput];
            [self.session commitConfiguration];
            
            NSArray *array = [[self.session.outputs objectAtIndex:0] connections];
            for (AVCaptureConnection *connection in array){
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            }
            [self.session startRunning];
        }
    }
    
}

//获取可用的摄像头
- (AVCaptureDevice *)cameroWithPosition:(AVCaptureDevicePosition)position{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        AVCaptureDeviceDiscoverySession *dissession = 
        [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera,AVCaptureDeviceTypeBuiltInTelephotoCamera,AVCaptureDeviceTypeBuiltInWideAngleCamera] 
                                                               mediaType:AVMediaTypeVideo 
                                                                position:position];
        for (AVCaptureDevice *device in dissession.devices) {
            if ([device position] == position ) {
                return device;
            }
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if ([device position] == position) {
                return device;
            }
        }
    }
    return nil;
}

-(CIImage *)inputCIImageForDetector:(CIImage *)image{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow
                                                     forKey:CIDetectorAccuracy];
    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    NSArray *faceArray = [detector featuresInImage:image
                                           options:nil];
    
    if (!(faceArray.count==1)) {
        
        if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateFace:)]) {
            [self.detectorDelegate detectorVideoLocateFace:CGRectZero];
        }
        
        return image;
    }
    //得到图片的尺寸
    CGSize ciImageSize=[image extent].size;  
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    transform = CGAffineTransformTranslate(transform,0,-ciImageSize.height);
    for (CIFeature *f in faceArray){
            CIFaceFeature *faceFeature=(CIFaceFeature *)f;
            // 实现坐标转换
            CGSize viewSize =self.view.bounds.size;          
            CGFloat scale = MIN(viewSize.width / ciImageSize.width,viewSize.height / ciImageSize.height);
            
            CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
            CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
            // 缩放
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            //获取人脸的frame
            CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
            // 修正
            faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
            faceViewBounds.origin.x += offsetX;
            faceViewBounds.origin.y += offsetY;            
            
            //            NSLog(@"faceBounds: x %f, y%f",faceFeature.bounds.origin.x,faceFeature.bounds.origin.y);
            //            NSLog(@"glkView   : w %f, h%f",self.view.bounds.size.width,self.view.bounds.size.height);
            //            NSLog(@"imageSize : w %f, h%f",ciImageSize.width,ciImageSize.height);
            
            if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateFace:)]) {
                [self.detectorDelegate detectorVideoLocateFace:faceViewBounds];
            }
        
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){
            CGFloat x=faceFeature.rightEyePosition.x;
            CGFloat y=faceFeature.rightEyePosition.y;
            
            
            CGSize size=CGSizeMake(faceViewBounds.size.width/3, faceViewBounds.size.width/3);
            CGRect rightEyeRect=CGRectMake(x-size.width/2,y-size.height/2, size.width, size.height);
            
            //获取人脸的frame
            CGRect rightEyeBounds = CGRectApplyAffineTransform(rightEyeRect, transform);
            rightEyeBounds=CGRectApplyAffineTransform(rightEyeBounds,scaleTransform);
            rightEyeBounds.origin.x += offsetX;
            rightEyeBounds.origin.y += offsetY;
            
            if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateRightEyeForFace:)]) {
                [self.detectorDelegate detectorVideoLocateRightEyeForFace:rightEyeBounds];
            }
            
        }else{
            if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateRightEyeForFace:)]) {
                [self.detectorDelegate detectorVideoLocateRightEyeForFace:CGRectZero];
            }
        }

        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){
            
            CGFloat x=faceFeature.leftEyePosition.x;
            CGFloat y=faceFeature.leftEyePosition.y;
             CGSize size=CGSizeMake(faceViewBounds.size.width/3, faceViewBounds.size.width/3);
            CGRect leftEyeRect=CGRectMake(x-size.width/2,y-size.height/2, size.width, size.height);
            
            //获取人脸的frame
            CGRect leftEyeBounds = CGRectApplyAffineTransform(leftEyeRect, transform);
            leftEyeBounds=CGRectApplyAffineTransform(leftEyeBounds,scaleTransform);
            leftEyeBounds.origin.x += offsetX;
            leftEyeBounds.origin.y += offsetY;
            
            if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateLeftEyeForFace:)]) {
                [self.detectorDelegate detectorVideoLocateLeftEyeForFace:leftEyeBounds];
            }
            
        }else{
            if ([self.detectorDelegate respondsToSelector:@selector(detectorVideoLocateLeftEyeForFace:)]) {
                [self.detectorDelegate detectorVideoLocateLeftEyeForFace:CGRectZero];
            }
        }
            
    }
    
    return image;
}

-(void)drawImage:(CIImage *)image{
    [self.glkView bindDrawable];
    
    if( !(self.glContext == [EAGLContext currentContext])) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);  
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);  
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    [self.ciContext drawImage:image
                       inRect:CGRectMake(0, 0, kScreenWidth*2, kScreenHeight*2) 
                     fromRect:CGRectMake(0, 0, [image extent].size.width,[image extent].size.height) ];
    
    [self.glkView display];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    self.mCount++;
    if (self.mCount%5==0) {
        image=[self inputCIImageForDetector:image];
        self.mCount=0;
    }
    
    
    [self drawImage:image];
}

#pragma mark - private

#pragma mark - getter
-(EAGLContext *)glContext{
    if (!_glContext) {
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return _glContext;
}

-(GLKView *)glkView{
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*2, kScreenHeight*2)
                                          context:self.glContext];
        
        _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
        
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24; 
    }
    return _glkView;
}

-(CIContext *)ciContext{
    if (!_ciContext) {
        _ciContext = [CIContext contextWithEAGLContext:self.glContext];
    }
    return _ciContext;
}

-(AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset: AVCaptureSessionPresetHigh];
    }
    return _session;
}

//摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput  alloc] initWithDevice:[self cameroWithPosition:AVCaptureDevicePositionBack] error:&error];
        if (error) {
            NSLog(@"后置摄像头获取失败");
        }
    }
    self.isDevicePositionFront = NO;
    return _backCameraInput;
}

- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameroWithPosition:AVCaptureDevicePositionFront] 
                                                                   error:&error];
        if (error) {
            NSLog(@"前置摄像头获取失败");
        }
    }
    self.isDevicePositionFront = YES;
 
    return _frontCameraInput;
}

-(AVCaptureVideoDataOutput *)dataOutput{
    if (!_dataOutput) {
        //output
        _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        [_dataOutput setAlwaysDiscardsLateVideoFrames:YES]; 
        //conn.videoMaxFrameDuration = CMTimeMake(1,rate);
        
        [_dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; 
    }
    return _dataOutput;
}
@end


