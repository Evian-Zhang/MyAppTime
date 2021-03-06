//
//  AppDelegate.m
//  MyAppTime
//
//  Created by Evian张 on 2019/3/25.
//  Copyright © 2019 Evian张. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate {
    NSFileManager *_defaultManager;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.dataModel = [[ATDataModel alloc] init];
    self.dataModel.persistentContainer = self.persistentContainer;
    
    _defaultManager = [NSFileManager defaultManager];
    
    [self handleUserDefaults];
    
    [self.dataModel addTimer];
    
    [NSProcessInfo.processInfo disableSuddenTermination];
    
    self.preferencesItem.target = self;
    self.preferencesItem.action = @selector(showPreferencesWindow);
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    NSImage *statusItemImage = [NSImage imageNamed:@"statusItemImage"];
    statusItemImage.size = NSMakeSize(18.0, 18.0);
    statusItemImage.template = YES;
    self.statusItem.button.image = statusItemImage;
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(showPopover);
    
    self.hasMainWindow = NO;
    self.hasPreferencesWindow = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusItemShowMore) name:@"ATStatusItemShowMore" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusItemPreferences) name:@"ATStatusItemPreferences" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusItemQuit) name:@"ATStatusItemQuit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMainWindowClose) name:@"ATMainWindowClose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePreferencesWindowClose) name:@"ATPreferencesWindowClose" object:nil];
}


//- (void)applicationWillTerminate:(NSNotification *)aNotification {
//    [self.dataModel writeBack];
//}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWriteBack) name:@"ATWriteBackFinished" object:nil];
    [self.dataModel writeBack];
    return NSTerminateLater;
}

- (void)handleWriteBack {
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}

- (void)handleUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray<NSString *> *initialIgnoredBundleIDs = @[@"com.apple.Stickies", @"com.zhang.evian.MyAppTime"];
    
    NSDictionary<NSString *, id> *registrationDictionary = @{@"wantsStartAtLogin":@YES, @"ignoredBundleIDs":initialIgnoredBundleIDs};
    [userDefaults registerDefaults:registrationDictionary];
    [userDefaults synchronize];
    
    BOOL wantsStartAtLogin = [userDefaults boolForKey:@"wantsStartAtLogin"];
    NSString *launchAgentsPath = @"~/Library/LaunchAgents/".stringByExpandingTildeInPath;
    NSString *launchdPlistPath = [launchAgentsPath stringByAppendingString:@"/com.zhang.evian.MyAppTimeLauncher.plist"];
    BOOL hasPlist = [_defaultManager fileExistsAtPath:launchdPlistPath];
    if (wantsStartAtLogin) {
        if (!hasPlist) {
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"com.zhang.evian.MyAppTimeLauncher" ofType:@"plist"];
            NSError *copyError;
            [_defaultManager copyItemAtPath:plistPath toPath:launchdPlistPath error:&copyError];
            if (copyError) {
                NSLog(@"%@", copyError);
            }
        }
    } else {
        if (hasPlist) {
            NSError *removeError;
            [_defaultManager removeItemAtPath:launchdPlistPath error:&removeError];
            if (removeError) {
                NSLog(@"%@", removeError);
            }
        }
    }
    
    self.dataModel.ignoredBundleIDs = [userDefaults arrayForKey:@"ignoredBundleIDs"];
}

- (void)showPreferencesWindow {
    if (!self.hasPreferencesWindow) {
        self.preferencesWindowController = [[ATPreferencesWindowController alloc] initWithWindowNibName:@"ATPreferencesWindowController"];
        self.preferencesWindowController.dataModel = self.dataModel;
    }
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:nil];
    [self.popover close];
    self.hasPreferencesWindow = YES;
}

- (void)showPopover {
    self.popover = [[NSPopover alloc] init];
    self.popover.behavior = NSPopoverBehaviorTransient;
    self.statusItemViewController = [[ATStatusItemViewController alloc] initWithNibName:@"ATStatusItemViewController" bundle:nil];
    [self.statusItemViewController initDataModel:self.dataModel andBundleID:ATTotalTime];
    self.popover.contentViewController = self.statusItemViewController;
    [NSApp activateIgnoringOtherApps:YES];
    [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMaxY];
}

- (void)handleStatusItemShowMore {
    if (!self.hasMainWindow) {
        self.mainWindowController = [[ATMainWindowController alloc] initWithWindowNibName:@"ATMainWindowController"];
        self.mainWindowController.dataModel = self.dataModel;
    }
    [NSApp activateIgnoringOtherApps:YES];
    [self.mainWindowController showWindow:nil];
    [self.popover close];
    self.hasMainWindow = YES;
}

- (void)handleStatusItemPreferences {
    [self showPreferencesWindow];
}

- (void)handleStatusItemQuit {
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)handleMainWindowClose {
    self.hasMainWindow = NO;
}

- (void)handlePreferencesWindowClose {
    self.hasPreferencesWindow = NO;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MyAppTime"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        // Customize this code block to include application-specific recovery steps.              
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return self.persistentContainer.viewContext.undoManager;
}

//- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
//    // Save changes in the application's managed object context before the application terminates.
//    NSManagedObjectContext *context = self.persistentContainer.viewContext;
//
//    if (![context commitEditing]) {
//        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
//        return NSTerminateCancel;
//    }
//
//    if (!context.hasChanges) {
//        return NSTerminateNow;
//    }
//
//    NSError *error = nil;
//    if (![context save:&error]) {
//
//        // Customize this code block to include application-specific recovery steps.
//        BOOL result = [sender presentError:error];
//        if (result) {
//            return NSTerminateCancel;
//        }
//
//        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
//        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
//        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
//        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert setMessageText:question];
//        [alert setInformativeText:info];
//        [alert addButtonWithTitle:quitButton];
//        [alert addButtonWithTitle:cancelButton];
//
//        NSInteger answer = [alert runModal];
//
//        if (answer == NSAlertSecondButtonReturn) {
//            return NSTerminateCancel;
//        }
//    }
//
//    return NSTerminateNow;
//}

@end
