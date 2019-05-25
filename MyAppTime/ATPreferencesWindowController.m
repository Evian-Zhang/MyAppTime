//
//  ATPreferencesWindowController.m
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATPreferencesWindowController.h"

@interface ATPreferencesWindowController ()

@end

@implementation ATPreferencesWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        return self;
    }
    return nil;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    if ([self.userDefaults boolForKey:@"wantsStartAtLogin"]) {
        self.startAtLoginBox.state = NSControlStateValueOn;
    } else {
        self.startAtLoginBox.state = NSControlStateValueOff;
    }
    
    self.okButton.target = self;
    self.okButton.action = @selector(handleOkButton);
}

- (void)handleOkButton {
    BOOL wantsStartAtLogin = NO;
    if (self.startAtLoginBox.state == NSControlStateValueOn) {
        wantsStartAtLogin = YES;
    }
    [self.userDefaults setBool:wantsStartAtLogin forKey:@"wantsStartAtLogin"];
    [self.userDefaults synchronize];
    [self.window close];
}

@end
