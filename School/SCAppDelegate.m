//
//  SCAppDelegate.m
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCAppDelegate.h"
#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>
#import "Mixpanel.h"

#import "HTMLNode.h"
#import "HTMLParser.h"

static NSString *const SCMixpanelToken = @"6aa7979497eb8ff56083c6c0348bd5a0";

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"f276ae9e66671a920afb09c425e5cd1d324c60eb"];
    [Mixpanel sharedInstanceWithToken:SCMixpanelToken];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"SCFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"SCFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[Mixpanel sharedInstance] track:@"First Launch"];
    }
    return YES;
}

#pragma mark Core Data

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"database.sqlite"];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{
                                                                                                                                NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                                                                                                                NSInferMappingModelAutomaticallyOption : @(YES)
                                                                                                                                } error:&error]) {
            NSLog(@"Error creating persistent store coordinator %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSNotification *notif = [[NSNotification alloc] initWithName:SCUpdateNextLessonNotificationKey object:notification userInfo:[notification userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

@end
