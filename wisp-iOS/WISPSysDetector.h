//
//  WISPSysDetector.h
//  wisp-iOS
//
//  Created by Guoqing Geng on 9/29/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#ifndef WISPSysDetector_h
#define WISPSysDetector_h

#import <Foundation/Foundation.h>

@interface WISPSysDetector : NSObject {
}
- (NSString *)getSystemName;
-(NSString *)getUUIDAsString;
@end

#endif /* WISPSysDetector_h */
