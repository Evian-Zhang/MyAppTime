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
    NSCalendar *_calendar;
    NSDateFormatter *_dateFormatter;
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
    
    [self changeToBasicSettingView];
    
    NSArray<NSString *> *tmpIgnoredBundleIDs = [self.userDefaults arrayForKey:@"ignoredBundleIDs"];
    if (tmpIgnoredBundleIDs) {
        self.ignoredBundleIDs = tmpIgnoredBundleIDs.mutableCopy;
    } else {
        self.ignoredBundleIDs = [NSMutableArray<NSString *> array];
    }
    
    self.segmentedControl.target = self;
    self.segmentedControl.action = @selector(handleSegmentedControl);
    
    self.okButton.target = self;
    self.okButton.action = @selector(handleOkButton);
    
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(handleCancelButton);
    
    self.window.delegate = self;
    
    _calendar = [NSCalendar currentCalendar];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATPreferencesWindowClose" object:nil];
}

- (void)changeToBasicSettingView {
    NSArray<NSView *> *subviews = self.displayView.subviews;
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    _displayMode = ATPreferencesWindowDisplayBasicSettings;
    [self.displayView addSubview:self.basicSettingView];
    self.startAtLoginBox.target = self;
    self.startAtLoginBox.action = @selector(handleWantsStartAtLoginBox);
    if (self.wantsStartAtLogin) {
        self.startAtLoginBox.state = NSControlStateValueOn;
    } else {
        self.startAtLoginBox.state = NSControlStateValueOff;
    }
    
    self.recordingDatas = [NSMutableArray<AIRecordingData *> array];
    self.deletedDatas = [NSMutableArray<AIRecordingData *> array];
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

- (void)changeToIgnoredBundleIDsView {
    NSArray<NSView *> *subviews = self.displayView.subviews;
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    _displayMode = ATPreferencesWindowDisplayIgnoredBundleIDs;
    [self.displayView addSubview:self.ignoredBundleIDsView];
    self.ignoredBundleIDsTableView.delegate = self;
    self.ignoredBundleIDsTableView.dataSource = self;
    [self.ignoredBundleIDsTableView reloadData];
    
    self.ignoredBundleIDsSegmentedControl.target = self;
    self.ignoredBundleIDsSegmentedControl.action = @selector(handleIgnoredBundleIDsSegmentedControl);
    
    self.recordingDatas = [NSMutableArray<AIRecordingData *> array];
    self.deletedDatas = [NSMutableArray<AIRecordingData *> array];
}

- (void)handleIgnoredBundleIDsSegmentedControl {
    switch (self.ignoredBundleIDsSegmentedControl.selectedSegment) {
        case 0:
            [self.ignoredBundleIDs addObject:NSLocalizedString(@"Please enter in a bundle ID", @"ATPreferencesWindowController.ignoredBundleIDsSegmentedControl.PlusSign")];
            [self.ignoredBundleIDsTableView reloadData];
            [self.ignoredBundleIDsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.ignoredBundleIDs.count - 1] byExtendingSelection:YES];
            break;
            
        case 1:
        {
            NSInteger selectedRow = self.ignoredBundleIDsTableView.selectedRow;
            if (selectedRow > -1) {
                [self.ignoredBundleIDs removeObjectAtIndex:selectedRow];
                [self.ignoredBundleIDsTableView reloadData];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)changeToRawDataView {
    NSArray<NSView *> *subviews = self.displayView.subviews;
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    _displayMode = ATPreferencesWindowDisplayRawData;
    [self.displayView addSubview:self.rawDataView];
    self.recordingDatas = [NSMutableArray<AIRecordingData *> array];
    self.deletedDatas = [NSMutableArray<AIRecordingData *> array];
    
    self.rawDataTableView.delegate = self;
    self.rawDataTableView.dataSource = self;
    [self.rawDataTableView reloadData];
    
    self.hasBundleIDBox.state = NSControlStateValueOff;
    self.bundleIDTextField.stringValue = NSLocalizedString(@"Please enter a bundleID", @"ATPreferencesWindowController.RawDataView.bundleIDTextField.stringValue");
    
    self.queryButton.target = self;
    self.queryButton.action = @selector(handleQuery);
    
    self.rawDataSegmentedControl.target = self;
    self.rawDataSegmentedControl.action = @selector(handleRawDataSegmentedControl);
}

- (void)handleQuery {
    NSDate *startDate = self.startDatePicker.dateValue;
    NSDate *endDate = self.endDatePicker.dateValue;
    if ([startDate compare:endDate] == NSOrderedAscending) {
        NSString *queriedBundleID;
        if (self.hasBundleIDBox.state == NSControlStateValueOn) {
            if (self.bundleIDTextField.stringValue.length > 0) {
                queriedBundleID = self.bundleIDTextField.stringValue.copy;
            } else {
                queriedBundleID = @"ATNothing";
            }
        }
        NSArray<AIRecordingData *> *tmpRecordingDatas = [self.dataModel recordingDatasFrom:startDate to:endDate withBundleID:queriedBundleID];
        for (AIRecordingData *recordingData in tmpRecordingDatas) {
            [self.recordingDatas addObject:recordingData];
        }
        [self.rawDataTableView reloadData];
    }
}

- (void)handleRawDataSegmentedControl {
    if (self.rawDataSegmentedControl.selectedSegment == 0) {
        NSInteger selectedRow = self.rawDataTableView.selectedRow;
        if (selectedRow > -1) {
            [self.deletedDatas addObject:self.recordingDatas[selectedRow]];
            [self.recordingDatas removeObjectAtIndex:selectedRow];
            [self.rawDataTableView reloadData];
        }
    }
}

- (void)handleSegmentedControl {
    switch (self.segmentedControl.selectedSegment) {
        case 0:
            [self changeToBasicSettingView];
            break;
            
        case 1:
            [self changeToIgnoredBundleIDsView];
            break;
            
        case 2:
            [self changeToRawDataView];
            break;
            
        default:
            break;
    }
}

- (void)handleOkButton {
    [self.userDefaults setBool:self.wantsStartAtLogin forKey:@"wantsStartAtLogin"];
    [self.userDefaults setObject:self.ignoredBundleIDs.copy forKey:@"ignoredBundleIDs"];
    [self.userDefaults synchronize];
    [self.dataModel removeRecordingDatas:self.deletedDatas];
    [self.window close];
}

- (void)handleCancelButton {
    [self close];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([tableView.identifier isEqualToString:@"ATIgnoredBundleIDsTable"]) {
        if (self.ignoredBundleIDs) {
            return self.ignoredBundleIDs.count;
        }
        return 0;
    } else if ([tableView.identifier isEqualToString:@"ATRawDataTable"]) {
        if (self.recordingDatas) {
            return self.recordingDatas.count;
        }
        return 0;
    }
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableView.identifier isEqualToString:@"ATIgnoredBundleIDsTable"]) {
        NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ATIgnoredBundleIDsTableCell" owner:nil];
        tableCellView.textField.stringValue = self.ignoredBundleIDs[row];
        return tableCellView;
    } else if ([tableView.identifier isEqualToString:@"ATRawDataTable"]) {
        if (tableColumn == self.rawDataTableView.tableColumns[0]) {
            NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ATRawDataBundleIDCell" owner:nil];
            tableCellView.textField.stringValue = self.recordingDatas[row].bundleID;
            return tableCellView;
        } else if (tableColumn == self.rawDataTableView.tableColumns[1]) {
            NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ATRawDataDateCell" owner:nil];
            tableCellView.textField.stringValue = [_dateFormatter stringFromDate:self.recordingDatas[row].date];
            return tableCellView;
        } else if (tableColumn == self.rawDataTableView.tableColumns[2]) {
            NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ATRawDataDurationCell" owner:nil];
            tableCellView.textField.stringValue = [NSString stringWithFormat:@"%.1f", self.recordingDatas[row].duration];
            return tableCellView;
        }
    }
    return nil;
}

@end
