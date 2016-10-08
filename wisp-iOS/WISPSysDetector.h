//
//  WISPSysDetector.h
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/29/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#ifndef WISPSysDetector_h
#define WISPSysDetector_h

@interface WISPSysDetector : NSObject

@property (readonly, copy) NSString *systemName;
@property (readonly, copy) NSString *machineName;
@property (readonly, copy) NSString *UUIDString;

@end

#endif /* WISPSysDetector_h */
