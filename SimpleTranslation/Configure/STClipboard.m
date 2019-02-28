//
//  STClipboard.m
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/13.
//  Copyright © 2019 dusmit. All rights reserved.
//  监听剪切板参考：https://github.com/AlexChekel1337/NSPasteboardPolling
//

#import "STClipboard.h"

@interface STClipboard ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSPasteboard *pasteboard;
@property (nonatomic, strong) NSString *previousPasteboardString;

@end

@implementation STClipboard

+ (instancetype)sharedInstance {
    
    static STClipboard *clipboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        clipboard = [[STClipboard alloc]init];
    });
    return clipboard;
}

- (void)startWithDelegate:(id)delegate {
    
    [self stop];
    self.delegate = delegate;
    self.timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(checkPasteboard) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)checkPasteboard {
    
    if (!self.pasteboard) self.pasteboard = [NSPasteboard generalPasteboard];
    NSString *pasteboardString = [self.pasteboard stringForType:NSPasteboardTypeString];
    if (![pasteboardString isEqualToString:self.previousPasteboardString]) {
        [self.delegate pasteboardDidUpdate:pasteboardString];
    }
    self.previousPasteboardString = pasteboardString;
}


@end
