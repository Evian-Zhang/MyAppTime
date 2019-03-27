//
//  ATBarChartView.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/27.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "ATBarChartViewDelegate.h"
#import "ATBarChartViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATBarChartView : NSView

@property (nonatomic, weak) id<ATBarChartViewDelegate> delegate;
@property (nonatomic, weak) id<ATBarChartViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
