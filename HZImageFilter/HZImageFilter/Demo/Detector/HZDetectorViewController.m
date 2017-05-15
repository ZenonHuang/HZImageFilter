//
//  HZDetectorViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/4.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "HZDetectorViewController.h"
#import <CoreImage/CoreImage.h>

@interface HZDetectorViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *oldImageView;

@end

@implementation HZDetectorViewController


- (IBAction)tapSubmitButton:(id)sender {
    
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:nil];
    
    CIImage *image=[[CIImage alloc] initWithImage:self.oldImageView.image];
    NSArray *faceArray = [detector featuresInImage:image
                                           options:nil];
    // Create a green circle to cover the rects that are returned.
//    CIImage *maskImage = nil;
       CIImage *maskImage = [[CIImage alloc] initWithImage:self.oldImageView.image];
    
    for (CIFeature *f in faceArray) {
        CGFloat centerX = f.bounds.origin.x + f.bounds.size.width / 2.0;
        CGFloat centerY = f.bounds.origin.y + f.bounds.size.height / 2.0;
        CGFloat radius = MIN(f.bounds.size.width, f.bounds.size.height) / 1.5;
        CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" 
                                        withInputParameters:@{
                                                              @"inputRadius0": @(radius),
                                                              @"inputRadius1": @(radius + 1.0f),
                                                              @"inputColor0": [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3],
                                                              @"inputColor1": [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                                              kCIInputCenterKey: [CIVector vectorWithX:centerX Y:centerY],
                                                              }];
        CIImage *circleImage = [radialGradient valueForKey:kCIOutputImageKey];
        
        if (nil == maskImage){
            maskImage = circleImage;
        }else{
            maskImage = [[CIFilter filterWithName:@"CISourceOverCompositing" 
                              withInputParameters:@{
                                                    kCIInputImageKey: circleImage,
                                                    kCIInputBackgroundImageKey: maskImage,
                                                    }] 
                         valueForKey:kCIOutputImageKey];
        }
    }

    
    
    //更新
    self.oldImageView.image=[UIImage imageWithCIImage:maskImage];
}

@end
