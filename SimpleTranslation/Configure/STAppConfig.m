//
//  STAppConfig.m
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/12.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import "STAppConfig.h"
#import <Carbon/Carbon.h>
#import <ServiceManagement/ServiceManagement.h>

@interface STAppConfig ()

@end

@implementation STAppConfig

+ (void)systemConfig {
    
    [STAppConfig touchEvent];
    [STAppConfig costomHotKey];
    //[STAppConfig setLaunchAgents];
    //[STAppConfig settingAutoStart];
}

#pragma mark - 点击其他位置隐藏视图
+ (void)touchEvent {
    
    //__weak typeof (self)weakSelf = self;
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown handler:^(NSEvent * _Nonnull event) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HiddenSettingNotification object:nil userInfo:nil];
    }];
}

#pragma mark - 快捷键设置
+ (void)costomHotKey {
    
    // 声明相关参数
    EventHotKeyRef translationHotKeyRef;
    EventHotKeyID translationHotKeyID;
    
    EventHotKeyRef copyHotKeyRef;
    EventHotKeyID copyHotKeyID;
    
    EventTypeSpec myEvenType;
    myEvenType.eventClass = kEventClassKeyboard;    // 键盘类型
    myEvenType.eventKind = kEventHotKeyPressed;     // 按压事件
    
    // 定义快捷键
    translationHotKeyID.signature = 'Tran';  // 自定义签名
    translationHotKeyID.id = 4;              // 快捷键ID
    copyHotKeyID.signature = 'Copy';  // 自定义签名
    copyHotKeyID.id = 5;              // 快捷键ID
    
#pragma mark 注册快捷键
    // 注册快捷键
    // 参数一：keyCode; 如18代表1，19代表2，21代表4，49代表空格键，36代表回车键 详见keyCodes
    // 快捷键：command+T
    RegisterEventHotKey(0x11, cmdKey, translationHotKeyID, GetApplicationEventTarget(), 0, &translationHotKeyRef);
    
    // 快捷键：command+option+C
    RegisterEventHotKey(0x08, cmdKey + optionKey, copyHotKeyID, GetApplicationEventTarget(), 0, &copyHotKeyRef);
    
    // 注册回调函数，响应快捷键
    InstallApplicationEventHandler(&hotKeyHandler, 1, &myEvenType, NULL, NULL);
}

// 自定义C类型的回调函数
OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    
    EventHotKeyID hotKeyRef;
    
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
    
    unsigned int hotKeyId = hotKeyRef.id;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HotKeyEventNotification object:nil userInfo:@{HotKeyID: @(hotKeyId)}];
    
    switch (hotKeyId) {
        case 4:
            NSLog(@"%d", hotKeyId);
            break;
        case 5:
            NSLog(@"%d", hotKeyId);
            break;
        default:
            break;
    }
    return noErr;
}

#pragma mark - 设置开机自启动
+ (void)setLaunchAgents {
    
    CFStringRef appId = (__bridge_retained CFStringRef)@"com.dusmit.LauncherApplication";
    SMLoginItemSetEnabled(appId, true);
    __block BOOL startedAtLogin = NO;
//    [[[NSWorkspace sharedWorkspace]runningApplications] enumerateObjectsUsingBlock:^(NSRunningApplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.bundleIdentifier isEqualToString:CFBridgingRelease(appId)]) {
//            startedAtLogin = YES;
//            *stop = YES;
//        }
//    }];
    
    if (startedAtLogin) {
        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:@"killme" object:[[NSBundle mainBundle]bundleIdentifier]];
    }
}

+ (void)settingAutoStart {
    
    // 激活AutoLaunchHelper
    CFStringRef aCFString = (__bridge_retained CFStringRef)@"com.dusmit.LauncherApplication";
    SMLoginItemSetEnabled(aCFString, true);
    CFRelease(aCFString);
}




@end
