//
//  STNetworkingManager.m
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/12.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import "STNetworkingManager.h"

#define kTimeoutInterval  15

@implementation STNetworkingManager

+ (instancetype)sharedInstance {
    
    static STNetworkingManager *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        network = [[STNetworkingManager alloc]initWithBaseURL:[NSURL URLWithString:@"http://api.fanyi.baidu.com/api/trans/"]];
    });
    return network;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    if (self = [super initWithBaseURL:url]) {
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer.timeoutInterval = 10.;
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"multipart/form-data", @"application/json", @"application/octet-stream", @"text/json", @"text/html", @"image/jpeg", @"image/png", nil];
    }
    return self;
}

@end
