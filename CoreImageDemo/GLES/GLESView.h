//
//  GLESView.h
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/3.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@import GLKit;
@interface GLESView : UIView
@property (nonatomic,assign) BOOL recognizeFaced;

-(void)drawCIImage:(CIImage *)ciimage;

@end

NS_ASSUME_NONNULL_END
