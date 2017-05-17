//
//  HZChromaKeyFilter.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/16.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "Tool.h"
#import "HZChromaKeyFilter.h"

@interface HZChromaKeyFilter ()
@end

@implementation HZChromaKeyFilter
-(instancetype)initWithInputImage:(UIImage *)image
                  backgroundImage:(UIImage *)bgImage{
    self=[super init];
    
    if (!self) {
        return nil;
    }
    

    
    self.inputFilterImage=image;
    self.backgroundImage=bgImage;
    
    return self;
    
}

-(CIImage *)outputImage{
    
    CIFilter *colorCubeFilter=    [CIFilter filterWithName:@"CIColorCube"];
    
    // Allocate memory
    const unsigned int size = 64;
    float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
    [colorCubeFilter setValue:@(size) forKey:@"inputCubeDimension"];
    
    CIImage *myImage = [[CIImage alloc] initWithImage:self.inputFilterImage];
    [colorCubeFilter setValue:myImage forKey:@"inputImage"];
    
    float rgb[3], hsv[3], *c = cubeData;
    // Populate cube with a simple gradient going from 0 to 1
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size-1); // Red value
                // Convert RGB to HSV
                // You can find publicly available rgbToHSV functions on the Internet
                RGBtoHSV(rgb[0],rgb[1],rgb[2], &hsv[0],&hsv[1],&hsv[2]);
                //green  
                //                float alpha = (hsv[0] > 80 && hsv[0] < 160) ? 0.0f:1.0f;
                //颜色判断 
                float alpha = (hsv[0] >=85 && hsv[0] <= 155) ? 0.0f:1.0f;
                //饱和度
                if (hsv[1]<0.2) {
                    alpha=1.0f;
                }
                //亮度
                if (hsv[2]<0.2) {
                    alpha=1.0f;
                }
                //blue        float alpha = (hsv[0] > 210 && hsv[0] < 270) ? 0.0f:1.0f;
                
                // Calculate premultiplied alpha values for the cube
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                c += 4;
            }
        }
    }

    
    // Create memory with the cube data
    NSData *data = [NSData dataWithBytesNoCopy:cubeData
                                        length:size * size * size * sizeof (float) * 4
                                  freeWhenDone:YES];
    [colorCubeFilter setValue:data forKey:@"inputCubeData"];
  
    myImage = [colorCubeFilter outputImage];
    
    
#pragma mark 组合
    CIImage *backgroundCIImage = [[CIImage alloc] initWithImage:self.backgroundImage];
    CIImage *resulImage = [[CIFilter filterWithName:@"CISourceOverCompositing" 
                                      keysAndValues:kCIInputImageKey,myImage,kCIInputBackgroundImageKey,backgroundCIImage,nil] 
                           valueForKey:kCIOutputImageKey];

    return resulImage;
}

@end
