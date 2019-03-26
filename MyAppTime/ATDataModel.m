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
    NSTimeInterval _refreshInterval;
    NSTimeInterval _writeBackInterval;
}

- (instancetype)init {
    if (self = [super init]) {
        _sharedWorkspace = [NSWorkspace sharedWorkspace];
        _defaultManager = [NSFileManager defaultManager];
        self.timeRecordings = [NSMutableDictionary<NSString *, NSNumber *> dictionary];
        _refreshInterval = 1.0;
        _writeBackInterval = 10.0;
    }
    return self;
}

- (NSMutableArray<NSString *> *)bundleIDs {
    NSMutableArray<NSString *> *bundleIDs = [NSMutableArray<NSString *> array];
    
    NSMutableArray *windowDicts = (__bridge NSMutableArray *)CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    for (NSDictionary *windowDict in windowDicts) {
        NSString *windowLayer = (NSString *)[windowDict objectForKey:@"kCGWindowLayer"];
        if (!windowLayer.intValue) {
            NSString *pidString = (NSString *)[windowDict objectForKey:@"kCGWindowOwnerPID"];
            pid_t pid = pidString.intValue;
            NSRunningApplication *runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
            NSString *bundleID = runningApplication.bundleIdentifier;
            if (![bundleIDs containsObject:bundleID]) {
                [bundleIDs addObject:bundleID];
            }
        }
    }
    
    return bundleIDs;
}

- (void)addRecordingTimer {
    NSTimer *timer = [NSTimer timerWithTimeInterval:_refreshInterval target:self selector:@selector(refreshRecordings) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:_writeBackInterval target:self selector:@selector(writeBack) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void)refreshRecordings {
    NSMutableArray<NSString *> *bundleIDs = self.bundleIDs;
    for (NSString *bundleID in bundleIDs) {
        NSBundle *bundle = [NSBundle bundleWithURL:[_sharedWorkspace URLForApplicationWithBundleIdentifier:bundleID]];
        NSString *localizedName = bundle.localizedInfoDictionary[@"CFBundleDisplayName"];
        if (!localizedName) {
            localizedName = bundle.infoDictionary[@"CFBundleName"];
        }
        NSLog(@"%@", localizedName);
        NSNumber *duration = [self.timeRecordings objectForKey:bundleID];
        if (!duration) {
            duration = [NSNumber numberWithDouble:0.0];
        }
        duration = [NSNumber numberWithDouble:duration.doubleValue + _refreshInterval];
        [self.timeRecordings setObject:duration forKey:bundleID];
    }
    NSLog(@"%@", self.timeRecordings);
}

- (void)addWriteBackTimer {
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(writeBackTimerHandler) object:nil];
//    [thread start];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf writeBack];
    });
    dispatch_resume(timer);
}

- (void)writeBackTimerHandler {
    NSTimer *timer = [NSTimer timerWithTimeInterval:_writeBackInterval target:self selector:@selector(writeBack) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)writeBack {
    NSArray<NSString *> *bundleIDs = [self.bundleIDs copy];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [calendar startOfDayForDate:now];
    NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:today options:NSCalendarWrapComponents];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", today, tomorrow];
    request.predicate = predicate;
    NSArray<AIRecordingData *> *todayRecordings = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    for (NSString *bundleID in bundleIDs) {
        BOOL hasRecord = NO;
        for (AIRecordingData *recordingData in todayRecordings) {
            if ([recordingData.bundleID isEqualToString:bundleID]) {
                recordingData.date = now;
                recordingData.duration = [self.timeRecordings objectForKey:bundleID].doubleValue;
                hasRecord = YES;
                break;
            }
        }
        if (!hasRecord) {
            AIRecordingData *recordingData = [NSEntityDescription  insertNewObjectForEntityForName:@"AIRecordingData"  inManagedObjectContext:self.persistentContainer.viewContext];
            recordingData.bundleID = bundleID;
            recordingData.date = now;
            recordingData.duration = [self.timeRecordings objectForKey:bundleID].doubleValue;
        }
    }
    NSError *error;
    if (![self.persistentContainer.viewContext save:&error]) {
        NSLog(@"%@", error);
    }
}

@end
