//
//  STClipboard.h
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/13.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STClipboardDelegate <NSObject>

@optional
- (void)pasteboardDidUpdate:(NSString *)string;

@end

@interface STClipboard : NSObject

@property (nonatomic, weak) id<STClipboardDelegate> delegate;

+ (instancetype)sharedInstance;
//- (void)start;
- (void)startWithDelegate:(id)delegate;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
