//
//  ATBarChartViewDataSource.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/28.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATTimeUnit.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATBarChartViewDataSource <NSObject>

- (NSUInteger)numberOfBarsInBarChartView:(ATBarChartView *)barChartView;
- (NSColor *)barChartView:(ATBarChartView *)barChartView colorForBarAtIndex:(NSUInteger)index;
- (NSString *)barChartView:(ATBarChartView *)barChartView titleForBarAtIndex:(NSUInteger)index;
- (float)barChartView:(ATBarChartView *)barChartView heightForBarAtIndex:(NSUInteger)index;
- (ATTimeUnit *)barChartView:(ATBarChartView *)barChartView timeUnitForBarAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
