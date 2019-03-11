//
//  CLColorInvertFilter.h
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/7.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLColorInvertFilter : CIFilter
@property (nonatomic, strong) CIImage * inputImage;


@end

NS_ASSUME_NONNULL_END
