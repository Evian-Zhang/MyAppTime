//
//  ATDataModel.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATDataModel.h"

@implementation ATDataModel {
    
}

@synthesize visibleApplications = _visibleApplications;

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSMutableArray<NSRunningApplication *> *)visibleApplications {
    NSMutableArray<NSRunningApplication *> *visibleApplications = [NSMutableArray<NSRunningApplication *> array];
    NSMutableArray<NSString *> *bundleIDs = [NSMutableArray<NSString *> array];
    
    NSMutableArray *windows = (__bridge NSMutableArray *)CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    for (NSDictionary *window in windows) {
        NSNumber *windowLayer = [window objectForKey:@"kCGWindowLayer"];
        if (!windowLayer.intValue) {
            NSString *pidString = [window objectForKey:@"kCGWindowOwnerPID"];
            pid_t pid = pidString.intValue;
            NSRunningApplication *runningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
            NSString *bundleID = runningApplication.bundleIdentifier;
            if (![bundleIDs containsObject:bundleID]) {
                [bundleIDs addObject:bundleID];
                [visibleApplications addObject:runningApplication];
            }
        }
    }
    
    return visibleApplications;
}

@end
