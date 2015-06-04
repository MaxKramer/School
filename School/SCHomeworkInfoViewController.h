//
//  SCHomeworkInfoViewController.h
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homework.h"

@interface SCHomeworkInfoViewController : UITableViewController

@property (nonatomic, strong) Homework *existingHomework;
@property (nonatomic, strong) void (^finishedEditingWithHomework)(NSDate *setDate, NSDate *dueDate, NSString *detail);

@end
