//
//  Tool.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/3.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "Tool.h"

@implementation Tool

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ){
    float min, max, delta;
    min = MIN( r, MIN(g, b) );
    max = MAX( r, MAX(g, b) );
    *v = max;                // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;      // s
    else {
        // r = g = b = 0       // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;        // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}



+(CIImage *)hz_inputGreenBgImg:(UIImage *)greenImage backgroundImage:(UIImage *)bgImage{
#pragma mark 删除绿背，取图
    /**   returns underlying CIImage or nil if CGImageRef based  可能为nil
          CIImage *myImage = [CIImage imageWithCGImage:baby.CGImage];
     **/
    CIImage *myImage = [[CIImage alloc] initWithImage:greenImage];
    
    // Allocate memory
    const unsigned int size = 64;
    float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
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
    
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:@(size) forKey:@"inputCubeDimension"];
    [colorCube setValue:myImage forKey:@"inputImage"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    myImage = colorCube.outputImage;
    
    
#pragma mark 组合
    
//    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *backgroundCIImage = [[CIImage alloc] initWithImage:bgImage];// [CIImage imageWithCGImage:bgImage.CGImage];
    
    CIImage *resulImage = [[CIFilter filterWithName:@"CISourceOverCompositing" 
                                      keysAndValues:kCIInputImageKey,myImage,kCIInputBackgroundImageKey,backgroundCIImage,nil] 
                           valueForKey:kCIOutputImageKey];
//    CGRect extent = [resulImage extent];
//    CGImageRef cgImage = [context createCGImage:resulImage fromRect:extent];
    
    
    return resulImage;

}
@end
