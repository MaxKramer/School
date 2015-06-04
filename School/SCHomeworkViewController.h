//
//  SCHomeworkViewController.h
//  School
//
//  Created by Max Kramer on 28/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subject.h"

@interface SCHomeworkViewController : SCFetchedResultsTableViewController

@property (nonatomic, strong) Subject *subject;

@end
