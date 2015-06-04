//
//  SCDayViewController.m
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCDayViewController.h"
#import "Lesson.h"
#import "Teacher.h"
#import "Subject.h"

@interface SCDayViewController ()

@end

@implementation SCDayViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
  
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"day == %@", self.day]];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];
    }
    return _fetchedResultsController;
}

- (void) viewDidLoad {
    [self.navigationItem setTitle:self.day];
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeTop];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const reuseIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    Lesson *lesson = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Teacher *teacher = [lesson teacher];
    Subject *subject = [lesson subject];
    
    [cell.textLabel setText:subject.name];
    
    if ([[[lesson subject] name] isEqualToString:@"Free"] || (teacher.title == nil || [teacher.title isEqualToString:@""] || teacher.surname == nil || [teacher.surname isEqualToString:@""])) {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Period %d", lesson.period.integerValue]];
    }
    else {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Period %d with %@ %@ in %@", lesson.period.integerValue, teacher.title, teacher.surname, lesson.classroom]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
