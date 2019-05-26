//
//  ATPreferencesWindowController.h
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATDataModel.h"
#import "AIRecordingData+CoreDataClass.h"
#import "AIRecordingData+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATPreferencesWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>

typedef enum ATPreferencesWindowDisplayMode {
    ATPreferencesWindowDisplayBasicSettings,
    ATPreferencesWindowDisplayIgnoredBundleIDs,
    ATPreferencesWindowDisplayRawData
} ATPreferencesWindowDisplayMode;

@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) ATDataModel *dataModel;
@property (nonatomic) BOOL wantsStartAtLogin;
@property (nonatomic) NSMutableArray<NSString *> *ignoredBundleIDs;
@property (nonatomic) NSMutableArray<AIRecordingData *> *recordingDatas;
@property (nonatomic) NSMutableArray<AIRecordingData *> *deletedDatas;

@property (nonatomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet NSView *displayView;

@property (nonatomic, weak) IBOutlet NSView *basicSettingView;
@property (nonatomic, weak) IBOutlet NSButton *startAtLoginBox;

@property (nonatomic, weak) IBOutlet NSView *ignoredBundleIDsView;
@property (nonatomic, weak) IBOutlet NSTableView *ignoredBundleIDsTableView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *ignoredBundleIDsSegmentedControl;

@property (nonatomic, weak) IBOutlet NSView *rawDataView;
@property (nonatomic, weak) IBOutlet NSDatePicker *startDatePicker;
@property (nonatomic, weak) IBOutlet NSDatePicker *endDatePicker;
@property (nonatomic, weak) IBOutlet NSButton *hasBundleIDBox;
@property (nonatomic, weak) IBOutlet NSTextField *bundleIDTextField;
@property (nonatomic, weak) IBOutlet NSButton *queryButton;
@property (nonatomic, weak) IBOutlet NSTableView *rawDataTableView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *rawDataSegmentedControl;

@property (nonatomic) IBOutlet NSButton *okButton;
@property (nonatomic) IBOutlet NSButton *cancelButton;

@end

NS_ASSUME_NONNULL_END
