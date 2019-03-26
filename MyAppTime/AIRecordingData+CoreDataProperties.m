//
//  AIRecordingData+CoreDataProperties.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/26.
//  Copyright © 2019 Evian张. All rights reserved.
//
//

#import "AIRecordingData+CoreDataProperties.h"

@implementation AIRecordingData (CoreDataProperties)

+ (NSFetchRequest<AIRecordingData *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AIRecordingData"];
}

@dynamic date;
@dynamic bundleID;
@dynamic duration;

@end
