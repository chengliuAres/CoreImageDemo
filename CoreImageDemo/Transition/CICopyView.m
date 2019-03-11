//
//  CICopyView.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/4.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "CICopyView.h"
@interface CICopyView()
{
    CGFloat width;
    CGFloat height;
    NSTimeInterval base;
    CIFilter * transition;
    CIContext * context;
}
@property (nonatomic, strong) CIImage * sourceImage;
@property (nonatomic, strong) CIImage * targetImage;
@property (nonatomic, strong) NSTimer * timer;



@end
@implementation CICopyView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        width = frame.size.width;
        height = frame.size.height;
        _sourceImage = [CIImage imageWithCGImage:[UIImage imageNamed:@"tu.jpg"].CGImage];
        _targetImage = [CIImage imageWithCGImage:[UIImage imageNamed:@"tu2.jpeg"].CGImage];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        base = [NSDate timeIntervalSinceReferenceDate];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    }
    return self;
}
-(void)timerFired:(id)sender{
    CGRect rect =  self.bounds;
    CGFloat t = 0.4* ([NSDate timeIntervalSinceReferenceDate] - base);
    if (context == nil) {
        context = [CIContext contextWithOptions:nil];
    }
    if (transition == nil) {
        [self setupTransition];
    }
    CIImage * image = [self imageForTransition:t+0.1];
    CGImageRef cgimage = [context createCGImage:image fromRect:rect];
    self.layer.contents = (__bridge id)cgimage;
    CGImageRelease(cgimage);
}

-(CIImage *)imageForTransition:(CGFloat)t{
    if (fmodf(t, 2.0) < 1.0f) {
        [transition setValue: _sourceImage  forKey: kCIInputImageKey];
        [transition setValue: _targetImage  forKey: kCIInputTargetImageKey];
    } else {
        [transition setValue: _targetImage  forKey: kCIInputImageKey];
        [transition setValue: _sourceImage  forKey: kCIInputTargetImageKey];
    }
    [transition setValue:@(0.5 *(1-cos(fmodf(t, 1.0f)*M_PI))) forKey:kCIInputTimeKey];
    CIFilter * crop = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey,[transition outputImage],
                       @"inputRectangle",[CIVector vectorWithX:0 Y:0 Z:width W:height], nil];
    return [crop outputImage];
}

-(void)setupTransition{
    CIVector * extent = [CIVector vectorWithX:0 Y:0 Z:width W:height];
    transition = [CIFilter filterWithName:@"CICopyMachineTransition"];
    [transition setDefaults];
    [transition setValue:extent forKey:kCIInputExtentKey];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
