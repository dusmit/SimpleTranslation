//
//  STNetworkingManager.h
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/12.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

#define NetWorkManager [STNetworkingManager sharedInstance]

@interface STNetworkingManager : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
