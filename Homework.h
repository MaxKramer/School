//
//  Homework.h
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subject;

@interface Homework : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSDate * setDate;
@property (nonatomic, retain) Subject *subject;

@end
