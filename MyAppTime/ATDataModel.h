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
#import "ATTimeUnit.h"

#define ATTotalTime @"ATTotalTime"

NS_ASSUME_NONNULL_BEGIN

@interface ATDataModel : NSObject

@property NSPersistentContainer *persistentContainer;

@property (nonatomic, readonly) NSMutableArray<NSString *> *bundleIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *timeRecordings;
@property (nonatomic, readonly) NSArray<AIRecordingData *> *requiredRecordings;
@property (nonatomic) NSArray<NSString *> *ignoredBundleIDs;

@property (nonatomic, strong) dispatch_queue_t dataModelQueue;
@property (nonatomic, strong) dispatch_source_t refreshTimer;
@property (nonatomic, strong) dispatch_source_t writeTimer;

- (void)addTimer;
- (void)writeBack;
- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forDate:(NSDate *)date;
- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forWeek:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forMonth:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forYear:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasForDate:(NSDate *)date;
- (NSArray<AIRecordingData *> *)recordingDatasForWeek:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasForMonth:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasForYear:(NSDate *)today;
- (NSArray<AIRecordingData *> *)recordingDatasFrom:(NSDate *) startDate to:(NSDate *)endDate withBundleID:(nullable NSString *)bundleID;
- (void)removeRecordingDatas:(NSMutableArray<AIRecordingData *> *)recordingDatas;

@end

NS_ASSUME_NONNULL_END
