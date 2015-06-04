//
//  SCWebViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCWebViewController.h"
#import "SVProgressHUD.h"

@interface SCWebViewController () <UIWebViewDelegate>

@end

@implementation SCWebViewController

- (id) initWithHTML:(NSString *)html {
    if ((self = [super init])) {
        _html = html;
    }
    return self;
}

- (id) initWithURLRequest:(NSURLRequest *)request {
    if ((self = [super init])) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad
{
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:[self.view frame]];
    [_webView setDelegate:self];
    [_webView setScalesPageToFit:YES];
    [self.view addSubview:_webView];
    if (self.request) {
        [_webView loadRequest:self.request];
    }
    else if (self.html) {
        [_webView loadHTMLString:self.html baseURL:nil];
    }
}

- (void) setRequest:(NSURLRequest *)request {
    if (_request != request) {
        _request = request;
        if (_request && _webView) {
            [_webView loadRequest:_request];
        }
    }
}


- (void) setHtml:(NSString *)html {
    if (_html != html) {
        _html = html;
        if (_html && _webView) {
            [_webView loadHTMLString:_html baseURL:nil];
        }
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    if (![self.request.URL.pathExtension isEqualToString:@"pdf"]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
