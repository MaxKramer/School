//
//  SCDirectionsTests.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import "MKPolyline+PolylineDecoding.h"

@interface SCDirectionsTests : XCTestCase

@property (nonatomic, assign) CLLocationCoordinate2D schoolCoordinate, currentLocationCoordinate;

@end

@implementation SCDirectionsTests

- (void)setUp
{
    self.currentLocationCoordinate = CLLocationCoordinate2DMake(51.610506, -0.236962);
    self.schoolCoordinate =  CLLocationCoordinate2DMake(51.553462, -0.181705);
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void) testDirectionsRequest {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?sensor=true&destination=%f,%f&origin=%f,%f", self.schoolCoordinate.latitude, self.schoolCoordinate.longitude, self.currentLocationCoordinate.latitude, self.currentLocationCoordinate.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:20.0f];
    XCTAssertNotNil(request, @"Request is nil");
    XCTAssertNotNil([request URL], @"URL is nil");
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        XCTAssertNil(connectionError, @"Connection error: %@", connectionError);
        XCTAssertNotNil(response, @"Nil response: %p", response);
        XCTAssertNotNil(data, @"Response data is nil: %p", data);
        
        NSError *jsonError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        XCTAssertNil(jsonError, @"Error parsing json: %@", jsonError);
        NSString *encoded = object[@"routes"][0][@"overview_polyline"][@"points"];
        XCTAssertNotNil(encoded, @"Error getting encoded polyline string");
        MKPolyline *polyline = [MKPolyline polylineWithEncodedString:encoded];
        XCTAssertNotNil(polyline, @"Polyline is nil");
    }];
}

@end
