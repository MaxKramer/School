//
//  SCDateFormatter.m
//  School
//
//  Created by Max Kramer on 29/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCDateFormatter.h"
#import "RelativeDateDescriptor.h"

@implementation SCDateFormatter
@synthesize dateFormatter = _dateFormatter;

+ (instancetype) sharedFormatter
{
    static SCDateFormatter *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SCDateFormatter alloc] init];
    });
    return shared;
}

- (NSDateFormatter *) dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    }
    return _dateFormatter;
}

- (RelativeDateDescriptor *) relativeFormatter {
    if (!_relativeFormatter) {
        _relativeFormatter = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@" postDateDescriptionFormat:@"%@"];
        [_relativeFormatter setExpressedUnits:RDDTimeUnitDays];
    }
    return _relativeFormatter;
}

- (NSDate *) dateFromString:(NSString *) string withFormat:(NSString *)fmt {
    [self.dateFormatter setDateFormat:fmt];
    NSDate *date = [self.dateFormatter dateFromString:string];
    [self.dateFormatter setDateFormat:nil];
    return date;
}

- (NSString *) stringFromDate:(NSDate *) date intoFormat:(NSString *)fmt{
    [self.dateFormatter setDateFormat:fmt];
    NSString *string = [self.dateFormatter stringFromDate:date];
    [self.dateFormatter setDateFormat:nil];
    return string;
}

- (NSString *) relativeStringBetweenDate:(NSDate *) date andDate:(NSDate *) date2 useSchoolDay:(BOOL)schoolDay {
    NSString *result = [self.relativeFormatter describeDate:date relativeTo:date2];
    if ([result isEqualToString:@"0 day"]) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
        if (components.hour > 16 && schoolDay) {
            return @"tomorrow";
        }
        else {
            return @"today";
        }
    }
    else if ([result isEqualToString:@"1 day"]) {
        return @"tomorrow";
    }
    return result;
}

@end
