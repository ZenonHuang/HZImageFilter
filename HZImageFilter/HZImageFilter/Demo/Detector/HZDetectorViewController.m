//
//  HZDetectorViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/4.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "HZDetectorViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIImageView+Gif.h"

@interface HZDetectorViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *oldImageView;

@end

@implementation HZDetectorViewController


- (IBAction)tapSubmitButton:(id)sender {
    for (UIView *view in self.oldImageView.subviews) {
        [view removeFromSuperview];
    }
    
    // 图像识别能力：可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh 
                                                     forKey:CIDetectorAccuracy];

    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    
//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
//                                              context:nil
//                                              options:nil];
    
    CIImage *image=[[CIImage alloc] initWithImage:self.oldImageView.image];
    NSArray *faceArray = [detector featuresInImage:image
                                           options:nil];

    /** 将 Core Image 坐标转换成 UIView 坐标 **/ 
    //得到图片的尺寸
    CGSize ciImageSize=   [image extent].size;;
    //将image沿y轴对称
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移,为负数
    transform = CGAffineTransformTranslate(transform,0,-ciImageSize.height);
    
    for (CIFeature *f in faceArray){
        
        if ([f.type isEqualToString:CIFeatureTypeFace]) {
            
            CIFaceFeature *faceFeature=(CIFaceFeature *)f;
            // 实现坐标转换
            CGSize viewSize = self.oldImageView.bounds.size;           
            CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                                viewSize.height / ciImageSize.height);
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
            
            UIView *faceView=[[UIView alloc] initWithFrame:faceViewBounds];
            faceView.layer.borderWidth=3;
            faceView.layer.borderColor=[UIColor orangeColor].CGColor;
            
            [self.oldImageView addSubview:faceView];
            
            /** 加光环  **/
            UIImageView *imageView=[UIImageView new];
            
            
            CGFloat haloWidth= faceViewBounds.size.width;
            CGFloat haloHeight= haloWidth * 159 / 351;
            
            CGFloat haloCenterX=faceViewBounds.origin.x+faceViewBounds.size.width/2;
            
            CGRect rect=CGRectMake(haloCenterX-haloWidth/2, faceViewBounds.origin.y-haloHeight, haloWidth, haloHeight);
            imageView.frame=rect;
            [self.oldImageView addSubview:imageView];
            
            
            NSMutableArray *list=[NSMutableArray new];
            for (int i=0; i<41; i++) {
                if (i<10) {
                    NSString *name=[NSString stringWithFormat:@"halo_00%d",i];
                    UIImage  *image=  [UIImage imageNamed:name];
                    [list addObject:image];
                }else{
                    NSString *name=[NSString stringWithFormat:@"halo_0%d",i];
                    UIImage  *image=  [UIImage imageNamed:name];
                    [list addObject:image];
                }
            }
            
            [imageView playGifAnim:[list copy]];
            
            // 判断是否有左眼位置
            if(faceFeature.hasLeftEyePosition){
            
                CGFloat x=faceFeature.leftEyePosition.x;
                CGFloat y=faceFeature.leftEyePosition.y;
                CGRect leftEyeRect=CGRectMake(x-10/2,y-10/2, 10, 10);
                
                //获取人脸的frame
                CGRect leftEyeBounds = CGRectApplyAffineTransform(leftEyeRect, transform);
                leftEyeBounds=CGRectApplyAffineTransform(leftEyeBounds,scaleTransform);
                leftEyeBounds.origin.x += offsetX;
                leftEyeBounds.origin.y += offsetY;
                
                UIView *leftEyeView = [[UIView alloc] initWithFrame:leftEyeBounds];
               leftEyeView .backgroundColor = [UIColor orangeColor];
                [self.oldImageView addSubview:leftEyeView ];
                
            }
            // 判断是否有右眼位置
            if(faceFeature.hasRightEyePosition){
                CGFloat x=faceFeature.rightEyePosition.x;
                CGFloat y=faceFeature.rightEyePosition.y;
                CGRect rightEyeRect=CGRectMake(x-10/2,y-10/2, 10, 10);
                
                //获取人脸的frame
                CGRect rightEyeBounds = CGRectApplyAffineTransform(rightEyeRect, transform);
                rightEyeBounds=CGRectApplyAffineTransform(rightEyeBounds,scaleTransform);
                rightEyeBounds.origin.x += offsetX;
                rightEyeBounds.origin.y += offsetY;
                
                UIView *rightEyeView = [[UIView alloc] initWithFrame:rightEyeBounds];
                rightEyeView.backgroundColor = [UIColor orangeColor];
                [self.oldImageView addSubview:rightEyeView];
            
            }
            // 判断是否有嘴位置
            if(faceFeature.hasMouthPosition){
            
            }

        }
        
    }
    
}

@end
