//
//  SCInspectionReportViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCInspectionReportViewController.h"
#import "SCWebViewController.h"
#import "NSString+Drawing.h"

@interface SCInspectionReportViewController ()

@property (nonatomic, strong) NSArray *filenames, *titles, *descriptions;

@end

@implementation SCInspectionReportViewController

- (id) init {
    if ((self = [super init])) {
        [self setFilenames:@[@"the_phoenix_school_inspection_report", @"ucs_junior_branch_2011_inspection", @"ucs_senior_school_2011_inspection"]];
        [self setTitles:@[@"The Phoenix's Inspection Report from 2011", @"The Junior Branch's Inspection Report from 2011", @"The Senior School's Inspection Report from 2011"]];
        [self setDescriptions:@[@"The Phoenix was found to have 'excellent pastoral care' and 'confident' and 'articulate' students.", @"'All pupils are highly successful in their learning and development'.", @"'The curriculum and extra-curricular provision make a positive contribution to the good quality of pupils’ achievement and their personal development.'"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [self.navigationItem setTitle:@"Inspection Reports"];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titles[indexPath.row];
    NSString *description = self.descriptions[indexPath.row];
    CGFloat height = 20;
    height += [title heightWithFont:[UIFont systemFontOfSize:14.0f] maxSize:CGSizeMake(265, 300) andLinebreakMode:NSLineBreakByWordWrapping];
    height += [description heightWithFont:[UIFont systemFontOfSize:12.0f] maxSize:CGSizeMake(265, 300) andLinebreakMode:NSLineBreakByWordWrapping];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *title = self.titles[indexPath.row];
    NSString *description = self.descriptions[indexPath.row];
    
    [cell.textLabel setText:title];
    [cell.detailTextLabel setText:description];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell.textLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:4.0f/255.0f blue:13.0f/255.0f alpha:1.0f]];
    
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    [cell.detailTextLabel setNumberOfLines:0];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setHidesBottomBarWhenPushed:YES];
    NSArray *titles = @[@"The Phoenix's Inspection", @"Junior Branch Inspection", @"Senior School Inspection"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:self.filenames[indexPath.row] withExtension:@"pdf"]];
    SCWebViewController *webViewController = [[SCWebViewController alloc] initWithURLRequest:request];
    [webViewController.navigationItem setTitle:titles[indexPath.row]];
    [self.navigationController pushViewController:webViewController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

@end
