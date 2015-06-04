//
//  SCAnnotation.h
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SCAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title, *subtitle;

@end
