//
//  MKMapView+PolylineDecoding.h
//  School
//
//  Created by Max Kramer on 21/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (PolylineDecoding)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end