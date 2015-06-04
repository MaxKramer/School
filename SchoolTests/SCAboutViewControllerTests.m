//
//  SCAboutViewControllerTests.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Drawing.h"
#import "SCAdmissionsViewController.h"
#import "SCAdmissionsInfoViewController.h"
#import "SCWebViewController.h"
#import "SCEthosViewController.h"
#import "SCContactViewController.h"
#import "SCExamResultsViewController.h"
#import "SCInspectionReportViewController.h"
#import "SCMoviePlayerViewController.h"

@interface SCAboutViewControllerTests : XCTestCase

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation SCAboutViewControllerTests

- (void)setUp
{
    NSArray *titles = @[@"Admissions", @"Exam Results", @"Prospectus", @"Inspection Reports", @"Contact", @"Day in the life of UCS", @"Ethos"];
    NSArray *descriptions = @[@"Find out more about applying to UCS", @"See how well our students have performed in recent exams", @"Order a prospectus through the post", @"View our performance in recent inspections", @"Contact us or view directions", @"A video showing what happens at UCS", @"Discover UCS' spirit as a community"];
    
    NSMutableArray *array = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:@{@"title" : titles[idx], @"description" : descriptions[idx]}];
    }];
    
    self.datasource = [array copy];
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void) testCellHeight {
    [self.datasource enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        NSString *title = data[@"title"];
        XCTAssertNotNil(title, @"Title is nil");
        XCTAssertTrue([title length] > 0, @"Title's length is 0");
        
        NSString *description = data[@"description"];
        XCTAssertNotNil(description, @"Description is nil");
        XCTAssertTrue([description length] > 0, @"Description's length is 0");
        
        CGFloat height = 20;
        height += [title heightWithFont:[UIFont boldSystemFontOfSize:14.0f] maxSize:CGSizeMake(280, 200) andLinebreakMode:NSLineBreakByWordWrapping];
        height += [description heightWithFont:[UIFont systemFontOfSize:12.0f] maxSize:CGSizeMake(280, 200) andLinebreakMode:NSLineBreakByWordWrapping];
        XCTAssertTrue(height > 20, @"Height is not greater than the padding.");
    }];
}

- (void) testViewControllerCreation {
    [self.datasource enumerateObjectsUsingBlock:^(id obj, NSUInteger row, BOOL *stop) {
        if (row == 0) {
            SCAdmissionsViewController *admissions = [[SCAdmissionsViewController alloc] initWithNibName:NSStringFromClass([SCAdmissionsViewController class]) bundle:nil];
            XCTAssertNotNil(admissions, @"Admissions view controller is nil");
        }
        else if (row == 1) {
            SCExamResultsViewController *exam = [[SCExamResultsViewController alloc] init];
            XCTAssertNotNil(exam, @"Exam results view controller is nil");
        }
        else if (row == 2) {
            SCWebViewController *prospectus = [[SCWebViewController alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ucs.org.uk/about/order-a-prospectus.html"]]];
            XCTAssertNotNil(prospectus, @"Prospectus view controller is nil");
            [prospectus setTitle:@"Prospectus"];
            XCTAssertTrue([prospectus.title isEqualToString:@"Prospectus"], @"Admissions view controller is not setting the title");
        }
        else if (row == 3) {
            SCInspectionReportViewController *inspection = [[SCInspectionReportViewController alloc] init];
            XCTAssertNotNil(inspection, @"Inspection view controller is nil");
        }
        else if (row == 4) {
            SCContactViewController *contact = [[SCContactViewController alloc] initWithStyle:UITableViewStyleGrouped];
            XCTAssertNotNil(contact, @"Contact view controller is nil");
        }
        else if (row == 5) {
            // no need to do anything as -testPlayVideo is called anyway
        }
        else if (row == 6) {
            SCEthosViewController *ethos = [[SCEthosViewController alloc] init];
            XCTAssertNotNil(ethos, @"Ethos view controller is nil");
        }
    }];
}

- (void) testPlayVideo {
    SCMoviePlayerViewController *player = [[SCMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://maxkramer.co/video.mp4"]];
    XCTAssertNotNil(player, @"Player view controller is nil");
}



@end
