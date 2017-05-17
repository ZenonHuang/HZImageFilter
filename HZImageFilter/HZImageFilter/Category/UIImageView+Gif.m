//
//  UIImageView+Gif.m
//  QLiveStream
//
//  Created by quseit02 on 16/8/2.
//  Copyright © 2016年 quseit. All rights reserved.
//

#import "UIImageView+Gif.h"
@implementation UIImageView (Gif)
// 播放GIF
- (void)playGifAnim:(NSArray *)images
{
    if (!images.count) {
        return;
    }
    //动画图片数组
    self.animationImages = images;
    //执行一次完整动画所需的时长
    self.animationDuration = 1.0; // 0.5;
    //动画重复次数, 设置成0 就是无限循环
    self.animationRepeatCount = 0;
    [self startAnimating];
}
// 停止动画
- (void)stopGifAnim
{
    if (self.isAnimating) {
        [self stopAnimating];
    }
    [self removeFromSuperview];
}
@end
