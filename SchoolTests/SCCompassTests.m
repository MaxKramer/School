//
//  SCCompassTests.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XMLReader.h"
#import "SCWebViewController.h"

@interface SCCompassTests : XCTestCase

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSData *xmlResponse;
@end

@implementation SCCompassTests

- (void)setUp
{
    [self setDateFormatter:[[NSDateFormatter alloc] init]];
    [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
    self.xmlResponse = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"compass" ofType:@"xml"]];
    [super setUp];
}

- (void)tearDown
{
    self.dateFormatter = nil;
    self.xmlResponse = nil;
    [super tearDown];
}

- (void) testDateFormatter {
    NSArray *dates = @[@"Thu, 07 Nov 2013 17:00:00 +0000", @"Mon, 04 Nov 2013 17:00:00 +0000", @"Sun, 03 Nov 2013 17:00:00 +0000", @"Sun, 03 Nov 2013 13:00:00 +0000", @"Sat, 02 Nov 2013 13:00:00 +0000", @"Fri, 01 Nov 2013 13:00:00 +0000", @"Thu, 31 Oct 2013 14:00:00 +0000", @"Thu, 24 Oct 2013 16:00:00 +0000", @"Mon, 21 Oct 2013 16:00:00 +0000", @"Wed, 16 Oct 2013 18:00:00 +0000", @"Tue, 15 Oct 2013 17:30:00 +0000", @"Sat, 12 Oct 2013 17:00:00 +0000", @"Wed, 09 Oct 2013 18:00:00 +0000", @"Tue, 08 Oct 2013 16:00:00 +0000", @"Mon, 07 Oct 2013 16:00:00 +0000", @"Fri, 04 Oct 2013 16:00:00 +0000", @"Thu, 03 Oct 2013 21:30:00 +0000", @"Thu, 03 Oct 2013 16:00:00 +0000", @"Wed, 02 Oct 2013 18:00:00 +0000", @"Wed, 02 Oct 2013 16:00:00 +0000", @"Tue, 01 Oct 2013 18:00:00 +0000", @"Tue, 01 Oct 2013 17:30:00 +0000", @"Tue, 01 Oct 2013 17:00:00 +0000", @"Tue, 01 Oct 2013 16:00:00 +0000", @"Sun, 29 Sep 2013 10:30:00 +0000"];
    XCTAssertNotNil(self.dateFormatter, @"date formatter is nil");
    [dates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *date = [self.dateFormatter dateFromString:obj];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMM yyyy"];
        NSString *string = [self.dateFormatter stringFromDate:date];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
        XCTAssertNotNil(date, @"%@ is %@", obj, string);
    }];
}

- (void) testLoadingArticles {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.ucscompass.co.uk/feeds/posts/default?alt=rss"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30.0f];
    XCTAssertNotNil(request, @"Article request URL is nil: %@", request.URL.absoluteString);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        XCTAssertNotNil(connectionError, @"Connection has error: %@", connectionError.description);
        XCTAssertNotNil(response, @"Response is nil: %@", response);
        XCTAssertNotNil(data, @"Response data is nil: %@", data);
    
        NSError *error;
        NSDictionary *xml = [XMLReader dictionaryForXMLData:data error:&error];
        XCTAssertNotNil(xml, @"Unable to parse XML: %@ : %@", xml, error.description);
    }];
}

- (void) testArticleFormatting {
    XCTAssertNotNil(self.xmlResponse, @"XML Response property is nil: %@", self.xmlResponse);
    
    NSError *error;
    NSDictionary *xml = [XMLReader dictionaryForXMLData:self.xmlResponse error:&error];
    XCTAssertNotNil(xml, @"Unable to parse XML: %@ : %@", xml, error.description);
    
    NSArray *articles = xml[@"rss"][@"channel"][@"item"];
    
    XCTAssertNotNil(articles, @"Articles is nil: %@", articles);
    XCTAssertFalse([articles count] == 0, @"No articles found: %@", articles);
    
    NSMutableArray *formatted = [NSMutableArray array];
    
    [articles enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        XCTAssertTrue([obj isKindOfClass:[NSDictionary class]], @"Non NSDictionary in articles: %@", obj);
        
        NSDate *asDate = [self.dateFormatter dateFromString:obj[@"pubDate"][@"text"]];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMM yyyy"];
        
        NSString *string = [self.dateFormatter stringFromDate:asDate];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
        
        NSDictionary *dict = @{
                               @"title" : obj[@"title"][@"text"],
                               @"last_updated" : obj[@"atom:updated"][@"text"],
                               @"link" : obj[@"link"][@"text"],
                               @"category" : obj[@"category"][1][@"text"],
                               @"author" : obj[@"category"][0][@"text"],
                               @"date_added" : string,
                               @"title" : obj[@"title"][@"text"],
                               @"content" : obj[@"description"][@"text"]
                               };
        XCTAssertNotNil(dict, @"Article is nil: %@", dict);
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            XCTAssertNotNil(obj, @"dict[%@] is nil", key);
        }];
        
        [formatted addObject:dict];
        
    }];
    XCTAssertTrue([articles count] == [formatted count], @"Articles count does not match formatted articles count");
}

- (void) testWebView {
    
    XCTAssertNotNil(self.xmlResponse, @"XML Response property is nil: %@", self.xmlResponse);
    
    NSError *error;
    NSDictionary *xml = [XMLReader dictionaryForXMLData:self.xmlResponse error:&error];
    XCTAssertNotNil(xml, @"Unable to parse XML: %@ : %@", xml, error.description);
    
    NSArray *articles = xml[@"rss"][@"channel"][@"item"];
    
    XCTAssertNotNil(articles, @"Articles is nil: %@", articles);
    XCTAssertFalse([articles count] == 0, @"No articles found: %@", articles);
    
    [articles enumerateObjectsUsingBlock:^(NSDictionary *article, NSUInteger idx, BOOL *stop) {
        SCWebViewController *webViewController = [[SCWebViewController alloc] initWithHTML:article[@"content"]];
        [webViewController setTitle:article[@"title"]];
        XCTAssertNotNil(webViewController, @"WebViewController is nil");
    }];
}

@end
