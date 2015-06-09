//
//  MapViewController.m
//  Morning
//
//  Created by Mike Choi on 1/12/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "MapViewController.h"
#import "MapPin.h"
#import "Venue.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MapViewController ()
@end

@implementation MapViewController
@synthesize mapView;
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(zoomIn)
     name:UIApplicationDidBecomeActiveNotification
     object:[UIApplication sharedApplication]];
}

- (void)zoomIn{
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.09f;
    [self.mapView setRegion:region animated:YES];
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.09f;
    [self.mapView setRegion:region animated:YES];
    
    self.userCoor = [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    [self setResults:self.results];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass: [MKUserLocation class]]){
       // [mapView selectAnnotation:annotation animated:YES];
        return nil;
    }
    else{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    // Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"arrow"];
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, 23, 23);
    annotationView.rightCalloutAccessoryView = button;
    annotationView.canShowCallout = YES;
        return annotationView;
    }
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    id<MKAnnotation> selectedAnn = view.annotation;
    
    MapPin *vma = (MapPin *)selectedAnn;
    Venue *venue = [self.results objectAtIndex:vma.tag];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[venue.location.lat doubleValue], (CLLocationDegrees)[venue.location.lng doubleValue]) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = venue.name;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [mapItem openInMapsWithLaunchOptions:launchOptions];
}


- (void)setResults:(NSArray *)results {
    _results = results;
    
    for(int i = 0; i < _results.count; i++){
        Venue *venue = [results objectAtIndex:i];
        NSString *title = venue.name;
        NSString *subtitle = [NSString stringWithFormat:@"%d checkins", venue.stats.checkins.intValue];
        NSNumber *lat = venue.location.lat;
        NSNumber *lng = venue.location.lng;
        CLLocationCoordinate2D coord;
        coord.latitude = lat.doubleValue;
        coord.longitude = lng.doubleValue;
        MapPin *ann = [[MapPin alloc] initWithTitle:title andSubtitle:subtitle AndCoordinate:coord tag:i];
        [self.mapView addAnnotation:ann];
    }
    
    [self.mapView reloadInputViews];
}


@end
