//
//  ATPreferencesWindowController.m
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATPreferencesWindowController.h"

@interface ATPreferencesWindowController () {
    ATPreferencesWindowDisplayMode _displayMode;
}

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
    
    self.wantsStartAtLogin = [self.userDefaults boolForKey:@"wantsStartAtLogin"];
    if (self.wantsStartAtLogin) {
        self.startAtLoginBox.state = NSControlStateValueOn;
    } else {
        self.startAtLoginBox.state = NSControlStateValueOff;
    }
    
    _displayMode = ATPreferencesWindowDisplayBasicSettings;
    [self.displayView addSubview:self.basicSettingView];
    
    self.okButton.target = self;
    self.okButton.action = @selector(handleOkButton);
    
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(handleCancelButton);
    
    self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATPreferencesWindowClose" object:nil];
}

- (void)handleWantsStartAtLoginBox {
    switch (self.startAtLoginBox.state) {
        case NSControlStateValueOn:
            self.wantsStartAtLogin = YES;
            break;
            
        case NSControlStateValueOff:
            self.wantsStartAtLogin = NO;
            break;
            
        case NSControlStateValueMixed:
            break;
    }
}

- (void)handleOkButton {
    [self.userDefaults setBool:self.wantsStartAtLogin forKey:@"wantsStartAtLogin"];
    [self.userDefaults synchronize];
    [self.window close];
}

- (void)handleCancelButton {
    [self close];
}



@end
