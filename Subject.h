//
//  Subject.h
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Teacher;

@interface Subject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Teacher *teacher;

@end
