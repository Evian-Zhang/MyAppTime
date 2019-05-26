//
//  ATStatusItemViewController.h
//  MyAppTime
//
//  Created by Evian张 on 2019/5/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ATBarChartView.h"
#import "ATDataModel.h"
#import "PrefixHeader.pch"

NS_ASSUME_NONNULL_BEGIN

@interface ATStatusItemViewController : NSViewController <ATBarChartViewDelegate, ATBarChartViewDataSource>

@property (nonatomic) ATDataModel *dataModel;
@property (nonatomic) NSMutableArray<ATTimeUnit *> *recordingDataValues;
@property (nonatomic) NSMutableArray<NSString *> *recordingDataNames;
@property (nonatomic) NSString *bundleID;

@property (nonatomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet ATBarChartView *barChartView;
@property (nonatomic) IBOutlet NSButton *showMoreButton;
@property (nonatomic) IBOutlet NSButton *preferencesButton;
@property (nonatomic) IBOutlet NSButton *quitButton;

- (void)initDataModel:(ATDataModel *)dataModel andBundleID:(NSString *)bundleID;

@end

NS_ASSUME_NONNULL_END
