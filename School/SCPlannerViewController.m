//
//  SCPlannerViewController.m
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCPlannerViewController.h"
#import "SCDayViewController.h"
#import "Lesson.h"
#import "SCAppDelegate.h"
#import "Subject.h"
#import "Teacher.h"

@interface SCPlannerViewController ()

@property (nonatomic, strong) NSArray *daysOfWeek;
@property (nonatomic, strong) NSString *selectedDay;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation SCPlannerViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setDaysOfWeek:@[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday"]];
    }
    return self;
}


- (NSManagedObjectContext *) managedObjectContext {
    return [(SCAppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void) viewDidLoad {
    [self.navigationItem setTitle:@"Lesson Plan"];
    [[NSNotificationCenter defaultCenter] addObserverForName:SCUpdateNextLessonNotificationKey object:self queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [self updateNextLesson];
       });
    }];
    [self scheduleNotifications];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [self updateNextLesson];
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationItem setPrompt:nil];
}

- (void) scheduleNotifications {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SCScheduledNotificationsKey] == NO) {
        NSArray *times = @[@"09:15 am", @"09:45 am", @"10:20 am", @"11:15 am", @"11:50 am", @"12:25 pm", @"02:15 pm", @"02:50 pm", @"03:25 pm", @"04:01 pm"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        
        [times enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDate *fireDate = [dateFormatter dateFromString:times[idx]];
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            [notif setFireDate:fireDate];
            [notif setTimeZone:[NSTimeZone defaultTimeZone]];
            [notif setRepeatInterval:NSDayCalendarUnit];
            [notif setUserInfo:@{@"time" : times[idx]}];
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SCScheduledNotificationsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSInteger) nextPeriod {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    if (hour < 9 || (hour == 9 && minute <= 10)) {
        return 1;
    }
    else if (hour == 9 && minute < 45) {
        return 2;
    }
    else if (hour <= 10 && minute < 20) {
        return 3;
    }
    else if (hour <= 11 && minute < 15) {
        return 4;
    }
    else if (hour <= 11 && minute < 50) {
        return 5;
    }
    else if (hour <= 12 && minute < 25) {
        return 6;
    }
    else if (hour <= 14 && minute < 15) {
        return 7;
    }
    else if (hour <= 14 && minute < 50) {
        return 8;
    }
    else if (hour <= 15 && minute < 25) {
        return 9;
    }
    else {
        return 1;
    }
}

- (Lesson *) nextLesson {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setFirstWeekday:2];
    NSDate *now = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit fromDate:now];
    NSInteger dayOfWeek = [calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:now];
    NSInteger hour = [dateComponents hour];
    NSInteger nextPeriod = [self nextPeriod];
    
    if (hour >= 16 || hour <= 9) {
        dayOfWeek += 1;
        if (dayOfWeek == 6 || dayOfWeek == 7) {
            dayOfWeek = 1;
        }
        nextPeriod = 1;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lesson"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"day == %@ AND period == %@", self.daysOfWeek[dayOfWeek - 1], @(nextPeriod)]];
    NSError *error;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [matches firstObject];
}

- (NSString *) periodNumberToStartDate:(NSInteger) period {
    NSArray *periodDates = @[@"9:10", @"9:45", @"10:20", @"11:15", @"11:50", @"12:25", @"2:15", @"2:50", @"3:25"];
    return periodDates[period - 1];
}

- (void) updateNextLesson {
    Lesson *nextLesson = [self nextLesson];
    [self.navigationItem setPrompt:[NSString stringWithFormat:@"Your next lesson is %@ at %@ in %@", nextLesson.subject.name, [self periodNumberToStartDate:[self nextPeriod]], nextLesson.classroom]];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.daysOfWeek count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:self.daysOfWeek[indexPath.row]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedDay:self.daysOfWeek[indexPath.row]];
    [self performSegueWithIdentifier:@"push_day" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SCDayViewController *destination = [segue destinationViewController];
    [destination setDay:self.selectedDay];
}

@end