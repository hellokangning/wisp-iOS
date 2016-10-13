//
//  ViewController.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/28/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import "ViewController.h"
#import "WISPURLProtocol.h"
#import "AFURLSessionManager.h"

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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendLargeRequest:(id)sender {
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

- (IBAction)sendTinyRequest:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://qint.cdn.clouddn.com/512001"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
    //连接服务器
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if(connectionError || data == nil) {
            NSLog(@"%@", connectionError);
        }
    }];
}

- (IBAction)sendBadRequest:(id)sender {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
   // NSURL *URL = [NSURL URLWithString:@"http://wisp.qiniu.io/webapi/fusion/encodingLogs"];
    NSURL *URL = [NSURL URLWithString:@"https://oerugfbxb.qnssl.com/wp-content/themes/Earthshaker/images/menu/reports.png"];
   // NSURL *URL = [NSURL URLWithString:@"http://www.notexistsite.com/download.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                              inDomain:NSUserDomainMask
                                                                     appropriateForURL:nil
                                                                                create:NO
                                                                                 error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    [downloadTask resume];
}

@end
