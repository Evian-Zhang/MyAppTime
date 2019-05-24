//
//  ATAppTimeWindowController.h
//  MyAppTime
//
//  Created by Evian张 on 2019/5/24.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ATBarChartView.h"
#import "ATDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAppTimeWindowController : NSWindowController <ATBarChartViewDelegate, ATBarChartViewDataSource, NSWindowDelegate>

typedef enum ATCurrentDisplayMode {
    ATCurrentModeDisplayDay,
    ATCurrentModeDisplayWeek,
    ATCurrentModeDisplayMonth,
    ATCurrentModeDisplayYear
} ATCurrentDisplayMode;

@property (nonatomic) ATDataModel *dataModel;
@property (nonatomic) NSMutableArray<ATTimeUnit *> *recordingDataValues;
@property (nonatomic) NSMutableArray<NSString *> *recordingDataNames;
@property (nonatomic) NSString *bundleID;

@property (nonatomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet ATBarChartView *barChartView;

- (void)initDataModel:(ATDataModel *)dataModel andBundleID:(NSString *)bundleID;

@end

NS_ASSUME_NONNULL_END
