//
//  WISPReport.h
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/9/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#ifndef WISPReport_h
#define WISPReport_h

@interface WISPReport : NSObject

@property (readwrite, copy) NSString *sysName;
@property (readwrite, copy) NSString *sysVersion;
@property (readwrite, copy) NSString *machineName;
@property (readwrite, copy) NSString *deviceID;
@property (readwrite, copy) NSString *netStatus;
@property (readwrite, copy) NSString *wispVersion;
@property (readwrite, copy) NSString *appID;
@property (readwrite, copy) NSString *url;
@property (readwrite, copy) NSString *host;
@property (readwrite, assign) UInt64 sendTime;
@property (readwrite, assign) UInt64 firstResTime;
@property (readwrite, assign) UInt64 dataLen;
@property (readwrite, assign) UInt64 dlTime;
@property (readwrite, copy) NSString *errorMsg;


@end

#endif /* WISPReport_h */
