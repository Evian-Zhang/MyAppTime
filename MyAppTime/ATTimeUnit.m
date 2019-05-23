//
//  ATTimeUnit.m
//  MyAppTime
//
//  Created by Evian张 on 2019/5/23.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATTimeUnit.h"

@implementation ATTimeUnit

- (instancetype)init {
    if (self = [super init]) {
        self.hour = 0;
        self.minute = 0;
        self.second = 0;
        return self;
    }
    return nil;
}

- (NSComparisonResult)compare:(ATTimeUnit *)other {
    if (self.hour < other.hour) {
        return NSOrderedAscending;
    } else if (self.hour > other.hour) {
        return NSOrderedDescending;
    }
    
    if (self.minute < other.minute) {
        return NSOrderedAscending;
    } else if (self.minute > other.minute) {
        return NSOrderedDescending;
    }
    
    if (self.second < other.second) {
        return NSOrderedAscending;
    } else if (self.minute > other.minute) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

- (void)addSeconds:(int)second {
    self.second += second;
    if (self.second > 60) {
        self.minute += self.second / 60;
        self.second %= 60;
    }
    
    if (self.minute > 60) {
        self.hour += self.minute / 60;
        self.minute %= 60;
    }
}

- (float)floatValue {
    return self.hour + (float)self.minute / 60 + (float)self.second / 3600;
}

@end
