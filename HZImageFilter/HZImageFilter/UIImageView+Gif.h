//
//  UIImageView+Gif.h
//  QLiveStream
//
//  Created by quseit02 on 16/8/2.
//  Copyright © 2016年 quseit. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImageView (Gif)
// 播放GIF
- (void)playGifAnim:(NSArray *)images;
// 停止动画
- (void)stopGifAnim;
@end
