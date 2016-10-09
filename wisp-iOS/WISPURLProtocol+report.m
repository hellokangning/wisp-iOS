//
//  WISPURLProtocol+report.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/9/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WISPSysDetector.h"
#import "WISPURLProtocol+report.h"
#import "WISPSysDetector.h"
#import "WISPURLModelMgr.h"
#import "WISPURLModel.h"
#import "WISPReport.h"

@implementation WISPURLProtocol (report)

+ (void)sendReport {
    WISPSysDetector *sysDetector = [WISPSysDetector defaultDetector];
    NSString *sysName = [sysDetector systemName];
    NSString *sysVersion = [sysDetector systemVersion];
    NSString *machineName = [sysDetector machineName];
    NSString *deviceID = [sysDetector UUIDString];
    NSString *netStatus = [sysDetector netStatus];
    
    NSString *wispVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *appID = [self appID];
    NSMutableArray *requests = [[WISPURLModelMgr defaultManager] allModels];
    NSMutableArray *logs = [NSMutableArray arrayWithCapacity:[requests count]];
    for (WISPURLModel *req in requests) {
        NSString *url = req.requestURLString;
        NSString *host = req.requestDomain;
        SInt64 sendTime = req.startTimestamp;
        SInt64 firstResTime = req.responseTimeStamp;
        SInt64 dataLen = req.responseDataLength;
        SInt64 dlTime = req.endTimestamp - req.startTimestamp;
        int statusCode = req.responseStatusCode;
        NSString *msg = req.errMsg;
        
        WISPReport *report = [[WISPReport alloc] init];
        [report setSysName:sysName];
        [report setSysVersion:sysVersion];
        [report setMachineName:machineName];
        [report setDeviceID:deviceID];
        [report setNetStatus:netStatus];
        [report setWispVersion:wispVersion];
        [report setAppID:appID];
        [report setUrl:url];
        [report setHost:host];
        [report setSendTime:sendTime];
        [report setFirstResTime:firstResTime];
        [report setDataLen:dataLen];
        [report setDlTime:dlTime];
        [report setErrorMsg:[NSString stringWithFormat:@"%d, %@", statusCode, msg]];
        
    }
    
    [[WISPURLModelMgr defaultManager] removeAllModels];
}

@end
