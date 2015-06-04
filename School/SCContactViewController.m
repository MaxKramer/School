//
//  SCContactViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCContactViewController.h"
#import "NSString+Drawing.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "SCDirectionsViewController.h"

@interface SCContactViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation SCContactViewController

- (void)viewDidLoad
{
    [self.navigationItem setTitle:@"Contact Us"];
    
    NSArray *phoenix = @[@{@"title" : @"Directions", @"description" : @"View directions to The Phoenix", @"coord" : @"51.545839,-0.177316"}, @{@"title" : @"All Enquiries", @"phone" : @"020 7722 4433", @"email" : @"thephoenix@ucs.org.uk", @"description" : @"Call or email The Phoenix with your query."}];
    NSArray *jb = @[@{@"title" : @"Directions", @"description" : @"View directions to The Junior Branch", @"coord" : @"51.556809,-0.178985"}, @{@"title" : @"All Enquiries", @"phone" : @"020 7435 3068", @"email" : @"juniorbranch@ucs.org.uk", @"description" : @"Call or email The Junior Branch with your query."}];
    NSArray *senior = @[
    @{
        @"title" : @"Directions",
        @"description" : @"View directions to The Senior School",
        @"coord" : @"51.553462,-0.181705"
      },
    @{
        @"title": @"General Enquiries",
        @"phone" : @"020 7435 2215",
        @"email" : @"seniorschool@ucs.org.uk",
        @"description" : @"Call or email to discuss any non-specific queries you have"
      },
  @{
      @"title" : @"Pupil Absence/Lateness",
      @"phone" : @"020 7433 2136",
      @"email" : @"absence@ucs.org.uk",
      @"description" : @"Call or email to report an absence or lateness"
      },@{
      @"title" : @"Admissions Office",
      @"phone" : @"020 7433 2117",
      @"email" : @"ssadmissions@ucs.org.uk",
      @"description" : @"Call or email to discuss any questions regarding admission"
      },@{
      @"title" : @"The Headmaster's Office",
      @"phone" : @"020 7433 2102",
      @"email" : @"hmsec@ucs.org.uk",
      @"description" : @"Call or email the headmaster's office with any queries"
      },@{
      @"title" : @"Sport/PE Department",
      @"phone" : @"020 7433 2322",
      @"email" : @"PE@ucs.org.uk",
      @"description" : @"Call or email to report any injuries or speak to a member of PE staff"
      },@{
      @"title" : @"UCS Box Office",
      @"phone" : @"020 7433 2219",
      @"email" : @"boxoffice@ucs.org.uk",
      @"description" : @"Call or email to book tickets for a performance or event"
      },@{
      @"title" : @"The Bursary",
      @"phone" : @"020 7433 2140",
      @"email" : @"jcawdell@ucsadmin.org.uk",
      @"description" : @"Call or email to discuss fees or any queries regarding money"
      },@{
      @"title" : @"Old Gowers Club/Alumni Office",
      @"phone" : @"020 7433 2310",
      @"email" : @"oldgowers@ucs.org.uk",
      @"description" : @"Call or email to discuss any queries relating to the Old Gowers Club"
      },@{
      @"title" : @"School Nurse",
      @"phone" : @"020 7433 2173",
      @"email" : @"matron@ucs.org.uk",
      @"description" : @"Call or email to speak to the School Nurse"
      }];
    
    self.datasource = @[phoenix, jb, senior];
    
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource[section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.datasource[indexPath.section][indexPath.row];
    CGFloat height = 10;
    height += [data[@"title"] heightWithFont:[UIFont boldSystemFontOfSize:14.0f] maxSize:CGSizeMake(265, 300) andLinebreakMode:NSLineBreakByWordWrapping];
    height += [data[@"description"] heightWithFont:[UIFont systemFontOfSize:12.0f] maxSize:CGSizeMake(265, 300) andLinebreakMode:NSLineBreakByWordWrapping];
    return height;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"The Phoenix";
            break;
        case 1:
            return @"The Junior Branch";
            break;
        case 2:
            return @"The Senior School";
            break;
    }
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const ReuseIdentifier = @"ReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
    }
    NSDictionary *data = self.datasource[indexPath.section][indexPath.row];
    [cell.textLabel setText:data[@"title"]];
    [cell.detailTextLabel setText:data[@"description"]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell.textLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:4.0f/255.0f blue:13.0f/255.0f alpha:1.0f]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.detailTextLabel setNumberOfLines:0];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSDictionary *data = self.datasource[indexPath.section][indexPath.row];
        NSString *coordString = data[@"coord"];
        NSArray *parts = [coordString componentsSeparatedByString:@","];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([parts[0] doubleValue], [parts[1] doubleValue]);
        NSString *title = [data[@"description"] stringByReplacingOccurrencesOfString:@"View directions to " withString:@""];
        SCDirectionsViewController *directions = [[SCDirectionsViewController alloc] initWithCoordinate:coord locationTitle:title andSubtitle:@""];
        [self.navigationController pushViewController:directions animated:YES];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please choose a contact method:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"Email", nil];
        [self setSelectedIndexPath:indexPath];
        [actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            NSString *telephone = self.datasource[self.selectedIndexPath.section][self.selectedIndexPath.row][@"phone"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [telephone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
        }
        else {
            NSString *email = self.datasource[self.selectedIndexPath.section][self.selectedIndexPath.row][@"email"];
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            [controller setToRecipients:@[email]];
            [controller setSubject:@"Query from the VLE App"];
            [controller setMailComposeDelegate:self];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
