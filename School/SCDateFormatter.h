//
//  SCDateFormatter.h
//  School
//
//  Created by Max Kramer on 29/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RelativeDateDescriptor;
@interface SCDateFormatter : NSObject

+ (instancetype) sharedFormatter;

- (NSDate *) dateFromString:(NSString *) string withFormat:(NSString *) fmt;
- (NSString *) stringFromDate:(NSDate *) date intoFormat:(NSString *) fmt;

- (NSString *) relativeStringBetweenDate:(NSDate *) date andDate:(NSDate *) date2 useSchoolDay:(BOOL) schoolDay;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) RelativeDateDescriptor *relativeFormatter;

@end
