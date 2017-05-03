//
//  RSBToHSV.h
//  HZImageFilter
//
//  Created by zz go on 2017/5/3.
//  Copyright © 2017年 zzgo. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface Tool : NSObject
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );
@end
