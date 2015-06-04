//
//  SCFetchedResultsTableViewController.h
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCFetchedResultsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
