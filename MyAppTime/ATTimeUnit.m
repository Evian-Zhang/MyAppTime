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
    } else if (self.second > other.second) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

- (void)addSeconds:(int)second {
    self.second += second;
    if (self.second >= 60) {
        self.minute += self.second / 60;
        self.second %= 60;
    }
    
    if (self.minute >= 60) {
        self.hour += self.minute / 60;
        self.minute %= 60;
    }
}

- (float)floatValue {
    return self.hour + (float)self.minute / 60 + (float)self.second / 3600;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    if (self.hour > 0) {
        [description appendFormat:@"%d小时", self.hour];
        if (self.minute > 0) {
            [description appendFormat:@"%d分钟", self.minute];
            if (self.second > 0) {
                [description appendFormat:@"%d秒", self.second];
            }
        } else {
            if (self.second > 0) {
                [description appendFormat:@"0分钟%d秒", self.second];
            }
        }
    } else {
        if (self.minute > 0) {
            [description appendFormat:@"%d分钟", self.minute];
            if (self.second > 0) {
                [description appendFormat:@"%d秒", self.second];
            }
        } else {
            if (self.second > 0) {
                [description appendFormat:@"%d秒", self.second];
            } else {
                [description appendString:@"0秒"];
            }
        }
    }
    return description;
}

@end
