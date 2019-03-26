//
//  AppDelegate.h
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

#import "ATMainWindowController.h"
#import "ATDataModel.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property ATMainWindowController *mainWindowController;
@property (nonatomic) ATDataModel *dataModel;

@end

