//
//  SCAppDelegate.h
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

@interface SCAppDelegate : UIResponder <UIApplicationDelegate>

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@end
