//
//  HZChromaKeyFilter.m
//  HZImageFilter
//
//  Created by zz go on 2017/5/16.
//  Copyright © 2017年 zzgo. All rights reserved.
//


#import "HZChromaKeyFilter.h"

@interface HZChromaKeyFilter ()
@end

@implementation HZChromaKeyFilter
-(instancetype)initWithInputImage:(UIImage *)image backgroundImage:(CIImage *)bgImage{
    self=[super init];
    
    if (!self) {
        return nil;
    }
    

    self.inputFilterImage=image;
    self.backgroundImage=bgImage;
    
    return self;
    
}
static int angle = 0;

-(CIImage *)outputImage{
    
    CIImage *myImage = [[CIImage alloc] initWithImage:self.inputFilterImage];
    //位移
    CIImage * tempImage = myImage;//[scaleFilter outputImage];
    CGSize extsz1 = self.backgroundImage.extent.size;
    CGSize extsz2 = tempImage.extent.size;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(extsz1.width-extsz2.width -100, extsz2.height+100);
    transform = CGAffineTransformRotate(transform, M_PI*2*(angle/360.0));
    angle ++;
    if (angle == 360) {
        angle = 0;
    }
    CIFilter * transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformFilter setValue:tempImage forKey:@"inputImage"];
    [transformFilter setValue:[NSValue valueWithCGAffineTransform:transform] forKey:@"inputTransform"];
    
    CIImage *backgroundCIImage = self.backgroundImage; //[[CIImage alloc] initWithImage:self.backgroundImage];
    CIImage *resulImage = [[CIFilter filterWithName:@"CISourceOverCompositing"  keysAndValues:kCIInputImageKey,transformFilter.outputImage,
                            kCIInputBackgroundImageKey,backgroundCIImage,nil]
                           valueForKey:kCIOutputImageKey];

    return resulImage;
}

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

@end
