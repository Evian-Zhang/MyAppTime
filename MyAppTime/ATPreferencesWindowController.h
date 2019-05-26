//
//  ATPreferencesWindowController.h
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATPreferencesWindowController : NSWindowController <NSWindowDelegate>

typedef enum ATPreferencesWindowDisplayMode {
    ATPreferencesWindowDisplayBasicSettings,
    ATPreferencesWindowDisplayIgnoredBundleIDs,
    ATPreferencesWindowDisplayRawData
} ATPreferencesWindowDisplayMode;

@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL wantsStartAtLogin;

@property (nonatomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet NSView *displayView;
@property (nonatomic) IBOutlet NSView *basicSettingView;
@property (nonatomic) IBOutlet NSButton *startAtLoginBox;
@property (nonatomic) IBOutlet NSButton *okButton;
@property (nonatomic) IBOutlet NSButton *cancelButton;

@end

NS_ASSUME_NONNULL_END
