//
//  HZDetectorVideoViewController.h
//  HZImageFilter
//
//  Created by zz go on 2017/5/17.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

//协议
@protocol DetectorVideoDelegate<NSObject>
//协议的方法
-(void)detectorVideoLocateFace:(CGRect)faceBounds;

-(void)detectorVideoLocateLeftEyeForFace:(CGRect)leftEyeBounds;

-(void)detectorVideoLocateRightEyeForFace:(CGRect)rightEyeBounds;
@end

@interface HZDetectorVideoViewController :  GLKViewController    
@property(nonatomic,weak) id<DetectorVideoDelegate> detectorDelegate;
-(void)chanageCamera;
@end

