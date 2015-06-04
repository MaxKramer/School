//
//  SCHomeViewController.h
//  School
//
//  Created by Max Kramer on 09/12/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHomeViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *studentButton, *prospectiveButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel, *questionLabel, *propagandaLabel;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@end
