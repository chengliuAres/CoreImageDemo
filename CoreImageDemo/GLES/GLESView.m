//
//  GLESView.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/3.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "GLESView.h"
@interface GLESView()
@property (nonatomic, assign)  CGRect     rectInPixels;
@property (nonatomic, strong)  CIContext *context;
@property (nonatomic, strong)  GLKView   *showView;

@property (nonatomic, strong) UIView * leftEye;
@property (nonatomic, strong) UIView * rightEye;
@property (nonatomic, strong) UIView * mouth;
@property (nonatomic, strong) UIView * face;

@property (nonatomic, strong) UIView * resultView;
@end
@implementation GLESView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self) {
        self = [super initWithFrame:frame];
        //获取openGLES渲染环境
        EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        //初始化GLKview 并制定openGLES渲染环境 + 绑定
        _showView = [[GLKView alloc] initWithFrame:frame context:context];
        //A default implementation for views that draw their content using OpenGL ES.
        /*
         Binds the context and drawable. This needs to be called when the currently bound framebuffer
         has been changed during the draw method.
         */
        [_showView bindDrawable];
        
        //添加进图层
        [self addSubview:_showView];
        
        //创建上下文CIContext - GPU方式 ：但是必须在主线程
        _context = [CIContext contextWithEAGLContext:context options:@{kCIContextWorkingColorSpace:[NSNull null]}];
        //定义绘制区域
        //_rectInPixels = CGRectMake(0, 0, _showView.drawableWidth, _showView.drawableHeight);

    }
    return self;
}

-(void)setRecognizeFaced:(BOOL)recognizeFaced{
    _recognizeFaced = recognizeFaced;
    if (recognizeFaced) {
        self.resultView.hidden = NO;
    }else{
        self.resultView.hidden = YES;
    }
}

int i = 0;
float scaleValue = 1.0;
-(void)drawCIImage:(CIImage *)ciimage{
        CGSize imageSize = [ciimage extent].size;
        CGSize viewSize = self.bounds.size;
        CGFloat scale_w = imageSize.width/viewSize.width;
        CGFloat scale_h = imageSize.height/imageSize.height;
        CGFloat scale = scale_w < scale_h ? scale_w:scale_w;
        scaleValue = scale;
    
    [_context drawImage:ciimage inRect:CGRectMake(0, 0, viewSize.width*scale, viewSize.height*scale) fromRect:[ciimage extent]];
    //将CIImage转变为UIImage
    //    CGImageRef cgimg = [_context createCGImage:ciImage fromRect:[ciImage extent]];
    //    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    //    CGImageRelease(cgimg);
    [_showView display];
    if (_recognizeFaced) {
        if (i%5 == 0) {
            [self detector:ciimage];
        }
        i++;
    }
}

-(void)detector:(CIImage *)image{
    //CIContext * context = [CIContext contextWithOptions:nil];
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_context options:param];
    NSArray * detectResult = [faceDetector featuresInImage:image];
    printf("count: %lu \n",(unsigned long)detectResult.count);
    if (detectResult.count == 0) {
        self.resultView.hidden = YES;
        return;
    }
    self.resultView.hidden = NO;
    for (CIFaceFeature * feature in detectResult) {
        [UIView animateWithDuration:5/60.0f animations:^{
            self.face.frame = CGRectMake(feature.bounds.origin.x/scaleValue, feature.bounds.origin.y/scaleValue, feature.bounds.size.width/scaleValue, feature.bounds.size.height/scaleValue);
            if (feature.hasLeftEyePosition) {
                self.leftEye.center = CGPointMake(feature.leftEyePosition.x/scaleValue, feature.leftEyePosition.y/scaleValue);
            }
            if (feature.hasRightEyePosition) {
                self.rightEye.center = CGPointMake(feature.rightEyePosition.x/scaleValue, feature.rightEyePosition.y/scaleValue);
            }
            if (feature.hasMouthPosition) {
                self.mouth.center = CGPointMake(feature.mouthPosition.x/scaleValue, feature.mouthPosition.y/scaleValue);
            }
            ///note: UI坐标系 和 CoreImage坐标系不一样：左下角为原点
        }];
        //_resultView.transform = CGAffineTransformMakeScale(1, -1);
    }
}

-(UIView *)resultView{
    if (!_resultView) {
        _resultView = [[UIView alloc] initWithFrame:self.bounds];
        [_showView addSubview:_resultView];
    }
    return _resultView;
}

-(UIView *)leftEye{
    if (!_leftEye) {
        _leftEye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _leftEye.layer.borderColor = [UIColor redColor].CGColor;
        _leftEye.layer.borderWidth = 1;
        [_resultView addSubview:_leftEye];
    }
    return _leftEye;
}

-(UIView *)rightEye{
    if (!_rightEye) {
        _rightEye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _rightEye.layer.borderColor = [UIColor redColor].CGColor;
        _rightEye.layer.borderWidth = 1;
        [_resultView addSubview:_rightEye];
    }
    return _rightEye;
}

-(UIView *)mouth{
    if (!_mouth) {
        _mouth = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _mouth.layer.borderColor = [UIColor greenColor].CGColor;
        _mouth.layer.borderWidth = 1;
        [_resultView addSubview:_mouth];
    }
    return _mouth;
}

-(UIView *)face{
    if (!_face) {
        _face = [[UIView alloc] init];
        _face.layer.borderColor = [UIColor purpleColor].CGColor;
        _face.layer.borderWidth = 2;
        [_resultView addSubview:_face];
    }
    return _face;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
