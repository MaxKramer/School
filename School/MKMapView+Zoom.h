//
//  MKMapView+Zoom.h
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zoom)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end