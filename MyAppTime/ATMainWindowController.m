//
//  ATMainWindowController.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/26.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATMainWindowController.h"

@interface ATMainWindowController ()

@end

@implementation ATMainWindowController {
    ATCurrentDisplayMode _currentDisplayMode;
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.recordingDataValues = [NSMutableArray array];
        self.recordingDataNames = [NSMutableArray array];
        _currentDisplayMode = ATCurrentModeDisplayDay;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self changeDataSourceToTodayRecordings];
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    [self adjustBarChartViewClipView];
    
    self.segmentedControl.target = self;
    self.segmentedControl.action = @selector(segmentedControlSelectionDidChange);
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)changeDataSourceToTodayRecordings {
    self.recordingDataValues = [self todayRecordingsForBundleID:ATTotalTime].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < 24; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d时", i] atIndex:i];
    }
}

- (NSArray<NSNumber *> *)todayRecordingsForBundleID:(NSString *)bundleID {
    const int dayHours = 24;
    NSMutableArray<NSNumber *> *todayRecordings = [NSMutableArray<NSNumber *> arrayWithCapacity:dayHours];
    for (int hour = 0; hour < dayHours; hour++) {
        [todayRecordings insertObject:[NSNumber numberWithDouble:0.0] atIndex:hour];
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forDate:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int hour = [calendar component:NSCalendarUnitHour fromDate:recordingDate];
        double duration = todayRecordings[hour].doubleValue;
        todayRecordings[hour] = [NSNumber numberWithDouble:duration + recordingData.duration];
    }
    
    return todayRecordings;
}

- (void)changeDataSourceToThisWeekRecordings {
    self.recordingDataValues = [self thisWeekRecordingForBundleID:ATTotalTime].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < 7; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"周%d", i + 1] atIndex:i];
    }
}

- (NSArray<NSNumber *> *)thisWeekRecordingForBundleID:(NSString *)bundleID {
    const int weekDays = 7;
    NSMutableArray<NSNumber *> *thisWeekRecordings = [NSMutableArray<NSNumber *> arrayWithCapacity:weekDays];
    for (int day = 0; day < weekDays; day++) {
        [thisWeekRecordings insertObject:[NSNumber numberWithDouble:0.0] atIndex:day];
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forWeek:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int day = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:recordingDate] - 1;
        double duration = thisWeekRecordings[day].doubleValue;
        thisWeekRecordings[day] = [NSNumber numberWithDouble:duration + recordingData.duration];
    }
    return thisWeekRecordings;
}

- (void)changeDataSourceToThisMonthRecordings {
    self.recordingDataValues = [self thisMonthRecordingForBundleID:ATTotalTime].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < self.recordingDataValues.count; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d号", i + 1] atIndex:i];
    }
}

- (NSArray<NSNumber *> *)thisMonthRecordingForBundleID:(NSString *)bundleID {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    const int monthDays = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:now].length;
    NSMutableArray<NSNumber *> *thisMonthRecordings = [NSMutableArray<NSNumber *> arrayWithCapacity:monthDays];
    for (int day = 0; day < monthDays; day++) {
        [thisMonthRecordings insertObject:[NSNumber numberWithDouble:0.0] atIndex:day];
    }
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forMonth:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int day = [calendar component:NSCalendarUnitDay fromDate:recordingDate] - 1;
        double duration = thisMonthRecordings[day].doubleValue;
        thisMonthRecordings[day] = [NSNumber numberWithDouble:duration + recordingData.duration];
    }
    return thisMonthRecordings;
}

- (void)changeDataSourceToThisYearRecordings {
    self.recordingDataValues = [self thisYearRecordingForBundleID:ATTotalTime].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < self.recordingDataValues.count; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d月", i + 1] atIndex:i];
    }
}

- (NSArray<NSNumber *> *)thisYearRecordingForBundleID:(NSString *)bundleID {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    const int yearMonths = 12;
    NSMutableArray<NSNumber *> *thisYearRecordings = [NSMutableArray<NSNumber *> arrayWithCapacity:yearMonths];
    for (int month = 0; month < yearMonths; month++) {
        [thisYearRecordings insertObject:[NSNumber numberWithDouble:0.0] atIndex:month];
    }
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forYear:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int month = [calendar component:NSCalendarUnitMonth fromDate:recordingDate] - 1;
        double duration = thisYearRecordings[month].doubleValue;
        thisYearRecordings[month] = [NSNumber numberWithDouble:duration + recordingData.duration];
    }
    return thisYearRecordings;
}

- (void)adjustBarChartViewClipView {
    [self.barChartView scrollToPoint:NSMakePoint(0.0, self.barChartView.frame.size.height)];
}

- (void)segmentedControlSelectionDidChange {
    switch (self.segmentedControl.selectedSegment) {
        case 0:
            _currentDisplayMode = ATCurrentModeDisplayDay;
            [self changeDataSourceToTodayRecordings];
            [self.barChartView reloadData];
            break;
            
        case 1:
            _currentDisplayMode = ATCurrentModeDisplayWeek;
            [self changeDataSourceToThisWeekRecordings];
            [self.barChartView reloadData];
            break;
            
        case 2:
            _currentDisplayMode = ATCurrentModeDisplayMonth;
            [self changeDataSourceToThisMonthRecordings];
            [self.barChartView reloadData];
            break;
            
        case 3:
            _currentDisplayMode = ATCurrentModeDisplayYear;
            [self changeDataSourceToThisYearRecordings];
            [self.barChartView reloadData];
            break;
            
        default:
            break;
    }
}

- (nonnull NSColor *)barChartView:(nonnull ATBarChartView *)barChartView colorForBarAtIndex:(NSUInteger)index {
    return [NSColor textColor];
}

- (float)barChartView:(nonnull ATBarChartView *)barChartView heightForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataValues) {
        NSNumber *duration = self.recordingDataValues[index];
        return duration.doubleValue;
    }
    return 0.0;
}

- (nonnull NSString *)barChartView:(nonnull ATBarChartView *)barChartView titleForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataNames) {
        return self.recordingDataNames[index];
    }
    return @"";
}

- (NSUInteger)numberOfBarsInBarChartView:(nonnull ATBarChartView *)barChartView {
    if (self.recordingDataNames) {
        return self.recordingDataNames.count;
    }
    return 0;
}

@end
