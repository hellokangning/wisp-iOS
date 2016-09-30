//
//  ViewController.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/28/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import "ViewController.h"
#import "WISPSysDetector.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    WISPSysDetector *detector = [[WISPSysDetector alloc] init];
    [detector getUUIDAsString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
