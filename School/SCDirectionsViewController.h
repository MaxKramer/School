//
//  SCDirectionsViewController.h
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SCDirectionsViewController : UIViewController <MKMapViewDelegate>

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord locationTitle:(NSString *) title andSubtitle:(NSString *) subtitle;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *locationTitle, *locationSubtitle;
@property (nonatomic, strong, readonly) MKMapView *mapView;

@end
