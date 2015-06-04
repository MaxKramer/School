//
//  SCExamResultsTests.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCWebViewController.h"

@interface SCExamResultsTests : XCTestCase

@end

@implementation SCExamResultsTests

- (void) testURL {
    for (int row = 0; row <= 1; row++) {
        NSString *resourceName = nil;
        if (row == 0) {
            resourceName =  @"2013_a_level_summary_2";
        }
        else {
            resourceName = @"2013_gcse_results_summary_2";
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"pdf"];
        XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path], @"No file exists with name %@.pdf", resourceName);
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        XCTAssertNotNil(fileURL, @"File url is nil %p", fileURL);
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
        XCTAssertNotNil(request, @"Request is nil %p", request);
        
        SCWebViewController *webViewController = [[SCWebViewController alloc] initWithURLRequest:request];
        XCTAssertNotNil(webViewController, @"Web view controller is nil %p", webViewController);
        
        NSString *title = nil;
        if (row == 0) {
            title = @"A Level Results";
        }
        else {
            title = @"GCSE Results";
        }
        
        XCTAssertNotNil(title, @"Title is nil %p", title);
        
        [webViewController.navigationItem setTitle:title];
        XCTAssertEqual(title, webViewController.navigationItem.title, @"Title has not been set properly");
        
    }
}

@end
