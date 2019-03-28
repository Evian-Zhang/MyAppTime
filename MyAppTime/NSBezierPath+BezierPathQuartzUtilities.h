//
//  NSBezierPath+BezierPathQuartzUtilities.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/28.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (BezierPathQuartzUtilities)

- (CGPathRef)quartzPath;

@end

NS_ASSUME_NONNULL_END
