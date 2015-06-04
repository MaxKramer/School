//
//  SCHomeworkViewController.m
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCHomeworkViewController.h"
#import "SCHomeworkInfoViewController.h"
#import "Homework.h"
#import "NSString+Drawing.h"
#import "SCDateFormatter.h"

@interface SCHomeworkViewController () 

@property (nonatomic, strong) Homework *selectedHomework;

@end

@implementation SCHomeworkViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark Property Instatiation

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Homework" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subject.name == %@", self.subject.name];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES]]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];
    }
    return _fetchedResultsController;
    
}

#pragma mark ViewDidLoad

- (void)viewDidLoad
{
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ Homework", self.subject.name]];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [super viewDidLoad];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing == YES) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddMoreInfo:)] animated:YES];
    }
    else {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
}

#pragma mark Show Add More Info Screen

- (void) showAddMoreInfo:(id) sender
{
    [self performSegueWithIdentifier:@"homework_info" sender:sender];
}

#pragma mark Insert Homework

- (void) addHomework:(Homework *) homework {
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error adding homework: %@", error.description);
    }
}

#pragma mark Difference in days between X and Now

- (NSInteger) dayDifferenceBetweenNow:(NSDate *) then {
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:now];
    NSDateComponents *thenComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:then];
    return [thenComponents day] - [nowComponents day];
}
     
#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Homework *home = [self.fetchedResultsController objectAtIndexPath:indexPath];
    float height = [[home detail] heightWithFont:[UIFont systemFontOfSize:16.0f] maxSize:CGSizeMake(265, CGFLOAT_MAX) andLinebreakMode:NSLineBreakByWordWrapping];
    return height + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Homework *home = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:home.detail];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0f]];

    NSInteger setDifference = [self dayDifferenceBetweenNow:home.setDate];
    NSMutableString *setText = [NSMutableString string];
    
    if (setDifference < -1) {
        [setText appendFormat:@"%d days ago", setDifference];
    }
    else if (setDifference == -1) {
        [setText appendString:@"yesterday"];
    }
    else if (setDifference == 0) {
        [setText appendString:@"today"];
    }
    else if (setDifference == 1) {
        [setText appendString:@"tomorrow"];
    }
    else if (setDifference > 1) {
        [setText appendFormat:@"in %d days", setDifference];
    }
    
    NSInteger dueDifference = [self dayDifferenceBetweenNow:home.dueDate];
    NSMutableString *detailText = [NSMutableString stringWithFormat:@"Set %@ and ", setText];
    
    if (dueDifference < -1) {
        [detailText appendFormat:@"was due in %d days ago", dueDifference];
    }
    else if (dueDifference == -1) {
        [detailText appendString:@"was due in yesterday"];
    }
    else if (dueDifference == 0) {
        [detailText appendString:@"is due in today"];
    }
    else if (dueDifference == 1) {
        [detailText appendString:@"is due in tomorrow"];
    }
    else {
        [detailText appendFormat:@"is due in %d days", dueDifference];
    }
    
    [cell.detailTextLabel setText:detailText];
    
    if (home.completed.boolValue) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell.contentView setAlpha:0.6f];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.contentView setAlpha:1.0f];
    }
    
    [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Homework *homework = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.isEditing) {
        [self setSelectedHomework:homework];
        [self showAddMoreInfo:self];
    }
    else {
        [self setHomework:homework asCompleted:!homework.completed.boolValue];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) setHomework:(Homework *) home asCompleted:(BOOL) complete {
    home.completed = @(complete);
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error updating homework state: %@", error.description);
    }	
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Homework *sub = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:sub];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Commit editing style error: %@", error.description);
        }
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark Storyboarding

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SCHomeworkInfoViewController *destination = [(UINavigationController *) [segue destinationViewController] viewControllers][0];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self setSelectedHomework:nil];
        [destination setFinishedEditingWithHomework:^(NSDate *setDate, NSDate *dueDate, NSString *detail) {
            Homework *home = [NSEntityDescription insertNewObjectForEntityForName:@"Homework" inManagedObjectContext:self.managedObjectContext];
            [home setSubject:self.subject];
            [home setDueDate:dueDate];
            [home setSetDate:setDate];
            [home setDetail:detail];
            [self addHomework:home];
        }];
    }
    else {
        [destination setExistingHomework:self.selectedHomework];
        [destination setFinishedEditingWithHomework:^(NSDate *setDate, NSDate *dueDate, NSString *detail) {
            [self.selectedHomework setSetDate:setDate];
            [self.selectedHomework setDueDate:dueDate];
            [self.selectedHomework setDetail:detail];
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error saving edited homework: %@ : %@", [self.selectedHomework description], [error localizedDescription]);
            }
        }];
    }
}

@end
