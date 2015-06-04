//
//  SCFetchedResultsTableViewController.m
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCFetchedResultsTableViewController.h"
#import "SCAppDelegate.h"

@interface SCFetchedResultsTableViewController ()

@end

@implementation SCFetchedResultsTableViewController

#pragma mark Property Instantiation

- (NSManagedObjectContext *) managedObjectContext {
    static NSManagedObjectContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SCAppDelegate *appDelegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
        context = [appDelegate managedObjectContext];
    });
    return context;
}

#pragma mark ViewDidLoad

- (void)viewDidLoad
{
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Error performing fetch in %@ error %@, %@", NSStringFromClass([self class]), error, [error userInfo]);
		exit(-1);
	}
    
    [super viewDidLoad];
}

#pragma mark NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end