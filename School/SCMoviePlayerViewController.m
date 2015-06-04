//
//  SCMoviePlayerViewController.m
//  School
//
//  Created by Max Kramer on 08/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCMoviePlayerViewController.h"

@interface SCMoviePlayerViewController ()

@end

@implementation SCMoviePlayerViewController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
