//
//  SCDirectionsViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCDirectionsViewController.h"
#import "SVProgressHUD.h"
#import "MKMapView+Zoom.h"
#import "SCAnnotation.h"
#import "MKPolyline+PolylineDecoding.h"

@implementation SCDirectionsViewController

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord locationTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    if ((self = [super init])) {
        _coordinate = coord;
        _locationTitle = title;
        _locationSubtitle = subtitle;
    }
    return self;
}

- (void) viewDidLoad {
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.navigationItem setTitle:@"Directions"];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [self.view addSubview:_mapView];
    
    SCAnnotation *annotation = [[SCAnnotation alloc] init];
    [annotation setTitle:_locationTitle];
    [annotation setSubtitle:_locationSubtitle];
    [annotation setCoordinate:_coordinate];
    [self.mapView addAnnotation:annotation];
    
    [self.mapView setZoomEnabled:YES];
    [self.mapView setCenterCoordinate:annotation.coordinate zoomLevel:14 animated:YES];
    
    [super viewDidLoad];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(SCAnnotation *)annotation {
    static NSString *const ReuseIdentifier = @"ReuseIdentifier";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:ReuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ReuseIdentifier];
    }
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        [annotationView setPinColor:MKPinAnnotationColorPurple];
    }
    else {
        [annotationView setPinColor:MKPinAnnotationColorGreen];
    }
    [annotationView setCanShowCallout:YES];
    return annotationView;
}


- (void)zoomToPolyLine:(MKPolyline *)polyline animated:(BOOL)animated
{
    MKPolygon *polygon = [MKPolygon polygonWithPoints:polyline.points count:polyline.pointCount];
    [self.mapView setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect]) animated:animated];
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor purpleColor];
        [routeRenderer setLineWidth:5.0f];
        return routeRenderer;
    }
    return nil;
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (self.mapView.overlays.count == 0) {
        [SVProgressHUD showWithStatus:@"Finding Directions, please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [self performDirectionsRequestWithBlock:^(MKPolyline *polyline, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"Unable to find directions"];
            }
            else {
                if ([[self.mapView overlays] count] > 0) {
                    [self.mapView removeOverlays:[self.mapView overlays]];
                    [self.mapView addOverlay:polyline];
                }
                [self.mapView addOverlay:polyline];
                [self.mapView setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(40, 0, 10, 0) animated:YES];
                [SVProgressHUD showSuccessWithStatus:@"Found directions!"];
            }
            
        }];
    }
}

- (void) performDirectionsRequestWithBlock:(void (^) (MKPolyline *polyline, NSError *error)) block {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?sensor=true&destination=%f,%f&origin=%f,%f", self.coordinate.latitude, self.coordinate.longitude, self.mapView.userLocation.location.coordinate.latitude, self.mapView.userLocation.location.coordinate.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:20.0f];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
               block(nil, connectionError);
            });
        }
        else {
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *encoded = object[@"routes"][0][@"overview_polyline"][@"points"];
            MKPolyline *polyline = [MKPolyline polylineWithEncodedString:encoded];
            block(polyline, nil);
        }
    }];
}

@end
