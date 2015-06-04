//
//  SCDiaryViewController.m
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCDiaryViewController.h"
#import "SCAppDelegate.h"
#import "Subject.h"
#import "SCHomeworkViewController.h"
#import "Homework.h"
#import "TDBadgedCell.h"
#import "SVProgressHUD.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "Teacher.h"
#import "Lesson.h"
#import "Mixpanel.h"

static NSInteger const SCLoginAlertTag = 151;

@interface SCDiaryViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *homework, *dueHomeworkCount;
@property (nonatomic, strong) Subject *selectedSubject;

@end

@implementation SCDiaryViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark Property Instantiation

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];
    }
    return _fetchedResultsController;
}

#pragma mark ViewDidLoad

- (void) viewDidLoad
{
    [self.navigationItem setTitle:@"Subjects"];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goHome:)];
    [self.navigationItem setLeftBarButtonItem:back];
    
    self.dueHomeworkCount = [NSMutableDictionary dictionary];
    [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Subject *subj, NSUInteger idx, BOOL *stop) {
        [self updateCountDictionaryForSubject:subj];
    }];
    
    [super viewDidLoad];

    BOOL needsRemoval = [[NSUserDefaults standardUserDefaults] boolForKey:@"SCNeedsRemoval"];
    if (needsRemoval == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SCNeedsRemoval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.managedObjectContext deleteObject:obj];
            [self.managedObjectContext save:nil];
        }];
        [self displayLoginAlert];
    }
    else {
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [self displayLoginAlert];
        }
    }
}

- (void) goHome:(id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) displayLoginAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please login!" message:@"Please enter your UCS VLE login details." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    [alert setTag:SCLoginAlertTag];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alert show];
}

- (NSString *) userIDFromResponse:(NSString *) response {
    NSArray *possibleURLStrings = @[@"https://vle.ucs.org.uk/user/profile.php?id=", @"https://vle.ucs.org.uk/blog/index.php?userid=", @"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=welcome&userid=", @"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=attendance&userid=", @"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=timetable&userid=", @"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=gradebook&userid=", @"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=event&userid=",@"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/report.php?tab=achievement&userid="];
    __block NSString *uid;
    [possibleURLStrings enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
        NSRange rangeOfURL = [response rangeOfString:url];
        if (rangeOfURL.location != NSNotFound) {
            rangeOfURL.length += 6;
            if (response.length > rangeOfURL.location + rangeOfURL.length) {
                NSString *parts = [response substringWithRange:rangeOfURL];
                parts = [parts stringByReplacingOccurrencesOfString:url withString:@""];
                NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                NSMutableString *returns = [NSMutableString stringWithString:parts];
                for (int i = [returns length] - 1; i >= 0; i--) {
                    if (![cs characterIsMember:[returns characterAtIndex:i]]) {
                        [returns deleteCharactersInRange:NSMakeRange(i, 1)];
                    }
                }
                if (returns != nil && returns.length >= 3) {
                    uid = [returns copy];
                    *stop = YES;
                }
            }
        }
    }];
    return uid;
}

- (void) displayErrorAlertWithTitle:(NSString *) title {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:title];
    });
}

- (BOOL) userLoggedInFromResponse:(NSString *) response {
    return [response rangeOfString:@"You are logged in as"].location != NSNotFound;
}

- (void) loadTimetableAndLessonsForUsername:(NSString *) username andPassword:(NSString *) password {
    [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"Logging in, please wait." maskType:SVProgressHUDMaskTypeGradient];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://vle.ucs.org.uk/login/index.php"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"username=%@&password=%@", username, password] dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [self displayErrorAlertWithTitle:@"Please check your internet connection and try again!"];
            return;
        }
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![self userLoggedInFromResponse:responseString]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayErrorAlertWithTitle:@"Your username or password is incorrect, please try again"];
                [self performSelector:@selector(displayLoginAlert) withObject:nil afterDelay:4.0f];
            });
            return;
        }
        NSString *userID = [self userIDFromResponse:responseString];
        if (userID == nil) {
            [self displayErrorAlertWithTitle:@"Unable to find your user id, please try again. If it still doesn't work, tell Max!"];
            return;
        }
        [[Mixpanel sharedInstance] identify:userID];
        [[[Mixpanel sharedInstance] people] set:@{@"name" : username, @"$email" : [username stringByAppendingString:@"@ucs.org.uk"], @"username" : username, @"email" : [username stringByAppendingString:@"@ucs.org.uk"]}];
        [self requestAndInsertTimetableWithUserID:userID];
    }];
}

- (void) requestAndInsertTimetableWithUserID:(NSString *) userID {
    NSURLRequest *timetableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vle.ucs.org.uk/blocks/wa_mis_integration/reporting/timetable_printable.php?userid=%@&date=%d", userID, 1378684800]]];
    [NSURLConnection sendAsynchronousRequest:timetableRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [self displayErrorAlertWithTitle:@"Please check your internet connection and try again"];
            return;
        }
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *parsedTimetable = [self parseTimetable:responseString];
        [self insertTeachers:parsedTimetable[@"teachers"] andSubjects:parsedTimetable[@"subjects"]];
        [self generateAndInsertLessonsFromArray:parsedTimetable[@"timetable"]];
        [SVProgressHUD dismiss];
    }];
}

- (void) insertTeachers:(NSArray *) teachers andSubjects:(NSArray *) subjects {
    [subjects enumerateObjectsUsingBlock:^(NSString *subject, NSUInteger idx, BOOL *stop) {
        if (![self subjectExistsWithName:subject]) {
            [self addSubjectWithName:subject];
        }
    }];
    [teachers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self teacherExistsWithName:obj]) {
            [self addTeacherWithName:obj];
        }
    }];
}

- (void) generateAndInsertLessonsFromArray:(NSArray *) array {
    [array enumerateObjectsUsingBlock:^(NSArray *day, NSUInteger dayOfWeek, BOOL *stop) {
        [day enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:obj];
            [properties setObject:[self dayOfWeekFromNumber:dayOfWeek] forKey:@"day"];
            [self addLessonWithProperties:properties];
        }];
    }];
}

- (NSString *) dayOfWeekFromNumber:(NSInteger) number {
    NSArray *days = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday"];
    return days[number];
}

- (void) addLessonWithProperties:(NSDictionary *) properties {
    Lesson *lesson = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
    [lesson setClassroom:properties[@"room"]];
    [lesson setDay:properties[@"day"]];
    NSString *fullname = properties[@"teacher"];
    NSArray *components = [fullname componentsSeparatedByString:@" "];
    [lesson setTeacher:[self teacherWithSurname:[components lastObject] andTitle:components[0]]];
    [lesson setSubject:[self subjectWithName:properties[@"name"]]];
    [lesson setPeriod:[self periodNumberFromRange:properties[@"period"]]];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"unable to add lesson with properties: %@", properties);
    }
}

- (Subject *) subjectWithName:(NSString *) name {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Subject"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [results firstObject];

}

- (Teacher *) teacherWithSurname:(NSString *) surname andTitle:(NSString *) title {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Teacher"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"surname == %@ AND title == %@", surname, title]];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [results firstObject];
}

- (NSDictionary *) parseTimetable:(NSString *) timetableHTML {
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:timetableHTML error:&error];
    if (error) {
        NSLog(@"error => %@", error);
        return nil;
    }
    
    HTMLNode *body = [parser body];
    
    NSArray *lessons = [body findChildrenOfClass:@"lesson  "];
    NSMutableArray *days = [NSMutableArray arrayWithObjects:@[].mutableCopy, @[].mutableCopy, @[].mutableCopy, @[].mutableCopy, @[].mutableCopy, nil];
    NSMutableSet *teachers = [NSMutableSet set];
    NSMutableSet *subjects = [NSMutableSet set];
    
    __block NSInteger currentLeftPadding = 59;
    __block NSUInteger currentIndex = 0;
    __block NSUInteger numberOfLessons = 0;
    [lessons enumerateObjectsUsingBlock:^(HTMLNode *lesson, NSUInteger idx, BOOL *stop) {
        NSString *css = [lesson getAttributeNamed:@"style"];
        css = [css stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *attributes = [css componentsSeparatedByString:@";"];
        NSString *left = attributes[0];
        left = [left stringByReplacingOccurrencesOfString:@"left: " withString:@""];
        left = [left stringByReplacingOccurrencesOfString:@"px;" withString:@""];
        __block NSString *lessonName, *teacher, *room, *period;
        numberOfLessons++;
        [lesson.children enumerateObjectsUsingBlock:^(HTMLNode *lessonNode, NSUInteger idx, BOOL *stop) {
            if (lessonNode != nil) {
                if (idx == 0) {
                    NSString *name = [[lessonNode contents] lowercaseString];
                    NSArray *words = [name componentsSeparatedByString:@" "];
                    NSMutableString *normalisedName = [NSMutableString string];
                    [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
                        NSString *uppercaseWord = [word stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[NSString stringWithFormat:@"%c", [word characterAtIndex:0]] uppercaseString]];
                        [normalisedName appendString:uppercaseWord];
                        if (idx < (words.count - 1)) {
                            [normalisedName appendString:@" "];
                        }
                    }];
                    lessonName = [normalisedName copy];
                    if ([lessonName isEqualToString:@"Maths Statist.."]) {
                        lessonName = @"Maths Statistics";
                    }
                    else if ([lessonName isEqualToString:@"Business Stud.."]) {
                        lessonName = @"Business Studies";
                    }
                    [subjects addObject:lessonName];
                }
                else {
                    NSString *lessonBody = [lessonNode rawContents];
                    lessonBody = [lessonBody stringByReplacingOccurrencesOfString:@"<div class=\"lesson_body\">" withString:@""];
                    lessonBody = [lessonBody stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
                    NSArray *parts = [lessonBody componentsSeparatedByString:@"<br>"];
                    if (parts.count == 3) {
                        teacher = parts[0];
                        [teachers addObject:teacher];
                        room = [parts[1] stringByReplacingOccurrencesOfString:@"Room: " withString:@""];
                        period = parts[2];
                    }
                    else {
                        period = parts[1];
                    }
                }
            }
        }];
        NSInteger newLeft = [left integerValue];
        NSMutableDictionary *lessonDictionary = [NSMutableDictionary dictionary];
        if (teacher) {
            [lessonDictionary setObject:teacher forKey:@"teacher"];
        }
        if (room) {
            [lessonDictionary setObject:room forKey:@"room"];
        }
        if (period) {
            [lessonDictionary setObject:period forKey:@"period"];
        }
        if (lessonName) {
            [lessonDictionary setObject:lessonName forKey:@"name"];
        }
        if (newLeft != currentLeftPadding) {
            currentIndex += 1;
            currentLeftPadding = newLeft;
        }
        [days[currentIndex] addObject:lessonDictionary];
    }];
    NSMutableArray *paddedDays = [NSMutableArray array];
    [days enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [paddedDays addObject:[self lessonsByPaddingWithFrees:obj forDay:[self dayOfWeekFromNumber:idx]]];
    }];
    if (numberOfLessons < 45) {
        [subjects addObject:@"Free"];
    }
    return @{@"timetable" : paddedDays, @"teachers" : [teachers allObjects], @"subjects" : [subjects allObjects]};
}

- (NSArray *) lessonsByPaddingWithFrees:(NSArray *) lessons forDay:(NSString *) day {
    NSMutableArray *returns = [NSMutableArray arrayWithArray:lessons];
    __block NSNumber *lastPeriodNumber = @(0);
    [lessons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *currentPeriodNumber = [self periodNumberFromRange:obj[@"period"]];
        if (currentPeriodNumber.integerValue > (lastPeriodNumber.integerValue + 1)) {
            NSInteger difference = currentPeriodNumber.integerValue - (lastPeriodNumber.integerValue + 1);
            for (int i = 1; i <= difference; i++) {
                NSNumber *period = @(lastPeriodNumber.integerValue + i);
                [returns insertObject:[self paddingForRange:[self rangeFromPeriodNumber:period] withDay:day] atIndex:(period.integerValue - 1)];
            }
        }
        lastPeriodNumber = currentPeriodNumber;
    }];
    return [returns copy];
}

- (NSDictionary *) paddingForRange:(NSString *) range withDay:(NSString *) day {
    return @{@"period" : range, @"name" : @"Free", @"day" : day};
}

- (NSString *) rangeFromPeriodNumber:(NSNumber *) period {
     NSArray *ranges = @[@"09:10am - 09:45am", @"09:45am - 10:20am", @"10:20am - 10:55am", @"11:15am - 11:50am", @"11:50am - 12:25pm", @"12:25pm - 13:00pm", @"14:15pm - 14:50pm", @"14:50pm - 15:25pm", @"15:25pm - 16:00pm"];
    return ranges[period.integerValue - 1];
}

- (NSNumber *) periodNumberFromRange:(NSString *) range {
    NSArray *ranges = @[@"09:10am - 09:45am", @"09:45am - 10:20am", @"10:20am - 10:55am", @"11:15am - 11:50am", @"11:50am - 12:25pm", @"12:25pm - 13:00pm", @"14:15pm - 14:50pm", @"14:50pm - 15:25pm", @"15:25pm - 16:00pm"];
    return @([ranges indexOfObject:range] + 1);
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.dueHomeworkCount != nil) {
        [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Subject *subj, NSUInteger idx, BOOL *stop) {
            [self updateCountDictionaryForSubject:subj];
        }];
        [self.tableView reloadData];
    }
    [super viewWillAppear:animated];
}

#pragma mark Add a Subject

- (void) addSubjectWithName:(NSString *) name
{
    Subject *sub = [NSEntityDescription insertNewObjectForEntityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [sub setName:name];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error inserting subject");
    }
}

- (BOOL) subjectExistsWithName:(NSString *) name {
    return [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]].count > 0;
}

- (BOOL) teacherExistsWithName:(NSString *) name {
    NSArray *components = [name componentsSeparatedByString:@" "];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Teacher"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"surname == %@", [components lastObject]]];
    NSError *error;
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    return count > 0;
}

- (void) addTeacherWithName:(NSString *) name {
    Teacher *teacher = [NSEntityDescription insertNewObjectForEntityForName:@"Teacher" inManagedObjectContext:self.managedObjectContext];
    NSArray *components = [name componentsSeparatedByString:@" "];
    [teacher setTitle:components[0]];
    [teacher setSurname:[components lastObject]];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error inserting subject");
    }
}

#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SCLoginAlertTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            NSString *username = [[alertView textFieldAtIndex:0] text];
            NSString *password = [[alertView textFieldAtIndex:1] text];
            [self loadTimetableAndLessonsForUsername:username andPassword:password];
        }
    }
}

#pragma mark NSFetchRequest for Number of Homeworks for Subject

- (NSFetchRequest *) fetchRequestForDueHomeworksOfSubject:(Subject *) subject {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Homework"];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Homework" inManagedObjectContext:self.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subject == %@ AND completed == 0", subject];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSUInteger) numberOfDueHomeworksForSubject:(Subject *) subject {
    NSFetchRequest *request = [self fetchRequestForDueHomeworksOfSubject:subject];
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error getting count: %@", error.localizedDescription);
    }
    else if (count == NSNotFound) {
        return 0;
    }
    return count;
}

- (void) updateCountDictionaryForSubject:(Subject *) subject {
    [self.dueHomeworkCount setObject:@([self numberOfDueHomeworksForSubject:subject]) forKey:[subject name]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            Subject *subject = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
            [self.dueHomeworkCount setObject:@(0) forKey:[subject name]];
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

- (TDBadgedCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentfier";
    TDBadgedCell *cell = (TDBadgedCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    Subject *sub = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:[sub name]];
    [cell setBadgeString:[self.dueHomeworkCount[[sub name]] stringValue]];
    return cell;
}

#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedSubject:self.fetchedResultsController.fetchedObjects[indexPath.row]];
    [self performSegueWithIdentifier:@"homework" sender:self];
}

#pragma mark Storyboarding

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SCHomeworkViewController *destination = [segue destinationViewController];
    [destination setSubject:self.selectedSubject];
}

@end
