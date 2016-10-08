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

@property (nonatomic,strong) NSURLRequest *request;
@property (nonatomic,strong) NSHTTPURLResponse *response;
@property (nonatomic,assign) double myID;
@property (nonatomic,strong) NSString *startDateString;
@property (nonatomic,strong) NSString *endDateString;

//request
@property (nonatomic,strong) NSString *requestURLString;
@property (nonatomic,strong) NSString *requestCachePolicy;
@property (nonatomic,assign) double requestTimeoutInterval;
@property (nonatomic,nullable, strong) NSString *requestHTTPMethod;
@property (nonatomic,nullable,strong) NSString *requestAllHTTPHeaderFields;
@property (nonatomic,nullable,strong) NSString *requestHTTPBody;

//response
@property (nonatomic,nullable,strong) NSString *responseMIMEType;
@property (nonatomic,strong) NSString *responseExpectedContentLength;
@property (nonatomic,nullable,strong) NSString *responseTextEncodingName;
@property (nullable, nonatomic, strong) NSString *responseSuggestedFilename;
@property (nonatomic,assign) int responseStatusCode;
@property (nonatomic,nullable,strong) NSString *responseAllHeaderFields;

//JSONData
@property (nonatomic,strong) NSString *receiveJSONData;

@property (nonatomic,strong) NSString *mapPath;
@property (nonatomic,strong) NSString *mapJSONData;

@end

#endif /* WISPURLModel_h */
