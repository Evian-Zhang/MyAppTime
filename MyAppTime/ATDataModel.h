//
//  ATDataModel.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATDataModel : NSObject

@property (nonatomic, readonly) NSMutableArray<NSString *> *bundleIDs;

- (void)addTimer;

@end

NS_ASSUME_NONNULL_END
