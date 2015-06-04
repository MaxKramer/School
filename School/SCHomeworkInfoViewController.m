//
//  SCHomeworkInfoViewController.m
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCHomeworkInfoViewController.h"
#import "UIPlaceholderTextView.h"
#import "SCDateFormatter.h"

@interface SCHomeworkInfoViewController () <UITextViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableDictionary *datasource;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation SCHomeworkInfoViewController

- (UIActionSheet *) actionSheet {
    if (_actionSheet == nil) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles:nil];
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker addTarget:self action:@selector(finishedPicker:) forControlEvents:UIControlEventValueChanged];
        [actionSheet addSubview:datePicker];
        
        _actionSheet = actionSheet;
        _datePicker = datePicker;
    }
    return _actionSheet;
}

- (void) viewDidLoad {
    [self.navigationItem setTitle:@"Add Homework"];
    [self setTitles:@[@"Date Set", @"Due Date", @"Description"]];
    [self setDatasource:[NSMutableDictionary dictionary]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(editingComplete:)]];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateNormal];
    
    if (self.existingHomework) {
        self.datasource[@"Date Set"] = [self formattedStringFromDate:self.existingHomework.setDate];
        self.datasource[@"Due Date"] = [self formattedStringFromDate:self.existingHomework.dueDate];
        self.datasource[@"Description"] = [self.existingHomework detail];
    }
    else {
        for (NSString *title in self.titles) {
            if ([title isEqualToString:@"Date Set"]) {
                self.datasource[title] = [self formattedStringFromDate:[NSDate date]];
            }
            else if ([title isEqualToString:@"Due Date"]) {
                self.datasource[title] = [self formattedStringFromDate:[NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24 * 3)]];
            }
            else {
                self.datasource[title] = @"";
            }
        }
    }
    
    [self setDateFormatter:[[NSDateFormatter alloc] init]];
    [self.dateFormatter setDateFormat:@"HH mm ss"];

    [super viewDidLoad];
}

- (NSString *) formattedStringFromDate:(NSDate *) date {
    return [[SCDateFormatter sharedFormatter] stringFromDate:date intoFormat:@"EEEE d MMMM"];
}

- (NSDate *) dateFromFormattedString:(NSString *) string {
    return [[SCDateFormatter sharedFormatter] dateFromString:string withFormat:@"EEEE d MMMM yyyy"];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 2) {
        return UITableViewAutomaticDimension;
    }
    else {
        return 150;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    NSString *title = self.titles[indexPath.row];
    [cell.textLabel setText:title];
    if (indexPath.row == 2) {
        UIPlaceHolderTextView *textView = (UIPlaceHolderTextView *) [cell.contentView viewWithTag:10];
        if (textView == nil) {
            textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(120, 0, 200, 150)];
            [textView setTag:10];
            [textView setPlaceholder:@"What have you got to do?"];
            [textView setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
            [textView setDelegate:self];
        }
        [textView setText:self.datasource[title]];
        [cell.contentView addSubview:textView];
    }
    else {
        [cell.detailTextLabel setText:self.datasource[title]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDatePickerForIndexPath:indexPath];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedEditing:)] animated:YES];
}

- (void) finishedEditing:(id) sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if ([cell.contentView viewWithTag:10]) {
        [[cell.contentView viewWithTag:10] resignFirstResponder];
    }
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void) textViewDidChange:(UITextView *)textView {
    if ([self descriptionIsValid:textView.text]) {
        [self.navigationItem.leftBarButtonItem setTitle:@"Add"];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]} forState:UIControlStateNormal];
    }
    else {
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateNormal];
    }
    self.datasource[@"Description"] = [self trimmedFormatOfString:[textView text]];
}

- (void) finishedPicker:(UIDatePicker *) sender {
    self.datasource[self.titles[sender.tag]] = [self formattedStringFromDate:sender.date];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.existingHomework && ![self.navigationItem.leftBarButtonItem.title isEqualToString:@"Save"]) {
        [self.navigationItem.leftBarButtonItem setTitle:@"Save"];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]} forState:UIControlStateNormal];
    }
}

- (void) showDatePickerForIndexPath:(NSIndexPath *) indexPath {
    NSString *title = self.titles[indexPath.row];
    [self.actionSheet setTitle:[NSString stringWithFormat:@"Choose the %@", title]];
    [self.datePicker setTag:indexPath.row];
    [self.datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:(-1 * (60 * 60 * 24 * 7))]];
    [self.datePicker setDate:[self dateFromFormattedString:[self stringByAppendingYearToString:self.datasource[self.titles[indexPath.row]]]]];
    [self.datePicker setMaximumDate:[[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24 * 28)]];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
    
    CGRect pickerRect = self.datePicker.bounds;
    pickerRect.origin.y = -100;
    self.datePicker.bounds = pickerRect;
    
    [self.actionSheet setNeedsLayout];
}

- (NSString *) trimmedFormatOfString:(NSString *) string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) descriptionIsValid:(NSString *) description {
    NSString *item = [self trimmedFormatOfString:description];
    if (item.length < 10) {
        return NO;
    }
    return YES;
}

- (NSString *) stringByAppendingYearToString:(NSString *) string {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger year = [components year];
    return [string stringByAppendingFormat:@" %i", year];
}

- (NSDate *) dateByAddingHMSToDate:(NSDate *) date useSchoolDay:(BOOL) schoolDay {
    NSString *string = [self.dateFormatter stringFromDate:[NSDate date]];
    __block NSInteger hours, seconds, minutes;
    NSArray *array = [string componentsSeparatedByString:@" "];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case 0:
                hours = [obj integerValue];
                break;
            case 1:
                minutes = [obj integerValue];
                break;
            case 2:
                seconds = [obj integerValue];
                break;
        }
    }];
    if (hours > 16 && schoolDay) {
        hours = 9;
    }
    NSTimeInterval interval = seconds + (minutes * 60) + (hours * 60 * 60);
    return [date dateByAddingTimeInterval:interval];
    
}

- (void) editingComplete:(id) sender {
    NSString *dueDate = [self stringByAppendingYearToString:self.datasource[self.titles[1]]];
    NSString *setDate = [self stringByAppendingYearToString:self.datasource[self.titles[0]]];
    if ([self descriptionIsValid:self.datasource[self.titles[2]]]) {
        if (self.finishedEditingWithHomework) {
            NSDate *set = [self dateFromFormattedString:setDate];
            NSDate *due = [self dateFromFormattedString:dueDate];
            self.finishedEditingWithHomework(set, due, self.datasource[self.titles[2]]);
        }
    }
    else {
        // leaving the controller as the cancel button was pressed
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end