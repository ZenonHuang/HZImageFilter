//
//  HZChromaKeyFilter.h
//  HZImageFilter
//
//  Created by zz go on 2017/5/16.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HZChromaKeyFilter : CIFilter

-(instancetype)initWithInputImage:(UIImage *)image
                  backgroundImage:(UIImage *)bgImage;

@property (nonatomic,readwrite,strong) UIImage *inputFilterImage;
@property (nonatomic,readwrite,strong) UIImage *backgroundImage;
@end
