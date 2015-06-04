//
//  SCAboutViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCAboutViewController.h"
#import "NSString+Drawing.h"
#import "SCAdmissionsViewController.h"
#import "SCExamResultsViewController.h"
#import "SCInspectionReportViewController.h"
#import "SCWebViewController.h"
#import "SCEthosViewController.h"
#import "SCContactViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SCMoviePlayerViewController.h"

@interface SCAboutViewController ()

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation SCAboutViewController

- (void) viewDidLoad {
    
    [self.navigationItem setTitle:@"University College School"];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:back];
    
    NSArray *titles = @[@"Admissions", @"Exam Results", @"Prospectus", @"Inspection Reports", @"Contact", @"Day in the life of UCS", @"Ethos"];
    NSArray *descriptions = @[@"Find out more about applying to UCS", @"See how well our students have performed in recent exams", @"Order a prospectus through the post", @"View our performance in recent inspections", @"Contact us or view directions", @"A video showing what happens at UCS", @"Discover UCS' spirit as a community"];
    
    NSMutableArray *array = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:@{@"title" : titles[idx], @"description" : descriptions[idx]}];
    }];
    
    self.datasource = [array copy];
    
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.datasource[indexPath.row];
    NSString *title = data[@"title"];
    NSString *description = data[@"description"];
    CGFloat height = 20;
    height += [title heightWithFont:[UIFont boldSystemFontOfSize:14.0f] maxSize:CGSizeMake(280, 200) andLinebreakMode:NSLineBreakByWordWrapping];
    height += [description heightWithFont:[UIFont systemFontOfSize:12.0f] maxSize:CGSizeMake(280, 200) andLinebreakMode:NSLineBreakByWordWrapping];
    return height;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const ReuseIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
    }
    
    [cell.textLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:4.0f/255.0f blue:13.0f/255.0f alpha:1.0f]];
    
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    [cell.detailTextLabel setNumberOfLines:0];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    
    NSDictionary *data = self.datasource[indexPath.row];
    [cell.textLabel setText:data[@"title"]];
    [cell.detailTextLabel setText:data[@"description"]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        SCAdmissionsViewController *admissions = [[SCAdmissionsViewController alloc] initWithNibName:NSStringFromClass([SCAdmissionsViewController class]) bundle:nil];
        [self.navigationController pushViewController:admissions animated:YES];
    }
    else if (indexPath.row == 1) {
        SCExamResultsViewController *exam = [[SCExamResultsViewController alloc] init];
        [self.navigationController pushViewController:exam animated:YES];
    }
    else if (indexPath.row == 2) {
        [self setHidesBottomBarWhenPushed:YES];
        SCWebViewController *prospectus = [[SCWebViewController alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ucs.org.uk/about/order-a-prospectus.html"]]];
        [prospectus setTitle:@"Prospectus"];
        [self.navigationController pushViewController:prospectus animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
    else if (indexPath.row == 3) {
        SCInspectionReportViewController *inspection = [[SCInspectionReportViewController alloc] init];
        [self.navigationController pushViewController:inspection animated:YES];
    }
    else if (indexPath.row == 4) {
        SCContactViewController *contact = [[SCContactViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:contact animated:YES];
    }
    else if (indexPath.row == 5) {
        [self playVideo];
    }
    else if (indexPath.row == 6) {
        [self setHidesBottomBarWhenPushed:YES];
        SCEthosViewController *ethos = [[SCEthosViewController alloc] init];
        [self.navigationController pushViewController:ethos animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
}

- (void) playVideo {
    SCMoviePlayerViewController *player = [[SCMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://maxkramer.co/video.mp4"]];
    [self presentViewController:player animated:YES completion:nil];
}

@end
