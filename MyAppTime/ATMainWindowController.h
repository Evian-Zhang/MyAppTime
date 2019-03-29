//
//  ATMainWindowController.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/26.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ATDataModel.h"
#import "ATBarChartView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATMainWindowController : NSWindowController <ATBarChartViewDelegate, ATBarChartViewDataSource>

@property (nonatomic) IBOutlet ATBarChartView *barChartView;
@property (nonatomic) ATDataModel *dataModel;
@property (nonatomic) NSMutableArray *recordingDataValues;
@property (nonatomic) NSMutableArray *recordingDataNames;

@end

NS_ASSUME_NONNULL_END
