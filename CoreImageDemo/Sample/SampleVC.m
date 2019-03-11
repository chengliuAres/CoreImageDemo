//
//  SampleVC.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/3.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "SampleVC.h"
#import "CLColorInvertFilter.h"

@interface SampleVC ()
{
    UIImageView * _effectedImgV;
}
@property (nonatomic, strong) CIContext * context;


@end

@implementation SampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];

}

- (UIImage *)addEffect:(NSString *)filtername fromImage:(UIImage *)image{
    ///note 1
//        CIImage * image1 = [image CIImage];
//        NSLog(@"%@",image1);
    //因为： UIImage 对象可能不是基于 CIImage 创建的（由 imageWithCIImage: 生成的），这样就无法获取到 CIImage 对象
    //解决方法一：
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"tu.jpg" ofType:nil];
//    UIImage * tempImage = [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path]]];
//    CIImage * tempCIimg = [tempImage CIImage];
//    NSLog(@"%@",tempCIimg);
    
    //解决方法2
    CIImage * ciimage = [[CIImage alloc] initWithImage:image];
    CIFilter * filter = [CIFilter filterWithName:filtername];
    [filter setValue:ciimage forKey:kCIInputImageKey];
    // 已有的值不改变, 其他的设为默认值
    [filter setDefaults];
    //渲染并输出CIImage
    CIImage * outimage = [filter outputImage];
    
    //UIImage * newImage = [UIImage imageWithCIImage:outimage]; //每次创建都会开辟新的CIContext上下文，耗费空间

    // 获取绘制上下文
    CIContext * context = [CIContext contextWithOptions:nil];//（GPU上创建）
    //self.context; //
    //创建CGImage
    CGImageRef cgimage = [context createCGImage:outimage fromRect:[outimage extent]];
    UIImage * newImage = [UIImage imageWithCGImage:cgimage];
    CGImageRelease(cgimage);
    return newImage;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSArray * filters = @[@"CIPhotoEffectFade",
                          @"CIPhotoEffectInstant",
                          @"CIPhotoEffectMono",
                          @"CIPhotoEffectNoir",
                          @"CIPhotoEffectProcess",
                          @"CIPhotoEffectTonal",
                          @"CIPhotoEffectTransfer"];
    uint32_t index = arc4random_uniform(filters.count-1);
    UIImage * image = [UIImage imageNamed:@"tu.jpg"];
    
    //_effectedImgV.image = [self addEffect:filters[index] fromImage:image];
    
    
    ///滤镜链
    //CoreImage 支持滤镜链，会自动把多个滤镜组合成一个新的程序，通过减少中间缓冲区的数量，来提高性能和质量。
     //kCIOutputImageKey作为键所对应的值将返回输出图像：
     //CIImage *result = [_filter valueForKey: kCIOutputImageKey];
     /**
     CoreImage不会进行任何的图像处理直到你真正调用了会渲染这个图像的方法。当你请求输出图像时，CoreImage将会组装一些运算用来生成输出图像，并且会将这些运算（图像配方）存进一个CIImage对象。真正的图像渲染只会发生在一个图像绘制方法被显式地调用时。
     在渲染时刻到来时，若有多个滤镜，会自动在一次操作中连接多个“配方”，那就意味着每个像素只会被处理一次而不是多次。。
     */
    UIImage * image2 = [self addEffect:filters[0] fromImage:image];
    UIImage * image3 = [self addEffect:filters[1] fromImage:image2];
    UIImage * image4 = [self addEffect:filters[2] fromImage:image3];
    UIImage * image5 = [self addEffect:filters[3] fromImage:image4];
    //_effectedImgV.image =  image5;
    
    
    ///自动图像增强
    //_effectedImgV.image = [self autoAdjust:[CIImage imageWithCGImage:image.CGImage]];
    
    ///自定义滤镜 --颜色翻转
//    CIImage * ciImage = [CIImage imageWithCGImage:[image CGImage]];
//    CLColorInvertFilter * customeFilter = [[CLColorInvertFilter alloc] init];
//    customeFilter.inputImage = ciImage;
//    CIImage * outCIImg = [customeFilter outputImage];
//    CGImageRef newImage = [self.context createCGImage:outCIImg fromRect:[outCIImg extent]];
//    _effectedImgV.image = [UIImage imageWithCGImage:newImage];
}

- (CIContext *)context{
    if (!_context) {
        //每次都会重新创建一个 CIContext 代价是非常高的。
        //并且，CIContext 和 CIImage 对象是不可变的，在线程之间共享这些对象是安全的。
        //所以多个线程可以使用同一个 GPU 或者 CPU CIContext 对象来渲染 CIImage 对象。
        _context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]]; //CPU上创建上下文
    }
    return _context;
}

///自动图像增强
-(UIImage *)autoAdjust:(CIImage *)image{
    id orientationProperty = [[image properties] valueForKey:(__bridge id)kCGImagePropertyOrientation];
    NSDictionary *options = nil;
    if (orientationProperty) {
        options = @{CIDetectorImageOrientation : orientationProperty};
        //用于设置识别方向，值是一个从1 ~ 8的整型的NSNumber。如果值存在，检测将会基于这个方向进行，但返回的特征仍然是基于这些图像的。
    }
    NSArray *adjustments = [image autoAdjustmentFiltersWithOptions:options];
    for (CIFilter *filter in adjustments) {
        [filter setValue:image forKey:kCIInputImageKey];
        image = filter.outputImage;
    }
    CIContext * context = [CIContext contextWithOptions:nil];//（GPU上创建） //self.context;
    //创建CGImage
    CGImageRef cgimage = [context createCGImage:image fromRect:[image extent]];
    UIImage * newImage = [UIImage imageWithCGImage:cgimage];
    return newImage;
}

- (void)createUI{
    CGFloat width = self.view.frame.size.width;
    CGRect rect = CGRectMake(0, 0, 200, 300);
    UIImageView * originalImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tu.jpg"]];
    originalImgV.contentMode = UIViewContentModeScaleAspectFit;
    originalImgV.frame = rect;
    originalImgV.center = CGPointMake(width/2, 250);
    [self.view addSubview:originalImgV];
    
    _effectedImgV = [[UIImageView alloc] initWithFrame:rect];
    _effectedImgV.center = CGPointMake(width/2, CGRectGetMaxY(originalImgV.frame)+100);
    _effectedImgV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_effectedImgV];
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
