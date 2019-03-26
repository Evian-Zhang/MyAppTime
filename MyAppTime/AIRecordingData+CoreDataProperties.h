//
//  AIRecordingData+CoreDataProperties.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/26.
//  Copyright © 2019 Evian张. All rights reserved.
//
//

#import "AIRecordingData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AIRecordingData (CoreDataProperties)

+ (NSFetchRequest<AIRecordingData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *bundleID;
@property (nonatomic) double duration;

@end

NS_ASSUME_NONNULL_END
