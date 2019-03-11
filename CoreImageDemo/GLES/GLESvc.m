//
//  GLESvc.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/3.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "GLESvc.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HZChromaKeyFilter.h"
#import "CLColorInvertFilter.h"

@interface GLESvc ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput * videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput * audioInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput * videoDataOutput;

@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) UISwitch * witchBtn;
@property (nonatomic, strong) HZChromaKeyFilter * customerFilter;


@end

@implementation GLESvc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}



-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciimage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if (_witchBtn.isOn) {
        [self.filter setValue:ciimage forKey:kCIInputImageKey];
        ciimage = [_filter outputImage];
//        CLColorInvertFilter * customeFilter = [[CLColorInvertFilter alloc] init];
//        customeFilter.inputImage = ciimage;
//        ciimage = [customeFilter outputImage];
        //自定义添加水印
        //_customerFilter = [[HZChromaKeyFilter alloc] initWithInputImage:[UIImage imageNamed:@"tu.jpg"] backgroundImage:ciimage];
        //ciimage = _customerFilter.outputImage;
    }
    [self.gpuView drawCIImage:ciimage];
    
}

-(GLESView *)gpuView{
    if (!_gpuView) {
        _gpuView = [[GLESView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _gpuView.recognizeFaced = YES;
        [self.view addSubview:self.gpuView];
        [self.view addSubview:self.witchBtn];
    }
    return _gpuView;
}

-(CIFilter *)filter{
    if (!_filter) {
        _filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    }
    return _filter;
}

-(void)setup{
    
    //设置视频输入
    [self setUpVideo];
    
    //设置音频
    [self setUpAudio];
    
    
    //处理视频帧
    [self setupVideoFrame];
    
    //[self setUpPreview];
    
    NSArray *array = [[self.session.outputs objectAtIndex:0] connections];
    for (AVCaptureConnection *connection in array){
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    [self.session startRunning];
}

-(void)setUpVideo{
    // 1.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    
    // 视频 HDR (高动态范围图像)
    // videoCaptureDevice.videoHDREnabled = YES;
    // 设置最大，最小帧速率
    //videoCaptureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 60);
    // 1.2 创建视频输入源
    NSError *error=nil;
    self.videoInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    // 1.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
}

- (void)setUpAudio
{
    // 2.1 获取音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    // 2.2 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    // 2.3 将音频输入源添加到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
}

-(void)setupVideoFrame{
    // 处理对外暴露的视频帧
    _videoDataOutput = [AVCaptureVideoDataOutput new];
    NSDictionary * newSetting =@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    //_videoDataOutput.minFrameDuration = CMTimeMake(1, 30); //fps 30
    AVCaptureConnection * videoDataConnect = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([videoDataConnect isVideoStabilizationSupported ]) {
        videoDataConnect.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
    }
    //预览图层和视频方向保持一致
    videoDataConnect.videoOrientation = AVCaptureVideoOrientationPortrait;//[self.previewLayer connection].videoOrientation;
    
    _videoDataOutput.videoSettings = newSetting;
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    if ([self.session canAddOutput:_videoDataOutput]) {
        [_session addOutput:_videoDataOutput];
    }
    //dispatch_queue_t queue = dispatch_queue_create("videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    //dispatch_queue_t serialQueue = dispatch_queue_create("sub_thread", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    [_videoDataOutput setSampleBufferDelegate:self queue:queue];
}

#pragma mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray * cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

- (AVCaptureSession *)session
{
    // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
    // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
    // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
    // 只有高分辨率的视频才是全屏的，如果想要自定义长宽比，就需要先录制高分辨率，再剪裁，如果录制低分辨率，剪裁的区域不好控制
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置分辨率
            _session.sessionPreset=AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UISwitch *)witchBtn{
    if (!_witchBtn) {
        _witchBtn = [[UISwitch alloc] init];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_witchBtn];
    }
    return _witchBtn;
}

@end
