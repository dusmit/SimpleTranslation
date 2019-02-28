//
//  AppDelegate.m
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/12.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import "AppDelegate.h"
#import "STAppConfig.h"
#import "STPopoverViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // 加载系统配置
    [STAppConfig systemConfig];
    // 添加通知
    [self addNotification];
    // 创建菜单栏item
    [self createMenuItem];
}

// 添加通知
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTranslationPopover) name:ShowPopoverNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageHovering:) name:PageHoveringNotification object:nil];
}

// 创建菜单栏Item及popover
- (void)createMenuItem {
    
    // 创建NSStatusItem并显示在系统状态栏上
    self.statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:IconStutas]) {
        [self.statusItem.button setImage:[NSImage imageNamed:@"StatusSuccessImage"]];
    }else {
        [self.statusItem.button setImage:[NSImage imageNamed:@"StatusImage"]];
    }
    // 添加点击事件
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(showPopover);
    // 创建popover
    self.popover = [[NSPopover alloc]init];
    //NSPopoverBehaviorApplicationDefined  悬停
    if ([[NSUserDefaults standardUserDefaults]boolForKey:PageHovering]) {
        self.popover.behavior = NSPopoverBehaviorApplicationDefined;
    }else {
        self.popover.behavior = NSPopoverBehaviorTransient;
    }
    self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    self.popover.contentViewController = [[STPopoverViewController alloc]initWithNibName:@"STPopoverViewController" bundle:nil];
    [self showTranslationPopover];
}

// 显示popover
- (void)showPopover {
    
    if (self.popover.isShown) {
        [self.popover close];
    }else {
        [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMaxY];
    }
}

// 显示翻译界面
- (void)showTranslationPopover {
    
    [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMaxY];
}

// 翻译界面悬停通知
- (void)pageHovering:(NSNotification *)not {
    
    NSLog(@"%@,%ld",not.object[@"PageHovering"],(long)self.popover.behavior);
    if ([not.object[@"PageHovering"] boolValue]) {
        self.popover.behavior = NSPopoverBehaviorApplicationDefined;
    }else {
        self.popover.behavior = NSPopoverBehaviorTransient;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
