//
//  RecognitionVC.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/4.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "RecognitionVC.h"

@interface RecognitionVC ()
@property (nonatomic, strong) UIView * leftEye;
@property (nonatomic, strong) UIView * rightEye;
@property (nonatomic, strong) UIView * mouth;
@property (nonatomic, strong) UIView * face;
@property (nonatomic, strong) UIImageView * imgView;

@property (nonatomic, strong) UIView * resultView;



@end

@implementation RecognitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage * image = [UIImage imageNamed:@"timg.jpeg"];
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _imgView.center = self.view.center;
    [self.view addSubview:_imgView];
    _imgView.image = image;
    
    _resultView = [[UIView alloc] initWithFrame:_imgView.frame];
    [self.view addSubview:_resultView];
    
    CIContext * context = [CIContext contextWithOptions:nil];
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    //
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    NSArray * detectResult = [faceDetector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    for (CIFaceFeature * feature in detectResult) {
        self.face.frame = feature.bounds;
        if (feature.hasLeftEyePosition) {
            self.leftEye.center = feature.leftEyePosition;
        }
        if (feature.hasRightEyePosition) {
            self.rightEye.center = feature.rightEyePosition;
        }
        if (feature.hasMouthPosition) {
            self.mouth.center = feature.mouthPosition;
        }
        ///note: UI坐标系 和 CoreImage坐标系不一样：左下角为原点
        _resultView.transform = CGAffineTransformMakeScale(1, -1);
    }
    
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
        _face.layer.borderWidth = 1;
        [_resultView addSubview:_face];
    }
    return _face;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
