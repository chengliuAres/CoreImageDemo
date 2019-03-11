//
//  CLColorInvertFilter.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/7.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "CLColorInvertFilter.h"

@implementation CLColorInvertFilter

- (void)setDefaults{
    [super setDefaults];
    //coding...
    
}

- (CIImage *)outputImage{
    CIFilter * filter = [CIFilter filterWithName:@"CIColorMatrix"
                                   keysAndValues:kCIInputImageKey,self.inputImage
                         ,@"inputRVector",[CIVector vectorWithX:-1 Y:0 Z:0],
                         @"inputGVector",[CIVector vectorWithX:0 Y:-1 Z:0],
                         @"inputBVector",[CIVector vectorWithX:0 Y:0 Z:-1],
                         @"inputBiasVector",[CIVector vectorWithX:1 Y:1 Z:1],
                         nil];
    return filter.outputImage;
}

@end
