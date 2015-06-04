//
//  SCWebViewController.h
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCWebViewController : UIViewController

- (id) initWithURLRequest:(NSURLRequest *) request;
- (id) initWithHTML:(NSString *) html;

@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSString *html;

@end
