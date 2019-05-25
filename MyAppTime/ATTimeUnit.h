//
//  ATTimeUnit.h
//  MyAppTime
//
//  Created by Evian张 on 2019/5/23.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATTimeUnit : NSObject

@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) int second;

- (NSComparisonResult)compare:(ATTimeUnit *)other;
- (void)addSeconds:(int)second;
- (float)floatValue;
- (NSString *)description;
- (NSString *)shortDescription;

@end

NS_ASSUME_NONNULL_END
