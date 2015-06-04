//
//  Lesson.h
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subject, Teacher;

@interface Lesson : NSManagedObject

@property (nonatomic, retain) NSString * classroom;
@property (nonatomic, retain) NSNumber * period;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) Teacher *teacher;
@property (nonatomic, retain) Subject *subject;

@end
