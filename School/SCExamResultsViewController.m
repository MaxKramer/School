//
//  SCExamResultsViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCExamResultsViewController.h"
#import "SCWebViewController.h"

@interface SCExamResultsViewController ()

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation SCExamResultsViewController

- (void) viewDidLoad {
    [self.navigationItem setTitle:@"Exam Results"];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const ReuseIdentifier = @"ReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"2013 results for A Level candidates"];
            [cell.detailTextLabel setText:@"92% achieved A* to B grades."];
            break;
        case 1:
            [cell.textLabel setText:@"2013 results for GCSE candidates"];
            [cell.detailTextLabel setText:@"A record breaking 87% achieved A* or A grades."];
            break;
    }
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:4.0f/255.0f blue:13.0f/255.0f alpha:1.0f]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *resourceName = nil;
    if (indexPath.row == 0) {
        resourceName =  @"2013_a_level_summary_2";
    }
    else {
        resourceName = @"2013_gcse_results_summary_2";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"pdf"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
    
    SCWebViewController *webViewController = [[SCWebViewController alloc] initWithURLRequest:request];
    NSString *title = nil;
    if (indexPath.row == 0) {
        title = @"A Level Results";
    }
    else {
        title = @"GCSE Results";
    }
    
    [webViewController.navigationItem setTitle:title];
    
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

@end