//
//  ChromaKey.h
//  HZImageFilter
//
//  Created by zz go on 2017/5/2.
//  Copyright © 2017年 zzgo. All rights reserved.
//

//#if TARGET_OS_IPHONE
#import <CoreImage/CoreImage.h>
//#else
//#import <QuartzCore/QuartzCore.h>
//#endif

@interface ChromaKey : CIFilter
{
    CIImage *inputImage;
    CIImage *inputBackgroundImage;
    NSNumber *inputCubeDimension;
    NSNumber *inputCenterAngle;
    NSNumber *inputAngleWidth;
}
@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) CIImage *inputBackgroundImage;
@property (copy, nonatomic) NSNumber *inputCubeDimension;
@property (copy, nonatomic) NSNumber *inputCenterAngle;
@property (copy, nonatomic) NSNumber *inputAngleWidth;
@end
