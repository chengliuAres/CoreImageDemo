//
//  ViewController.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/2.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "ViewController.h"
#import "SampleVC.h"
#import "GLESvc.h"
#import "Transition/TransitionVC.h"
#import "Recognition/RecognitionVC.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableview;
@property (nonatomic, strong) NSArray * dataSource;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataSource = @[@"一个Filter的使用",
                    @"采用GPU方式实时绘制",
                    @"专场效果",
                    @"人脸识别"];
    [self tableview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"cell"];
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SampleVC * sampleVc = [SampleVC new];
        [self.navigationController pushViewController:sampleVc animated:YES];
    }else if (indexPath.row == 1){
        GLESvc * vc = [GLESvc new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2){
        TransitionVC * vc = [TransitionVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        RecognitionVC * vc = [RecognitionVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [UIView new];
        [self.view addSubview:_tableview];
    }
    return _tableview;
}

@end
