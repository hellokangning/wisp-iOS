//
//  ViewController.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/28/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import "ViewController.h"
#import "WISPURLProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [WISPURLProtocol enableWithAppID:@"57f89e2e61f0c4745ffe6baf"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSURL *url = [NSURL URLWithString:@"http://kwl.cdn.clouddn.com/5242881"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask * task= [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // NSLog(@"%@", data);
        // NSLog(@"%@", response);
        NSLog(@"%@", error);
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
