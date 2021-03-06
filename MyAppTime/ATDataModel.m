//
//  ATDataModel.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATDataModel.h"

@implementation ATDataModel {
    NSWorkspace *_sharedWorkspace;
    NSFileManager *_defaultManager;
    NSNotificationCenter *_defaultCenter;
    NSTimeInterval _refreshInterval;
    NSTimeInterval _writeBackInterval;
    BOOL _isWritingBack;
    BOOL _isRecording;
}

- (instancetype)init {
    if (self = [super init]) {
        _sharedWorkspace = [NSWorkspace sharedWorkspace];
        _defaultManager = [NSFileManager defaultManager];
        self.timeRecordings = [NSMutableDictionary<NSString *, NSNumber *> dictionary];
        _refreshInterval = 1.0;
        _writeBackInterval = 1800.0;
        _isWritingBack = NO;
        _isRecording = NO;
        _defaultCenter = [NSNotificationCenter defaultCenter];
        [_defaultCenter addObserver:self selector:@selector(handleCalendarDayChangeNotification) name:NSCalendarDayChangedNotification object:nil];
    }
    return self;
}

- (NSMutableArray<NSString *> *)bundleIDs {
    NSMutableArray<NSString *> *bundleIDs = [NSMutableArray<NSString *> array];
    
    NSMutableArray *windowDicts = (__bridge NSMutableArray *)CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    
    if (![bundleIDs containsObject:ATTotalTime]) {
        [bundleIDs addObject:ATTotalTime];
    }
    
    for (NSDictionary *windowDict in windowDicts) {
        NSString *windowLayer = (NSString *)[windowDict objectForKey:@"kCGWindowLayer"];
        if (!windowLayer.intValue) {
            NSString *pidString = (NSString *)[windowDict objectForKey:@"kCGWindowOwnerPID"];
            pid_t pid = pidString.intValue;
            NSRunningApplication *runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
            NSString *bundleID = runningApplication.bundleIdentifier;
            if (bundleID) {
                if (![bundleIDs containsObject:bundleID]) {
                    [bundleIDs addObject:bundleID];
                }
            }
        }
    }
    
    return bundleIDs;
}

- (void)addTimer {
    self.dataModelQueue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    self.refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dataModelQueue);
    dispatch_source_set_timer(self.refreshTimer, dispatch_walltime(NULL, 0), _refreshInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.refreshTimer, ^{
        [self refreshRecordings];
    });
    
    self.writeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dataModelQueue);
    dispatch_source_set_timer(self.writeTimer, dispatch_walltime(NULL, 0), _writeBackInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.writeTimer, ^{
        [self writeBack];
    });
    
    dispatch_resume(self.refreshTimer);
    dispatch_resume(self.writeTimer);
}

- (void)refreshRecordings {
    if (_isRecording) {
        return;
    }
    _isRecording = YES;
    NSMutableArray<NSString *> *bundleIDs = self.bundleIDs;
    if (![bundleIDs containsObject:ATTotalTime]) {
        [bundleIDs addObject:ATTotalTime];
    }
    for (NSString *bundleID in bundleIDs) {
        NSNumber *duration = [self.timeRecordings objectForKey:bundleID];
        if (!duration) {
            duration = [NSNumber numberWithDouble:0.0];
        }
        duration = [NSNumber numberWithDouble:duration.doubleValue + _refreshInterval];
        [self.timeRecordings setObject:duration forKey:bundleID];
    }
    _isRecording = NO;
}

- (void)writeBack {
    if (_isWritingBack) {
        return;
    }
    dispatch_suspend(self.refreshTimer);
    _isWritingBack = YES;
    NSArray<NSString *> *bundleIDs = [self.bundleIDs copy];
    NSDate *now = [NSDate date];
    for (NSString *bundleID in bundleIDs) {
        if ([self.ignoredBundleIDs containsObject:bundleID]) {
            continue;
        }
        AIRecordingData *recordingData = [NSEntityDescription insertNewObjectForEntityForName:@"AIRecordingData" inManagedObjectContext:self.persistentContainer.viewContext];
        recordingData.bundleID = bundleID;
        recordingData.date = now;
        recordingData.duration = [self.timeRecordings objectForKey:bundleID].doubleValue;
    }
    NSError *error;
    if (![self.persistentContainer.viewContext save:&error]) {
        NSLog(@"%@", error);
    }
    [self.bundleIDs removeAllObjects];
    [self.timeRecordings removeAllObjects];
    _isWritingBack = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ATWriteBackFinished" object:nil];
    dispatch_resume(self.refreshTimer);
}

- (void)handleCalendarDayChangeNotification {
    dispatch_suspend(self.dataModelQueue);
    [self.bundleIDs removeAllObjects];
    [self.timeRecordings removeAllObjects];
    dispatch_resume(self.dataModelQueue);
}

- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [calendar startOfDayForDate:date];
    NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:today options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND bundleID == %@", today, tomorrow, bundleID];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *todayRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [todayRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [calendar startOfDayForDate:date];
    NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:today options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", today, tomorrow];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *todayRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [todayRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forWeek:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSDate *weekStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&weekStart interval:nil forDate:today];
    NSDate *weekEnd = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:weekStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND bundleID == %@", weekStart, weekEnd, bundleID];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisWeekRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisWeekRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForWeek:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    NSDate *weekStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&weekStart interval:nil forDate:today];
    NSDate *weekEnd = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:weekStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", weekStart, weekEnd];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisWeekRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisWeekRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forMonth:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *monthStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&monthStart interval:nil forDate:today];
    NSDate *monthEnd = [calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:monthStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND bundleID == %@", monthStart, monthEnd, bundleID];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisMonthRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisMonthRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForMonth:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *monthStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&monthStart interval:nil forDate:today];
    NSDate *monthEnd = [calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:monthStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", monthStart, monthEnd];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisMonthRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisMonthRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForBundleID:(NSString *)bundleID forYear:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *yearStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&yearStart interval:nil forDate:today];
    NSDate *yearEnd = [calendar dateByAddingUnit:NSCalendarUnitYear value:1 toDate:yearStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND bundleID == %@", yearStart, yearEnd, bundleID];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisYearRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisYearRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasForYear:(NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *yearStart = [NSDate date];
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&yearStart interval:nil forDate:today];
    NSDate *yearEnd = [calendar dateByAddingUnit:NSCalendarUnitYear value:1 toDate:yearStart options:NSCalendarSearchBackwards];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", yearStart, yearEnd];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *thisYearRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    return [thisYearRecordings copy];
}

- (NSArray<AIRecordingData *> *)recordingDatasFrom:(NSDate *)startDate to:(NSDate *)endDate withBundleID:(nullable NSString *)bundleID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate;
    if (bundleID) {
        predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND bundleID == %@", startDate, endDate, bundleID];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", startDate, endDate];
    }
    request.predicate = predicate;
    NSArray<AIRecordingData *> *requestedRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    if (requestedRecordings) {
        return requestedRecordings;
    } else {
        return [NSArray<AIRecordingData *> array];
    }
}

- (void)removeRecordingDatas:(NSMutableArray<AIRecordingData *> *)recordingDatas {
    for (AIRecordingData *recordingData in recordingDatas) {
        [self.persistentContainer.viewContext deleteObject:recordingData];
    }
    NSError *error;
    if (![self.persistentContainer.viewContext save:&error]) {
        NSLog(@"%@", error);
    }
}

@end
