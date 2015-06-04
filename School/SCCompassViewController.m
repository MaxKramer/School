//
//  SCCompassViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCCompassViewController.h"
#import "SVProgressHUD.h"
#import "XMLReader.h"
#import "NSString+Drawing.h"
#import "SCWebViewController.h"

@interface SCCompassViewController ()

@property (nonatomic, strong) NSArray *articles;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SCCompassViewController

- (void) viewDidLoad {
    [self.navigationItem setTitle:@"UCS Compass"];
    
    [self setDateFormatter:[[NSDateFormatter alloc] init]];
    [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
    
    [super viewDidLoad];
    
    [self refresh:nil];
}

- (void) refresh:(UIRefreshControl *) control {
    [SVProgressHUD showWithStatus:@"Loading articles, please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self loadArticlesWithCallback:^(NSArray *articles, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"No internet! Please check your internet connection and try again."];
        }
        else {
            [SVProgressHUD showSuccessWithStatus:@"Loaded Articles"];
            NSArray *sorted = [articles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
                NSDate *date1 = [self.dateFormatter dateFromString:obj1[@"date_added"]];
                NSDate *date2 = [self.dateFormatter dateFromString:obj2[@"date_added"]];
                return [date1 compare:date2];
            }];
            [self setArticles:sorted];
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void) loadArticlesWithCallback:(void (^) (NSArray *articles, NSError *error)) callback {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.ucscompass.co.uk/feeds/posts/default?alt=rss"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil, connectionError);
            });
        }
        else {
            NSDictionary *xml = [XMLReader dictionaryForXMLData:data error:nil];
            NSArray *formatted = [self formattedArticles:xml[@"rss"][@"channel"][@"item"]];
            dispatch_async(dispatch_get_main_queue(), ^{
               callback(formatted, nil);
            });
        }
    }];
}

- (NSArray *) formattedArticles:(NSArray *) articles {
    NSMutableArray *formatted = [NSMutableArray array];
    [articles enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSDate *asDate = [self.dateFormatter dateFromString:obj[@"pubDate"][@"text"]];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMM yyyy"];
        NSString *string = [self.dateFormatter stringFromDate:asDate];
        [self.dateFormatter setDateFormat:@"EEE, dd MMMMM yyyy HH:mm:ss ZZZZ"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:obj[@"title"][@"text"] forKey:@"title"];
        [dictionary setObject:obj[@"category"][0][@"text"] forKey:@"author"];
        if (string != nil) {
            [dictionary setObject:string forKey:@"date_added"];
        }
        else {
            [dictionary setObject:obj[@"pubDate"][@"text"] forKey:@"date_added"];
        }
        [dictionary setObject:obj[@"title"][@"text"] forKey:@"title"];
        [dictionary setObject:obj[@"description"][@"text"] forKey:@"content"];
        [formatted addObject:dictionary];
    }];
    return formatted;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *article = self.articles[indexPath.row];
    NSString *title = article[@"title"];
    NSString *description =[NSString stringWithFormat:@"Written by %@ on %@", article[@"author"], article[@"date_added"]];
    CGFloat height = 20;
    height += [title heightWithFont:[UIFont systemFontOfSize:14.0f] maxSize:CGSizeMake(265, 500) andLinebreakMode:NSLineBreakByWordWrapping];
    height += [description heightWithFont:[UIFont systemFontOfSize:12.0f] maxSize:CGSizeMake(265, 500) andLinebreakMode:NSLineBreakByWordWrapping];
    return height;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdentifier = @"ReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
    }
    NSDictionary *article = self.articles[indexPath.row];
    
    [cell.textLabel setText:article[@"title"]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Written by %@ on %@", article[@"author"], article[@"date_added"]]];
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
    NSDictionary *article = self.articles[indexPath.row];
    SCWebViewController *webViewController = [[SCWebViewController alloc] initWithHTML:article[@"content"]];
    [webViewController setTitle:article[@"title"]];
    [self.navigationController pushViewController:webViewController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}


@end
