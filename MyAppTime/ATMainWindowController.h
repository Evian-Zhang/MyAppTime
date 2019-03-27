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

@interface ATMainWindowController : NSWindowController

@property (nonatomic) ATDataModel *dataModel;

@end

NS_ASSUME_NONNULL_END
