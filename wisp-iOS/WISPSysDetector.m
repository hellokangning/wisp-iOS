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
#import "WISPSysDetector.h"

@implementation WISPSysDetector
- (NSString *)getSystemName {
    NSString *systemName = [[UIDevice currentDevice] systemName];
    return systemName;
}

-(NSString *)getUUIDAsString
{
    
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