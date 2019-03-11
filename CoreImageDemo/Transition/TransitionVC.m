//
//  TransitionVC.m
//  CoreImageDemo
//
//  Created by Daniel Mini on 2019/1/4.
//  Copyright © 2019 Daniel Mini. All rights reserved.
//

#import "TransitionVC.h"
#import "CICopyView.h"

@interface TransitionVC ()

@end

@implementation TransitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CICopyView * view = [[CICopyView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    [self.view addSubview:view];
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
