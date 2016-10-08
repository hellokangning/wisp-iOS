//
//  WISPURLModelMgr.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/8/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WISPURLModelMgr.h"
#import "WISPURLModel.h"

@interface WISPURLModelMgr() {
    NSMutableArray *allRequests;
}

@end

@implementation WISPURLModelMgr

- (id)init {
    self = [super init];
    if (self) {
        allRequests = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

+ (WISPURLModelMgr *)defaultManager {
    
    static WISPURLModelMgr *staticManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticManager=[[WISPURLModelMgr alloc] init];
    });
    return staticManager;
    
}

- (void)addModel:(WISPURLModel *)newModel {
    if ([newModel.responseMIMEType isEqualToString:@"text/html"]) {
        newModel.receiveJSONData=@"";
    }
    
    BOOL isNull = (newModel.receiveJSONData == nil);
    if (isNull) {
        newModel.receiveJSONData=@"";
    }
    
    [allRequests addObject:newModel];
}

- (void)removeAllModels {
    [allRequests removeAllObjects];
}

@end
