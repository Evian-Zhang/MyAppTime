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

@implementation ATMainWindowController

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.recordingDataValues = [NSMutableArray array];
        self.recordingDataNames = [NSMutableArray array];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self changeDataSourceToTodayRecordings];
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)changeDataSourceToTodayRecordings {
    self.recordingDataValues = [self todayRecordingsForBundleID:ATTotalTime].copy;
    for (int i = 0; i < 24; i++) {
        [self.recordingDataNames insertObject:[NSString stringWithFormat:@"%d", i + 1] atIndex:i];
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
