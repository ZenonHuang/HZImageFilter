//
//  HZCoreImageViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/4/30.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "HZCoreImageViewController.h"

#define ScreenWidth [self.view bounds].size.width
#define ScreenHeight [self.view bounds].size.height

@interface HZCoreImageViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic,readwrite,strong) NSMutableArray *dataList;
@property (nonatomic,readwrite,strong) UIPickerView *pickerView;
@property (nonatomic,readwrite,strong) UIImageView *imageView;
@property (nonatomic,readwrite,strong) UIImage *originImage;

@property (nonatomic,readwrite,strong) UIButton         *rightButton;
@property (nonatomic,readwrite,strong) UIBarButtonItem *rightBarButtonItem;
@end

@implementation HZCoreImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem=self.rightBarButtonItem;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.pickerView];
}

#pragma mark 滤镜处理事件


#pragma mark - action
-(void)onRightNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event{
    if(self.rightButton.selected){
        
        //picker关闭
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.pickerView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, CGRectGetHeight(self.pickerView.bounds));
        [UIView commitAnimations];
        
    }else{
        //picker显示
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.pickerView.frame = CGRectMake(0, ScreenHeight - CGRectGetHeight(self.pickerView.bounds), ScreenWidth, CGRectGetHeight(self.pickerView.bounds));
        [UIView commitAnimations];
        
    }
    
    self.rightButton.selected=(!self.rightButton.selected);

}

- (void)fliterEvent:(NSString *)filterName
{
    if ([filterName isEqualToString:@"OriginImage"]) {
        self.imageView.image = self.originImage;
        
    }else{
        //将UIImage转换成CIImage
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.originImage];
        //创建滤镜
        CIFilter *filter = [CIFilter filterWithName:filterName 
                                      keysAndValues:kCIInputImageKey,ciImage, nil];
        //已有的值不改变，其他的设为默认值
        [filter setDefaults];
        
        //获取绘制上下文
        CIContext *context = [CIContext contextWithOptions:nil];
        
        //渲染并输出CIImage
        CIImage *outputImage = [filter outputImage];
        
        //创建CGImage句柄
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        //获取图片
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        //释放CGImage句柄
        CGImageRelease(cgImage);
        
        self.imageView.image = image;
    }
    
}

#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataList count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.dataList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self fliterEvent:[self.dataList objectAtIndex:row]];
}

#pragma mark - getter
-(UIImage *)originImage{
    if (!_originImage) {
        _originImage = [UIImage imageNamed:@"test"];
    }
    return _originImage;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView=[[UIImageView alloc] initWithImage:self.originImage];
        
        _imageView.frame = self.view.frame;
        _imageView.center = self.view.center;
    }
    return _imageView;
}

-(UIPickerView *)pickerView{
    
    if (!_pickerView) {
        int pickerHeight = 200;//pickerView的高度
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, pickerHeight)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
    }
    return _pickerView;
}

-(NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList= 
        _dataList = [[NSMutableArray alloc] initWithObjects:
                     @"OriginImage",
                     @"CIPhotoEffectMono",
                     @"CIPhotoEffectChrome",
                     @"CIPhotoEffectFade",
                     @"CIPhotoEffectInstant",
                     @"CIPhotoEffectNoir",
                     @"CIPhotoEffectProcess",
                     @"CIPhotoEffectTonal",
                     @"CIPhotoEffectTransfer",
                     @"CISRGBToneCurveToLinear",
                     @"CIVignetteEffect",
                     nil];
    }
    return _dataList;
}

-(UIBarButtonItem *)rightBarButtonItem{
    if(!_rightBarButtonItem){
        _rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    }
    return _rightBarButtonItem;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        
        _rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setTitleColor:[UIColor blackColor]
                           forState:UIControlStateNormal];
        [_rightButton setTitle:@"Filter" 
                      forState:UIControlStateNormal];
        
        [_rightButton setTitle:@"hide" 
                          forState:UIControlStateSelected];
        
        [_rightButton sizeToFit];
        [_rightButton addTarget:self 
                         action:@selector(onRightNavButtonTapped:event:)
               forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightButton;
}
@end

