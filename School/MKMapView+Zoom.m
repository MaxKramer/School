//
//  MKMapView+Zoom.m
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "MKMapView+Zoom.h"

@implementation MKMapView (Zoom)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*self.frame.size.width/256);
    [self setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}


@end