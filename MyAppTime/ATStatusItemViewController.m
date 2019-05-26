//
//  ATStatusItemViewController.m
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATStatusItemViewController.h"

@interface ATStatusItemViewController () {
    ATCurrentDisplayMode _currentDisplayMode;
}

@end

@implementation ATStatusItemViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.recordingDataValues = [NSMutableArray<ATTimeUnit *> array];
        self.recordingDataNames = [NSMutableArray<NSString *> array];
        _currentDisplayMode = ATCurrentModeDisplayDay;
        return self;
    }
    return nil;
}

- (void)initDataModel:(ATDataModel *)dataModel andBundleID:(NSString *)bundleID {
    self.dataModel = dataModel;
    self.bundleID = bundleID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeDataSourceToTodayRecordings];
    
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    [self.barChartView reloadData];
    
    self.segmentedControl.target = self;
    self.segmentedControl.action = @selector(segmentedControlSelectionDidChange);
    
    self.showMoreButton.target = self;
    self.showMoreButton.action = @selector(handleShowMore);
    
    self.preferencesButton.target = self;
    self.preferencesButton.action = @selector(handlePreferences);
    
    self.quitButton.target = self;
    self.quitButton.action = @selector(handleQuit);
    // Do view setup here.
}

- (void)viewDidAppear {
    
}

- (void)handleShowMore {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATStatusItemShowMore" object:nil];
}

- (void)handlePreferences {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATStatusItemPreferences" object:nil];
}

- (void)handleQuit {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATStatusItemQuit" object:nil];
}

#pragma mark - today's datasource
- (void)changeDataSourceToTodayRecordings {
    self.recordingDataValues = [self todayRecordingsForBundleID:self.bundleID].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < 24; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d时", i] atIndex:i];
    }
}

- (NSArray<ATTimeUnit *> *)todayRecordingsForBundleID:(NSString *)bundleID {
    const int dayHours = 24;
    NSMutableArray<ATTimeUnit *> *todayRecordings = [NSMutableArray<ATTimeUnit *> arrayWithCapacity:dayHours];
    for (int hour = 0; hour < dayHours; hour++) {
        [todayRecordings insertObject:[[ATTimeUnit alloc] init] atIndex:hour];
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forDate:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int hour = [calendar component:NSCalendarUnitHour fromDate:recordingDate];
        [todayRecordings[hour] addSeconds:recordingData.duration];
    }
    
    return todayRecordings;
}

#pragma mark - this week's datasource
- (void)changeDataSourceToThisWeekRecordings {
    self.recordingDataValues = [self thisWeekRecordingsForBundleID:self.bundleID].copy;
    [self.recordingDataNames removeAllObjects];
    self.recordingDataNames = @[@"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日"].mutableCopy;
}

- (NSArray<ATTimeUnit *> *)thisWeekRecordingsForBundleID:(NSString *)bundleID {
    const int weekDays = 7;
    NSMutableArray<ATTimeUnit *> *thisWeekRecordings = [NSMutableArray<ATTimeUnit *> arrayWithCapacity:weekDays];
    for (int day = 0; day < weekDays; day++) {
        [thisWeekRecordings insertObject:[[ATTimeUnit alloc] init] atIndex:day];
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forWeek:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int day = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:recordingDate] - 1;
        [thisWeekRecordings[day] addSeconds:recordingData.duration];
    }
    return thisWeekRecordings;
}

#pragma mark - this month's datasource
- (void)changeDataSourceToThisMonthRecordings {
    self.recordingDataValues = [self thisMonthRecordingsForBundleID:self.bundleID].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < self.recordingDataValues.count; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d号", i + 1] atIndex:i];
    }
}

- (NSArray<ATTimeUnit *> *)thisMonthRecordingsForBundleID:(NSString *)bundleID {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    const int monthDays = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:now].length;
    NSMutableArray<ATTimeUnit *> *thisMonthRecordings = [NSMutableArray<ATTimeUnit *> arrayWithCapacity:monthDays];
    for (int day = 0; day < monthDays; day++) {
        [thisMonthRecordings insertObject:[[ATTimeUnit alloc] init] atIndex:day];
    }
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forMonth:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int day = [calendar component:NSCalendarUnitDay fromDate:recordingDate] - 1;
        [thisMonthRecordings[day] addSeconds:recordingData.duration];
    }
    return thisMonthRecordings;
}

#pragma mark - this year's datasource
- (void)changeDataSourceToThisYearRecordings {
    self.recordingDataValues = [self thisYearRecordingsForBundleID:self.bundleID].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < self.recordingDataValues.count; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d月", i + 1] atIndex:i];
    }
}

- (NSArray<ATTimeUnit *> *)thisYearRecordingsForBundleID:(NSString *)bundleID {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    const int yearMonths = 12;
    NSMutableArray<ATTimeUnit *> *thisYearRecordings = [NSMutableArray<ATTimeUnit *> arrayWithCapacity:yearMonths];
    for (int month = 0; month < yearMonths; month++) {
        [thisYearRecordings insertObject:[[ATTimeUnit alloc] init] atIndex:month];
    }
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForBundleID:bundleID forYear:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        NSDate *recordingDate = recordingData.date;
        int month = [calendar component:NSCalendarUnitMonth fromDate:recordingDate] - 1;
        [thisYearRecordings[month] addSeconds:recordingData.duration];
    }
    return thisYearRecordings;
}

#pragma mark - adjust view
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

#pragma mark - conform to <ATBarChartViewDelegate> and <ATBarChartViewDataSource>
- (float)barChartView:(nonnull ATBarChartView *)barChartView heightForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataValues) {
        ATTimeUnit *duration = self.recordingDataValues[index];
        return duration.floatValue;
    }
    return 0.0;
}

- (float)widthForBarsInBarChartView:(ATBarChartView *)barChartView {
    double width = 0;;
    switch (_currentDisplayMode) {
        case ATCurrentModeDisplayDay:
            width = 10;
            break;
            
        case ATCurrentModeDisplayWeek:
            width = 40;
            break;
            
        case ATCurrentModeDisplayMonth:
            width = 10;
            break;
            
        case ATCurrentModeDisplayYear:
            width = 20;
    }
    return width;
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

- (ATTimeUnit *)barChartView:(ATBarChartView *)barChartView timeUnitForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataValues) {
        return self.recordingDataValues[index];
    }
    return [[ATTimeUnit alloc] init];
}

@end
