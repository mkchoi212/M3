//
//  MapViewController.h
//  Morning
//
//  Created by Mike Choi on 1/12/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "CoffeeTableViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>{
    MKMapView *mapView;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *userCoor;
@property (nonatomic,strong) NSArray *results;
- (NSString *)deviceLocation;

@end
