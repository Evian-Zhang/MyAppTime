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
        self.recordingDataValues = [NSMutableArray<ATTimeUnit *> array];
        self.recordingDataNames = [NSMutableArray<NSString *> array];
        self.recordingDurations = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
        self.recordingBundleIDs = [NSArray<NSString *> array];
        self.appTimeWindowControllers = [NSMutableArray<ATAppTimeWindowController *> array];
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    self.segmentedControl.target = self;
    self.segmentedControl.action = @selector(segmentedControlSelectionDidChange);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppTimeWindowHasClosed:) name:@"ATAppTimeWindowHasClosed" object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)handleAppTimeWindowHasClosed:(NSNotification *)notifiction {
    ATAppTimeWindowController *appTimeWindowController = [notifiction.userInfo objectForKey:@"self"];
    if (appTimeWindowController) {
        [self.appTimeWindowControllers removeObject:appTimeWindowController];
    }
}

- (void)windowDidResize:(NSNotification *)notification {
    [self.barChartView reloadData];
}

#pragma mark - today's datasource
- (void)changeDataSourceToTodayRecordings {
    self.recordingDataValues = [self todayRecordingsForBundleID:ATTotalTime].copy;
    self.recordingDurations = [self todayRecordings].copy;
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

- (NSDictionary<NSString *, ATTimeUnit *> *)todayRecordings {
    NSMutableDictionary<NSString *, ATTimeUnit *> *todayRecordings = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
    NSDate *now = [NSDate date];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForDate:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        if ([recordingData.bundleID isEqualToString:ATTotalTime]) {
            continue;
        }
        ATTimeUnit *duration = [todayRecordings objectForKey:recordingData.bundleID];
        if (!duration) {
            duration = [[ATTimeUnit alloc] init];
            [todayRecordings setObject:duration forKey:recordingData.bundleID];
        }
        [duration addSeconds:recordingData.duration];
    }
    self.recordingBundleIDs = [todayRecordings keysSortedByValueUsingComparator:^NSComparisonResult(ATTimeUnit *  _Nonnull obj1, ATTimeUnit *  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    return todayRecordings;
}

#pragma mark - this week's datasource
- (void)changeDataSourceToThisWeekRecordings {
    self.recordingDataValues = [self thisWeekRecordingsForBundleID:ATTotalTime].copy;
    self.recordingDurations = [self thisWeekRecordings].copy;
    [self.recordingDataNames removeAllObjects];
    for (int i = 0; i < 7; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"周%d", i + 1] atIndex:i];
    }
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

- (NSDictionary<NSString *, ATTimeUnit *> *)thisWeekRecordings {
    NSMutableDictionary<NSString *, ATTimeUnit *> *thisWeekRecordings = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForWeek:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        if ([recordingData.bundleID isEqualToString:ATTotalTime]) {
            continue;
        }
        ATTimeUnit *duration = [thisWeekRecordings objectForKey:recordingData.bundleID];
        if (!duration) {
            duration = [[ATTimeUnit alloc] init];
            [thisWeekRecordings setObject:duration forKey:recordingData.bundleID];
        }
        [duration addSeconds:recordingData.duration];
    }
    self.recordingBundleIDs = [thisWeekRecordings keysSortedByValueUsingComparator:^NSComparisonResult(ATTimeUnit *  _Nonnull obj1, ATTimeUnit *  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    return thisWeekRecordings;
}

#pragma mark - this month's datasource
- (void)changeDataSourceToThisMonthRecordings {
    self.recordingDataValues = [self thisMonthRecordingsForBundleID:ATTotalTime].copy;
    self.recordingDurations = [self thisMonthRecordings].copy;
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

- (NSDictionary<NSString *, ATTimeUnit *> *)thisMonthRecordings {
    NSMutableDictionary<NSString *, ATTimeUnit *> *thisMonthRecordings = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
    NSDate *now = [NSDate date];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForMonth:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        if ([recordingData.bundleID isEqualToString:ATTotalTime]) {
            continue;
        }
        ATTimeUnit *duration = [thisMonthRecordings objectForKey:recordingData.bundleID];
        if (!duration) {
            duration = [[ATTimeUnit alloc] init];
            [thisMonthRecordings setObject:duration forKey:recordingData.bundleID];
        }
        [duration addSeconds:recordingData.duration];
    }
    self.recordingBundleIDs = [thisMonthRecordings keysSortedByValueUsingComparator:^NSComparisonResult(ATTimeUnit *  _Nonnull obj1, ATTimeUnit *  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    return thisMonthRecordings;
}

#pragma mark - this year's datasource
- (void)changeDataSourceToThisYearRecordings {
    self.recordingDataValues = [self thisYearRecordingsForBundleID:ATTotalTime].copy;
    self.recordingDurations = [self thisYearRecordings].copy;
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

- (NSDictionary<NSString *, ATTimeUnit *> *)thisYearRecordings {
    NSMutableDictionary<NSString *, ATTimeUnit *> *thisYearRecordings = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
    NSDate *now = [NSDate date];
    NSArray<AIRecordingData *> *recordingDatas = [self.dataModel recordingDatasForYear:now];
    for (AIRecordingData *recordingData in recordingDatas) {
        if ([recordingData.bundleID isEqualToString:ATTotalTime]) {
            continue;
        }
        ATTimeUnit *duration = [thisYearRecordings objectForKey:recordingData.bundleID];
        if (!duration) {
            duration = [[ATTimeUnit alloc] init];
            [thisYearRecordings setObject:duration forKey:recordingData.bundleID];
        }
        [duration addSeconds:recordingData.duration];
    }
    self.recordingBundleIDs = [thisYearRecordings keysSortedByValueUsingComparator:^NSComparisonResult(ATTimeUnit *  _Nonnull obj1, ATTimeUnit *  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
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
            [self.tableView reloadData];
            break;
            
        case 1:
            _currentDisplayMode = ATCurrentModeDisplayWeek;
            [self changeDataSourceToThisWeekRecordings];
            [self.barChartView reloadData];
            [self.tableView reloadData];
            break;
            
        case 2:
            _currentDisplayMode = ATCurrentModeDisplayMonth;
            [self changeDataSourceToThisMonthRecordings];
            [self.barChartView reloadData];
            [self.tableView reloadData];
            break;
            
        case 3:
            _currentDisplayMode = ATCurrentModeDisplayYear;
            [self changeDataSourceToThisYearRecordings];
            [self.barChartView reloadData];
            [self.tableView reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - conform to <ATBarChartViewDelegate> and <ATBarChartViewDataSource>
- (nonnull NSColor *)barChartView:(nonnull ATBarChartView *)barChartView colorForBarAtIndex:(NSUInteger)index {
    return [NSColor textColor];
}

- (float)barChartView:(nonnull ATBarChartView *)barChartView heightForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataValues) {
        ATTimeUnit *duration = self.recordingDataValues[index];
        return duration.floatValue;
    }
    return 0.0;
}

- (ATTimeUnit *)barChartView:(ATBarChartView *)barChartView timeUnitForBarAtIndex:(NSUInteger)index {
    if (self.recordingDataValues) {
        return self.recordingDataValues[index];
    }
    return [[ATTimeUnit alloc] init];
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

#pragma mark - conform to <NSTableViewDelegate> and <NSTableViewDataSource>
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.recordingDurations) {
        return self.recordingDurations.count;
    }
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *cellIdentifier;
    NSString *cellText;
    if (tableColumn == tableView.tableColumns[0]) {
        cellIdentifier = @"ATApplicationCellIdentifier";
        cellText = self.recordingBundleIDs[row];
    } else if (tableColumn == tableView.tableColumns[1]) {
        cellIdentifier = @"ATDurationCellIdentifier";
        cellText = [[self.recordingDurations objectForKey:self.recordingBundleIDs[row]] description];
    } else {
        cellIdentifier = @"ATDisplayCellIdentifier";
    }
    NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:cellIdentifier owner:nil];
    if (cellText.length > 0) {
        tableCellView.textField.stringValue = cellText;
    }
    if (tableColumn == tableView.tableColumns[2]) {
        NSRect buttonRect = tableCellView.frame;
        NSButton *displayButton = [NSButton buttonWithTitle:NSLocalizedString(@"Show detail...", @"button description in table") target:nil action:@selector(displayCell:)];
//        [displayButton setObjectValue:self.recordingBundleIDs[row]];
//        displayButton.frame = buttonRect;
        [displayButton setTag:row];
        NSArray<NSView *> *subviews = tableCellView.subviews.copy;
        for (NSView *view in subviews) {
            [view removeFromSuperview];
        }
        [tableCellView addSubview:displayButton];
    }
    return tableCellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30.0;
}

#pragma mark - auxiliary method
- (NSDictionary<NSString *, ATTimeUnit *> *)sortedDictionaryOf:(NSMutableDictionary<NSString *, ATTimeUnit *> *)dictionary {
    NSArray<NSString *> *sortedKeys = [dictionary keysSortedByValueUsingComparator:^NSComparisonResult(ATTimeUnit *  _Nonnull obj1, ATTimeUnit *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableDictionary<NSString *, ATTimeUnit *> *sortedDictionary = [NSMutableDictionary<NSString *, ATTimeUnit *> dictionary];
    for (NSString *key in sortedKeys) {
        [sortedDictionary setObject:[dictionary objectForKey:key] forKey:key];
    }
    return sortedDictionary;
}

- (void)displayCell:(NSButton *)sender {
    int row = sender.tag;
    NSString *bundleID = self.recordingBundleIDs[row];
    ATAppTimeWindowController *appTimeWindowController;
    for (ATAppTimeWindowController *tmp in self.appTimeWindowControllers) {
        if ([tmp.bundleID isEqualToString:bundleID]) {
            appTimeWindowController = tmp;
            break;
        }
    }
    if (appTimeWindowController) {
        [appTimeWindowController.window orderFront:nil];
        [appTimeWindowController.window makeKeyWindow];
    } else {
        appTimeWindowController = [[ATAppTimeWindowController alloc] initWithWindowNibName:@"ATAppTimeWindowController"];
        [appTimeWindowController initDataModel:self.dataModel andBundleID:bundleID];
        [self.appTimeWindowControllers addObject:appTimeWindowController];
        [appTimeWindowController.window center];
        [appTimeWindowController.window orderFront:nil];
        [appTimeWindowController.window makeKeyWindow];
    }
}

@end
