//
//  WISPSysDetector.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/29/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SAMKeychain.h"
#import <sys/utsname.h>
#import "WISPSysDetector.h"

@implementation WISPSysDetector
- (NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

- (NSString *)machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machine = [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    return machine;
}

- (NSString *)UUIDString {
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SAMKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SAMKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

@end