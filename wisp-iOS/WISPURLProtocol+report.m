//
//  WISPURLProtocol+report.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/9/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WISPSysDetector.h"
#import "WISPURLProtocol.h"
#import "WISPURLProtocol+report.h"
#import "WISPSysDetector.h"
#import "WISPURLModelMgr.h"
#import "WISPURLModel.h"
//#import "WISPReport.h"
#import "NSData+GZIP.h"

NSString *const WISPSite = @"https://wisp.qiniu.io";

@implementation WISPURLProtocol (report)

+ (void)sendReport {
    NSMutableArray *requests = [[WISPURLModelMgr defaultManager] allModels];
    if (requests == nil || [requests count] == 0) {
        return;
    }
    
    NSMutableArray *reports = [NSMutableArray arrayWithCapacity:[requests count]];
    
    WISPSysDetector *sysDetector = [WISPSysDetector defaultDetector];
    NSString *sysName = [sysDetector systemName];
    NSString *sysVersion = [sysDetector systemVersion];
    NSString *machineName = [sysDetector machineName];
    NSString *deviceID = [sysDetector UUIDString];
    NSString *netStatus = [sysDetector netStatus];
    
    NSString *wispVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *appID = [self appID];
    for (WISPURLModel *req in requests) {
        NSString *url = req.requestURLString;
        NSString *domain = req.requestDomain;
        UInt64 sendTime = req.startTimestamp;
        
        SInt64 firstResTime = (req.responseTimeStamp > sendTime) ? (req.responseTimeStamp - sendTime) : -1;
        SInt64 dataLen = req.responseDataLength;
        SInt64 dlTime = (req.endTimestamp > sendTime) ? (req.endTimestamp - sendTime) : -1;
        int statusCode = req.responseStatusCode;
        NSString *msg = req.errMsg;
        if (msg == nil) {
            msg = @"";
        }
       
        BOOL reachable = YES;
        if (statusCode != 200 || ![msg isEqualToString:@""])
            reachable = NO;
        
        NSDictionary *report = @{
                                 @"Os": sysName,
                                 @"SysVersion": sysVersion,
                                 @"DeviceProvider": machineName,
                                 @"DeviceID": deviceID,
                                 @"NetType": netStatus,
                                 @"Version": wispVersion,
                                 @"AppID": appID,
                                 @"Url": url,
                                 @"Domain": domain,
                                 @"Stime": [NSNumber numberWithLongLong:sendTime],
                                 @"FirstPacketTime": [NSNumber numberWithLongLong:firstResTime],
                                 @"Size": [NSNumber numberWithLongLong:dataLen],
                                 @"TotalTime": [NSNumber numberWithLongLong:dlTime],
                                 @"Code": [NSNumber numberWithInt:statusCode],
                                 @"Reachable": [NSNumber numberWithBool:reachable],
                                 @"Message": msg
                                 };
        [reports addObject:report];
    }
   
    NSDictionary *data = @{
                           @"data": reports
                           };
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&writeError];
    if (writeError != nil) {
        NSLog(@"Convent to JSON failed: %@", [writeError localizedDescription]);
        return;
    }
    
    NSData *gzippedData = [jsonData gzippedData];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)gzippedData.length];
    NSString *site = [WISPSite mutableCopy];
    NSString *urlString = [site stringByAppendingFormat:@"/webapi/fusion/encodingLogs"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [mutableRequest setValue:@"*/*" forHTTPHeaderField:@"accept"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:gzippedData];
    
    [NSURLProtocol setProperty:@YES
                        forKey:@"WISPURLProtocol"
                     inRequest:mutableRequest];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask * task = [session dataTaskWithRequest:mutableRequest
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error != nil) {
                                                 NSLog(@"send report failed: %@", error.localizedDescription);
                                             }
                                             else {
                                                NSLog(@"send report succ, data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                             }
                                         }];
    [task resume];
  
    [[WISPURLModelMgr defaultManager] removeAllModels];
}

@end
