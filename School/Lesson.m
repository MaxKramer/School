//
//  Lesson.m
//  School
//
//  Created by Max Kramer on 03/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "Lesson.h"
#import "Subject.h"
#import "Teacher.h"


@implementation Lesson

@dynamic classroom;
@dynamic period;
@dynamic day;
@dynamic teacher;
@dynamic subject;

- (NSString *) classroom {
    [self willAccessValueForKey:@"classroom"];
    NSString *classroom = [self primitiveValueForKey:@"classroom"];
    [self didAccessValueForKey:@"classroom"];
    if ([classroom stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]].length == classroom.length || [classroom length] == 1) {
        return [NSString stringWithFormat:@"%@ %@", ([classroom length] == 1 && [classroom stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]].length == 0) ? @"Lab" : @"Room", [classroom uppercaseString]];
    }
    return [classroom uppercaseString];
}

@end
