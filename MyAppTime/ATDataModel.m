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
}

@synthesize bundleIDs = _bundleIDs;
@synthesize timeRecordings = _timeRecordings;

- (instancetype)init {
    if (self = [super init]) {
        _sharedWorkspace = [NSWorkspace sharedWorkspace];
        _defaultManager = [NSFileManager defaultManager];
        self.timeRecordings = [NSMutableDictionary<NSString *, NSNumber *> dictionary];
        _refreshInterval = 1.0;
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

- (void)addTimer {
    NSTimer *timer = [NSTimer timerWithTimeInterval:_refreshInterval target:self selector:@selector(refreshRecordings) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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

@end
