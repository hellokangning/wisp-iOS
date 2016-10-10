//
//  WISPURLModel.h
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/8/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#ifndef WISPURLModel_h
#define WISPURLModel_h

@interface WISPURLModel : NSObject

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, assign) double myID;
@property (nonatomic, assign) UInt64 startTimestamp;
@property (nonatomic, assign) UInt64 endTimestamp;
@property (nonatomic, strong) NSString *errMsg;

//request
@property (nonatomic, strong) NSString *requestURLString;
@property (nonatomic, strong) NSString *requestDomain;
@property (nonatomic, assign) double requestTimeoutInterval;
@property (nonatomic, nullable, strong) NSString *requestHTTPMethod;


//response
@property (nonatomic, assign) int responseStatusCode;
@property (nonatomic, assign) SInt64 responseTimeStamp;
@property (nonatomic, assign) NSInteger responseDataLength;

@end

#endif /* WISPURLModel_h */
