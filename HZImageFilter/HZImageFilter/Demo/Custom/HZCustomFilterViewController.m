//
//  HZCustomFilterViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/2.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "HZCustomFilterViewController.h"
//#import <CoreImage/CoreImage.h>
//#import "Tool.h"
#import "HZChromaKeyFilter.h"
//#import <OpenGLES/EAGL.h>

@interface HZCustomFilterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *greenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;

@property (nonatomic,readwrite,strong) UIImagePickerController *imagePicker;
@property (nonatomic,readwrite,strong) UIView *selectedView;
@end


@implementation HZCustomFilterViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self hz_addView:self.greenImageView touchAction:@selector(tapImgView:)];
    [self hz_addView:self.resultBgImageView touchAction:@selector(tapImgView:)];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //UIImage *image=info[UIImagePickerControllerEditedImage];
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    if (self.selectedView==self.greenImageView) {
        self.greenImageView.image=image;
        return;
    }
    
    self.resultBgImageView.image=image;
    return;
}

#pragma mark - Action
-(void)tapImgView:(UITapGestureRecognizer *)gesture{
    if (gesture.view) {
        self.selectedView=gesture.view;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}


- (IBAction)tapResultButton:(id)sender {
    HZChromaKeyFilter *filter=[[HZChromaKeyFilter alloc] initWithInputImage:self.greenImageView.image  
                                                            backgroundImage:self.resultBgImageView.image];

    self.resultImageView.image=[[UIImage imageWithCIImage:filter.outputImage] copy];
}


#pragma mark - private
- (void)hz_addView:(UIView *)view touchAction:(SEL)action
{
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *g =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:g];
}

#pragma mark - getter
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[UIImagePickerController new];
        _imagePicker.allowsEditing = NO;
        _imagePicker.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.delegate=self;
    }
    return _imagePicker;
}
@end
