//
//  SCHomeViewController.m
//  School
//
//  Created by Max Kramer on 09/12/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCHomeViewController.h"

@interface SCHomeViewController ()

@end

static NSString *SCIsStudentKey = @"SCIsStudent";

@implementation SCHomeViewController

- (void)viewDidLoad
{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        CGRect frame = self.titleLabel.frame;
        frame.origin.y = 20;
        [self.titleLabel setFrame:frame];
        CGRect logoFrame = self.logoImageView.frame;
        logoFrame.origin.y = 100;
        [self.logoImageView setFrame:logoFrame];
        CGRect question = self.questionLabel.frame;
        question.origin.y = self.logoImageView.frame.origin.y + self.logoImageView.frame.size.height + 10;
        [self.questionLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.questionLabel setFrame:question];
        CGRect student = self.studentButton.frame;
        student.origin.y = self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height;
        [self.studentButton setFrame:student];
        CGRect prospective = self.prospectiveButton.frame;
        prospective.origin.y = self.studentButton.frame.origin.y + self.studentButton.frame.size.height;
        [self.prospectiveButton setFrame:prospective];
        CGRect propaganda = self.propagandaLabel.frame;
        propaganda.origin.y = self.view.frame.size.height - propaganda.size.height - 10;
        [self.propagandaLabel setFrame:propaganda];
    }
    [self.prospectiveButton addTarget:self action:@selector(prospectiveParent:) forControlEvents:UIControlEventTouchUpInside];
    [self.studentButton addTarget:self action:@selector(student:) forControlEvents:UIControlEventTouchUpInside];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SCIsStudentKey]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCIsStudentKey]) {
            [self performSelector:@selector(student:) withObject:nil afterDelay:0.2f];
        }
        else {
            [self performSelector:@selector(prospectiveParent:) withObject:nil afterDelay:0.2f];
        }
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) student:(id) sender {
    [self performSegueWithIdentifier:@"student" sender:self];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SCIsStudentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) prospectiveParent:(id) sender {
    [self performSegueWithIdentifier:@"parent" sender:self];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SCIsStudentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
