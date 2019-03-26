//
//  ATMainWindowController.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/26.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "ATMainWindowController.h"

@interface ATMainWindowController ()

@end

@implementation ATMainWindowController

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.dataModel = [[ATDataModel alloc] init];
        [self.dataModel addTimer];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
