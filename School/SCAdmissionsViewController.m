//
//  SCAdmissionsViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCAdmissionsViewController.h"
#import "SCAdmissionsInfoViewController.h"

@interface SCAdmissionsViewController ()

@end

@implementation SCAdmissionsViewController

- (void) viewDidLoad {
    [self.navigationItem setTitle:@"Admissions"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITextView class]]) {
            [obj setScrollEnabled:NO];
            *stop = YES;
        }
    }];
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdentifier = @"ReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"The Phoenix"];
            [cell.detailTextLabel setText:@"For children aged 3-7 years (nursery to yr 2)"];
            break;
        case 1:
            [cell.textLabel setText:@"The Junior Branch"];
            [cell.detailTextLabel setText:@"For children aged 7-11 (yrs 3-6)"];
            break;
        case 2:
            [cell.textLabel setText:@"The Senior School"];
            [cell.detailTextLabel setText:@"For children aged 11-19 (yrs 7-13)"];
            break;
    }
    
    [cell.textLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:4.0f/255.0f blue:13.0f/255.0f alpha:1.0f]];
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCAdmissionsInfoViewController *admissions = [[SCAdmissionsInfoViewController alloc] initWithAdmissionType:(indexPath.row == 0 ? SCAdmissionTypePhoenix : indexPath.row == 1 ? SCAdmissionTypeJunior : SCAdmissionTypeSenior)];
    [self.navigationController pushViewController:admissions animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
