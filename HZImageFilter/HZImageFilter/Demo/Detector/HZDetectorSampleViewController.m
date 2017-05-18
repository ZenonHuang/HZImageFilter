//
//  HZTestVideoViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/17.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "HZDetectorSampleViewController.h"
#import "HZDetectorVideoViewController.h"
#import "UIImageView+Gif.h"

@interface HZDetectorSampleViewController ()<DetectorVideoDelegate>
@property (nonatomic,readwrite,strong) HZDetectorVideoViewController *detectorVC;
@property (nonatomic,readwrite,strong) UIView *faceView;

@property (nonatomic,readwrite,strong) UIImageView *haloImgView;
@property (nonatomic,readwrite,strong) NSArray     *haloImgList;
@end

@interface HZDetectorSampleViewController ()
@property (nonatomic,readwrite,strong) UIButton         *rightButton;
@property (nonatomic,readwrite,strong) UIBarButtonItem  *rightBarButtonItem;
@end

@implementation HZDetectorSampleViewController

-(void)viewDidLoad{
    [super viewDidLoad ];
    
    self.navigationItem.rightBarButtonItem=self.rightBarButtonItem;
    
    [self addChildViewController:self.detectorVC];
    [self.view addSubview:self.detectorVC.view];
    self.detectorVC.view.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.haloImgView];
    [self.haloImgView playGifAnim:self.haloImgList];
}

#pragma mark - action
-(void)onRightNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event{
 
    [self.detectorVC chanageCamera];  
    self.rightButton.selected=(!self.rightButton.selected);
    
//    [self.detectorVC.view removeFromSuperview];
//    [self.view addSubview:self.detectorVC.view];
    [self.rightButton sizeToFit];
}

#pragma mark - delegate
-(void)detectorVideoLocateFace:(CGRect)faceBounds{
    if (CGRectEqualToRect(faceBounds, CGRectZero)   ) {
//         [self.haloImgView stopGifAnim];
        self.faceView.hidden=self.haloImgView.hidden=YES;
         
    }else{
            
          self.faceView.hidden=self.haloImgView.hidden=NO;
        
          self.faceView.frame=faceBounds;
        {
        CGFloat haloWidth= faceBounds.size.width;
        CGFloat haloHeight= haloWidth * 159 / 351;
        
        CGFloat haloCenterX=faceBounds.origin.x+faceBounds.size.width/2;
        
        CGRect rect=CGRectMake(haloCenterX-haloWidth/2, faceBounds.origin.y-haloHeight, haloWidth, haloHeight);
        self.haloImgView.frame=rect;
            
//            [self.haloImgView playGifAnim:self.haloImgList];
        }
    }
}

#pragma mark - getter
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
        [_rightButton setTitle:@"front" 
                      forState:UIControlStateNormal];
        
        [_rightButton setTitle:@"back" 
                          forState:UIControlStateSelected];
        
        [_rightButton sizeToFit];
        [_rightButton addTarget:self 
                         action:@selector(onRightNavButtonTapped:event:)
               forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightButton;
}

-(HZDetectorVideoViewController *)detectorVC{
    if (!_detectorVC) {
        _detectorVC=[HZDetectorVideoViewController new];
        _detectorVC.detectorDelegate=self;
    }
    return _detectorVC;
}

-(UIView *)faceView{
    if (!_faceView) {
        _faceView=[UIView new];
        _faceView.backgroundColor=[UIColor orangeColor];
    }
    return _faceView;
}

-(UIImageView *)haloImgView{
    if (!_haloImgView) {
        _haloImgView=[UIImageView new];
    }
    return _haloImgView;
}

-(NSArray *)haloImgList{
    if (!_haloImgList) {
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
        
        _haloImgList= [list copy];
    }
    return _haloImgList;
}

@end
