//
//  SCContactTests.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

@interface SCContactTests : XCTestCase

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation SCContactTests

- (void)setUp
{
    [super setUp];
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
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    self.datasource = nil;
    [super tearDown];
}

#if TARGET_IPHONE_SIMULATOR
#else
- (void) testCalling {
    [self.datasource enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
       [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           if (idx > 0) {
               NSString *phone = obj[@"phone"];
               NSString *trimmed = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
               NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", trimmed]];
               XCTAssertTrue([[UIApplication sharedApplication] canOpenURL:url], @"Unable to call %@ with url %@", trimmed, url);
           }
       }];
    }];
}

- (void) testEmail {
    [self.datasource enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                NSString *email = obj[@"email"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", email]];
                XCTAssertTrue([[UIApplication sharedApplication] canOpenURL:url], @"Unable to email %@", email);
            }
        }];
    }];
}

#endif

- (void) testCoordinate {
    [self.datasource enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *_stop) {
            if (idx == 0) {
                NSString *coord = obj[@"coord"];
                NSArray *parts = [coord componentsSeparatedByString:@","];
                CLLocationDegrees latitude = [parts[0] doubleValue];
                CLLocationDegrees longitude = [parts[1] doubleValue];
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                XCTAssertTrue(CLLocationCoordinate2DIsValid(coordinate), @"Coordinate for %@ is invalid", coord);
                *_stop = YES;
            }
        }];
    }];
}

@end