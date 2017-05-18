//
//  UIImage+Extension.h
//  HZImageFilter
//
//  Created by zz go on 2017/5/17.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (Extension)
-(UIImage*)convertViewToImage:(UIView*)v;
@end

@interface CIImage (Extension)
-(UIImage*)convertViewToImage:(UIView*)v;
@end
