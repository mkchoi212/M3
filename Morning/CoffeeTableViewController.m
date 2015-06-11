//
//  CoffeeTableViewController.m
//  Morning
//
//  Created by Mike Choi on 1/12/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//
#import "CoffeeTableViewController.h"
#import "Venue.h"
#import "VenueCell.h"
#import "AppDelegate.h"
#import "RJBlurAlertView.h"
#import "AMSmoothAlertView.h"
#import <RestKit/RestKit.h>

#import "MapViewController.h"

#define kCLIENTID "Y2DGJRCHEZ1XL0NXVFISFUMXE2RSYCFDNWXX5K0VRF02UEYR"
#define kCLIENTSECRET "HIBPZD3ZQ00WTH0G0LPLGQESB0XMEV0M0KZNNKZXT0YU3SEM"



@interface CoffeeTableViewController (){
    NSString *userCoord;
}


@property (nonatomic, strong) NSArray *sortedArray;

@end

@implementation CoffeeTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
  [self.locationManager startUpdatingLocation];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self configureRestKit];
    [self loadVenues];
}

- (void)refreshTableView {
    if (self.venues.count == 0) {
        UIImage *image = [UIImage imageNamed:@"no_coffee"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.tableView.contentMode = UIViewContentModeScaleAspectFill;
        self.tableView.backgroundView = imageView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.backgroundView = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.venues.count!=0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell" forIndexPath:indexPath];
    self.sortedArray = [_venues sortedArrayUsingSelector:@selector(compareDistance:)];
    Venue *venue = _sortedArray[indexPath.row];
    cell.nameLabel.text = venue.name;
    CGFloat miles = venue.location.distance.floatValue*0.000621371;
    NSString *distance = [NSString stringWithFormat:@"%.02f", miles];
    if ([distance isEqualToString:@"1"]){
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.02f mile", miles];
    }
    else{ cell.distanceLabel.text = [NSString stringWithFormat:@"%.02f miles", miles];}
    cell.checkinsLabel.text = [NSString stringWithFormat:@"%d checkins", venue.stats.checkins.intValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    RJBlurAlertView *alertView = [[RJBlurAlertView alloc] initWithTitle:@"CONFIRM" text:@"Do you wish to start navigation?" cancelButton:YES];
    alertView.animationType = RJBlurAlertViewAnimationTypeDrop;
    
    [alertView setCompletionBlock:^(RJBlurAlertView *alert, UIButton *button) {
        if (button == alert.okButton) {
            Venue *destination = [self.sortedArray objectAtIndex:indexPath.row];
            [self goDirections:destination];
        }
    }];
    [alertView show];
}

- (void)goDirections:(Venue *)venue {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[venue.location.lat doubleValue], (CLLocationDegrees)[venue.location.lng doubleValue]) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = venue.name;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [mapItem openInMapsWithLaunchOptions:launchOptions];
}

#pragma mark FOURSQUARE API

- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // define location object mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"crossStreet", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    
    RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    [statsMapping addAttributeMappingsFromDictionary:@{@"checkinsCount": @"checkins", @"tipsCount": @"tips", @"usersCount": @"users"}];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"stats" withMapping:statsMapping]];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping method:RKRequestMethodGET pathPattern:@"/v2/venues/search" keyPath:@"response.venues" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
}

- (void)loadVenues
{
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    userCoord = [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    
    NSDictionary *queryParams;

    NSArray *searchSettings = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"search"]];
    NSInteger on = [searchSettings indexOfObject:[NSNumber numberWithBool:YES]];
    NSString *searchTitle;
    switch (on) {
        case 0:
            searchTitle = @"4bf58dd8d48988d1e0931735";
            break;
        case 1:
            searchTitle = @"4bf58dd8d48988d113951735";
            break;
        case 2:
            searchTitle = @"4bf58dd8d48988d143941735";
            break;
        case 3:
            searchTitle = @"4d4b7104d754a06370d81259";
            break;
        default:
            break;
    }
    queryParams = [NSDictionary dictionaryWithObjectsAndKeys:userCoord, @"ll", clientID, @"client_id", clientSecret, @"client_secret", searchTitle, @"categoryId", @"20140118", @"v", nil];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        _venues = mappingResult.array;
        [self.parallax passVenues:_venues];
        [self refreshTableView];
        
        
    } failure:
     ^(RKObjectRequestOperation *operation, NSError *error) {
         //NSLog(@"What do you mean by 'there is no coffee?': %@", error);
     }];
    
    
}

- (UIScrollView *)scrollViewForParallaxController{
    return self.tableView;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        [self configureRestKit];
        [self loadVenues];
    }
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    // Check authorization status (with class method)
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // User has never been asked to decide on location authorization
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
        [self configureRestKit];
        [self loadVenues];

    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    // User has denied location use (either for this app or for all apps
    else if (status == kCLAuthorizationStatusDenied) {
        [self requestAuthorization];
        // Alert the user and send them to the settings to turn on location
    }
}

- (void)requestAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'While using the app' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


@end