//
//  STPopoverViewController.m
//  SimpleTranslation
//
//  Created by 陈洪强 on 2019/2/12.
//  Copyright © 2019 dusmit. All rights reserved.
//

#import "STPopoverViewController.h"
#import "STNetworkingManager.h"
#import "STAppConfig.h"
#import "STClipboard.h"
#import "STAboutViewController.h"
#import "NSString+Extension.h"
#import "AppDelegate.h"

@interface STPopoverViewController ()<NSTextViewDelegate, STClipboardDelegate>

@property (weak) IBOutlet NSScrollView *inputScrollView;
@property (weak) IBOutlet NSScrollView *outputScrollView;
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outupTextView;
@property (weak) IBOutlet NSButton *settingButton;
@property (nonatomic, assign) BOOL isOpenSetting;
@property (strong) IBOutlet NSView *settingView;
@property (weak) IBOutlet NSButton *autoStart;
@property (weak) IBOutlet NSButton *pageHovering;
@property (weak) IBOutlet NSButton *seeingPaste;
@property (weak) IBOutlet NSButton *showTransView;
@property (weak) IBOutlet NSButton *iconStutas;

@end

@implementation STPopoverViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHotKeyEvent:) name:HotKeyEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenSettingButton) name:HiddenSettingNotification object:nil];
    
    [self viewUIConfig];
    [self pasteboardSetting];
}

- (void)viewWillAppear {
    
    [super viewWillAppear];
    
    self.isOpenSetting = false;
    [self.settingButton setImage:[NSImage imageNamed:@"UpwardImage"]];
}

// 页面UI配置
- (void)viewUIConfig {
    
    self.inputTextView.delegate = self;
    self.inputTextView.font = [NSFont systemFontOfSize:18.0];
    self.outupTextView.delegate = self;
    self.outupTextView.font = [NSFont systemFontOfSize:18.0];
    
    [self.inputScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top).offset(10);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.offset(60);
    }];
    [self.outputScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.inputScrollView.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.offset(60);
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.outputScrollView.mas_bottom).offset(4);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.offset(16);
    }];
    [self.view addSubview:self.settingView];
    [self.settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.settingButton.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.offset(260);
        //make.bottom.equalTo(self.view.window).offset(-10);
    }];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:FirstStart]) {
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:FirstStart];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:AutoStart];
        [[NSUserDefaults standardUserDefaults]setBool:false forKey:PageHovering];
        [[NSUserDefaults standardUserDefaults]setBool:false forKey:SeeingPaste];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:ShowTransView];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:IconStutas];
    }
    self.autoStart.state = [[NSUserDefaults standardUserDefaults]boolForKey:AutoStart];
    self.pageHovering.state = [[NSUserDefaults standardUserDefaults]boolForKey:PageHovering];
    self.seeingPaste.state = [[NSUserDefaults standardUserDefaults]boolForKey:SeeingPaste];
    self.showTransView.state = [[NSUserDefaults standardUserDefaults]boolForKey:ShowTransView];
    self.iconStutas.state = [[NSUserDefaults standardUserDefaults]boolForKey:IconStutas];
}

- (IBAction)settingButtonTouch:(id)sender {
    
    if (self.isOpenSetting) {
        self.isOpenSetting = false;
        [self.settingButton setImage:[NSImage imageNamed:@"UpwardImage"]];
        
        [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y+260, self.view.window.frame.size.width, self.view.window.frame.size.height-260) display:true];
    }else {
        self.isOpenSetting = true;
        [self.settingButton setImage:[NSImage imageNamed:@"DownImage"]];
        [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y-260, self.view.window.frame.size.width, self.view.window.frame.size.height+260) display:true];
    }
}

- (void)hiddenSettingButton {
    
    if (self.isOpenSetting) {
        self.isOpenSetting = false;
        [self.settingButton setImage:[NSImage imageNamed:@"UpwardImage"]];
        [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y+260, self.view.window.frame.size.width, self.view.window.frame.size.height-260) display:true];
    }
}

// 请求翻译API
- (void)requestTranslation {
    
    if (self.inputTextView.string.length <= 0) {
        return;
    }
    NSString *to = @"zh";
    // 判断是否含有汉字
    for(int i = 0; i< [self.inputTextView.string length]; i ++) {
        
        int a = [self.inputTextView.string characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            to = @"en";
        }
    }
    NSString *str = [NSString stringWithFormat:@"20190201000261768%@1InSYmqlZJgUpMyS67Oiz",self.inputTextView.string];
    NSDictionary *parameters = @{@"q" : self.inputTextView.string,
                                 @"from" : @"auto",
                                 @"to" : to,
                                 @"appid" : @"20190201000261768",
                                 @"salt" : @"1",
                                 @"sign" : [str MD5]};
    
    AppDelegate * appDelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:IconStutas]) {
        [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusWaitImage"]];
    }
    
    [NetWorkManager POST:@"vip/translate" parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if (httpResponse.statusCode == 200) {
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:IconStutas]) {
                [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusSuccessImage"]];
            }
            NSDictionary *dic = [[NSDictionary alloc]initWithDictionary:responseObject];
            NSArray *arr = [dic objectForKey:@"trans_result"];
            NSString *str = [NSString string];
            for (NSDictionary *dict in arr) {
                str = [NSString stringWithFormat:@"%@%@",str,[dict objectForKey:@"dst"]];
            }
            self.outupTextView.string = str;
        }else {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:IconStutas]) {
                [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusFailImage"]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:IconStutas]) {
            [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusFailImage"]];
        }
    }];
}

- (void)handleHotKeyEvent:(NSNotification *)noti {
    
    NSInteger hotKeyID = [[noti.userInfo objectForKey:HotKeyID] intValue];
    
    if (hotKeyID == 4) {
        
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        if ([[pasteboard types] containsObject:NSPasteboardTypeString]) {
            // s 就是剪切板里的字符串, 如果你拷贝的是一个或多个的文件,文件夹, 这里就是文件或文件夹的名称
            self.inputTextView.string = [pasteboard stringForType:NSPasteboardTypeString];
            NSLog(@"剪切板里的字符串-->%@", [pasteboard stringForType:NSPasteboardTypeString]);
            if ([[NSUserDefaults standardUserDefaults]boolForKey:ShowTransView]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ShowPopoverNotification object:nil userInfo:nil];
            }
            [self requestTranslation];
        }
    }
    if (hotKeyID == 5) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
        [pasteboard setString:self.outupTextView.string forType:NSPasteboardTypeString];
        NSLog(@"写入剪贴板的字符串-->%@", self.outupTextView.string);
    }
}

- (void)hiddenSetting {
    
}

#pragma mark -- NSTextViewDelegate
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    
    /*
     CGFloat height = [textView.string boundingRectWithSize:NSMakeSize(textView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textView.font}].size.height;
     if (height > 60) {
     
     //        [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y, self.view.window.frame.size.width, self.view.window.frame.size.height+(height+60)) display:true];
     //
     [self.view.window setFrame:CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y-(height-60), self.view.window.frame.size.width, self.view.window.frame.size.height+(height-60)) display:true];
     
     [self.inputScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
     
     make.height.offset(height);
     }];
     }
     */
    if ([replacementString isEqualToString:@"\n"]) {
        
        [self requestTranslation];
        
        return NO;
    }
    
    return YES;
}

- (void)pasteboardSetting {
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:SeeingPaste]) {
        
        [[STClipboard sharedInstance]startWithDelegate:self];
    }
}

- (void)pasteboardDidUpdate:(NSString *)string {
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    self.inputTextView.string = [pasteboard stringForType:NSPasteboardTypeString];
    NSLog(@"剪切板里的字符串-->%@", [pasteboard stringForType:NSPasteboardTypeString]);
    if ([[NSUserDefaults standardUserDefaults]boolForKey:ShowTransView]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ShowPopoverNotification object:nil userInfo:nil];
    }
    [self requestTranslation];
}

#pragma mark -- setting action
- (IBAction)autoStart:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.state forKey:AutoStart];
}

- (IBAction)pageHovering:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.state forKey:PageHovering];
    [[NSNotificationCenter defaultCenter]postNotificationName:PageHoveringNotification object:@{@"PageHovering" : [NSNumber numberWithBool:sender.state]}];
}

- (IBAction)seeingPaste:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.state forKey:SeeingPaste];
    if (sender.state) {
        [[STClipboard sharedInstance]startWithDelegate:self];
    }else {
        [[STClipboard sharedInstance]stop];
    }
}

- (IBAction)showTransView:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.state forKey:ShowTransView];
}

- (IBAction)iconStutas:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.state forKey:IconStutas];
    AppDelegate * appDelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
    if (sender.state) {
        [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusSuccessImage"]];
    }else {
        [appDelegate.statusItem.button setImage:[NSImage imageNamed:@"StatusImage"]];
    }
}

- (IBAction)aboutTouch:(NSButton *)sender {
    
    // 创建popover
    NSPopover *popover = [[NSPopover alloc]init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    popover.contentViewController = [[STAboutViewController alloc]initWithNibName:@"STAboutViewController" bundle:nil];
    [popover showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)closeTouch:(NSButton *)sender {
    
    [[NSApplication sharedApplication] terminate:nil];
}


@end
