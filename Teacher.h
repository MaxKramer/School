//
//  Teacher.h
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Teacher : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * surname;

@end
