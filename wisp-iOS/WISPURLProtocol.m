//
//  WISPURLProtol.m
//  wisp-iOS
//
//  Created by Guoqing Geng on 10/8/16.
//  Copyright © 2016 qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  NEHTTPEye.m
//  NetworkEye
//
//  Created by coderyi on 15/11/3.
//  Copyright © 2015年 coderyi. All rights reserved.
//

#import "MSWeakTimer.h"
#import "WISPURLProtocol.h"

#import "WISPURLModel.h"
// #import "UIWindow+NEExtension.h"
#import "WISPURLSessionConfiguration.h"
#import "WISPURLModelMgr.h"

NSString *const WISPEnabled = @"WISPEnable";
NSString *const WISPSite = @"http://fusion-netdiag.qiniu.io";
NSInteger const WISPSuccStatusCode = 200;

static int sWISPVersion = 0;
static int sWISPFreq = 0;
static NSMutableArray *sWISPPermitDomains;
static NSMutableArray *sWISPForbidDomains;
static MSWeakTimer *sWISPTimer;

@interface WISPURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic,strong) WISPURLModel *URLModel;
@end

@implementation WISPURLProtocol
@synthesize URLModel;

#pragma mark - public
+ (void)enableWithAppID:(NSString *)appID {
    [[NSUserDefaults standardUserDefaults] setDouble:YES forKey:WISPEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    WISPURLSessionConfiguration * sessionConfiguration=[WISPURLSessionConfiguration defaultConfiguration];
    
    [NSURLProtocol registerClass:[WISPURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
    
    // request for config
    [self requestForConfig:appID];
}

+ (void)disable {
    [[NSUserDefaults standardUserDefaults] setDouble:NO forKey:WISPEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    WISPURLSessionConfiguration * sessionConfiguration=[WISPURLSessionConfiguration defaultConfiguration];
    
    [NSURLProtocol unregisterClass:[WISPURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
    
    sWISPPermitDomains = nil;
    sWISPForbidDomains = nil;
    [sWISPTimer invalidate];
    sWISPTimer = nil;
}

+ (BOOL)isEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:WISPEnabled] boolValue];
}
#pragma mark - superclass methods
+ (void)load {
    
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:@"WISPURLProtocol" inRequest:request] ) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:@"WISPURLProtocol"
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    
    URLModel=[[WISPURLModel alloc] init];
    URLModel.request=self.request;
    URLModel.startDateString=[self stringWithDate:[NSDate date]];
    
    NSTimeInterval myID=[[NSDate date] timeIntervalSince1970];
    double randomNum=((double)(arc4random() % 100))/10000;
    URLModel.myID=myID+randomNum;
}

- (void)stopLoading {
    [self.connection cancel];
    URLModel.response=(NSHTTPURLResponse *)self.response;
    URLModel.endDateString=[self stringWithDate:[NSDate date]];
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        URLModel.receiveJSONData = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is json request
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                URLModel.receiveJSONData = [self responseJSONFromData:jsonData];
            }
        }
        
    }
    else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            URLModel.receiveJSONData = xmlString;//example http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx/qqCheckOnline?qqCode=2121
        }
    }
    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:@"flowCount"] doubleValue];
    if (!flowCount) {
        flowCount=0.0;
    }
    flowCount=flowCount+self.response.expectedContentLength/(1024.0*1024.0);
    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:@"flowCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];//https://github.com/coderyi/NetworkEye/pull/6
    [[WISPURLModelMgr defaultManager] addModel:URLModel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        // TODO:
    }
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - Utils
+ (void)requestForConfig:(NSString *)appID {
    sWISPForbidDomains = [NSMutableArray arrayWithCapacity:1];
    sWISPPermitDomains = [NSMutableArray arrayWithCapacity:1];
    
    NSString *site = [WISPSite mutableCopy];
    NSString *urlString = [site stringByAppendingFormat:@"/webapi/fusion/app?id=%@", appID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *mutableReqeust = [NSMutableURLRequest requestWithURL:url];
    [NSURLProtocol setProperty:@YES
                        forKey:@"WISPURLProtocol"
                     inRequest:mutableReqeust];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask * task = [session dataTaskWithRequest:mutableReqeust
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            return;
        }
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if (responseStatusCode == WISPSuccStatusCode) {
            NSDictionary *resDict = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingMutableContainers
                                  error:&error];
            if (error) {
                return;
            }
            NSDictionary *appDict = [resDict valueForKey:@"app"];
            sWISPVersion = [[appDict valueForKey:@"version"] intValue];
            sWISPFreq = [[appDict valueForKey:@"freq"] intValue];
            NSArray *domains = [appDict valueForKey:@"permitDomains"];
            for (id item in domains) {
                [sWISPPermitDomains addObject:[(NSDictionary*)item valueForKey:@"domain"]];
            }

            sWISPTimer = [MSWeakTimer scheduledTimerWithTimeInterval:sWISPFreq*60
                                                              target:self
                                                            selector:@selector(sendReport)
                                                            userInfo:nil
                                                             repeats:YES
                                                       dispatchQueue:dispatch_get_main_queue()];
        }
    }];
    [task resume];
}

+ (void)sendReport {
    NSLog(@"Fire");
}

- (id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[WISPURLProtocol defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];//zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    });
    return staticDateFormatter;
}

@end
