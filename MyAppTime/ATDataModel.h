//
//  ATDataModel.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "AIRecordingData+CoreDataClass.h"
#import "AIRecordingData+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATDataModel : NSObject

@property NSPersistentContainer *persistentContainer;

@property (nonatomic, readonly) NSMutableArray<NSString *> *bundleIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *timeRecordings;

- (void)addRecordingTimer;
- (void)addWriteBackTimer;

@end

NS_ASSUME_NONNULL_END
