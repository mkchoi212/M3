#pragma mark - Imports

#import "CZMainViewController.h"
#import "CZWeatherView.h"
#import <CoreLocation/CoreLocation.h>

#define kDEFAULT_BACKGROUND_GRADIENT    @"gradient5"
#define kMIN_TIME_SINCE_UPDATE          3600

#pragma mark - CZMainViewController Class Extension

@interface CZMainViewController ()
// YES if the view has appeared
@property (nonatomic) BOOL              hasAppeared;

// View to display weather information
@property (nonatomic, strong) CZWeatherView     *weatherView;

@property (nonatomic) NSString *currentUnit;

@property (nonatomic) BOOL changes;


@end


#pragma mark - CZMainViewController Implementation

@implementation CZMainViewController

#pragma mark Get city and state


#pragma mark UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weatherView = [[CZWeatherView alloc]initWithFrame:self.view.bounds];
    self.weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
    self.weatherView.alpha = 0.0;	// make the view transparent
   
    [self.view addSubview:self.weatherView];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:2.0
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.alpha = 1.0;
                         self.weatherView.alpha = 1.0;
                     }
                     completion:nil];
    
    NSString *notificationName = @"updateUnit";
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationWithString:)
     name:notificationName
     object:nil];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.changes = YES;
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [_locationManager startUpdatingLocation];
    [super viewWillAppear:YES];
}

#pragma mark Updating Weather Data
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    _currentLocation = [locations objectAtIndex:0];
    [_locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:_currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           self.weatherView.hasData = NO;
                           return;
                       }
 
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       [self updateWeather:placemark];
                       self.weatherView.hasData = YES;
                   }];
}

- (void)updateWeather:(CLPlacemark *)placemark
{
    NSDate *lastUpdated = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"updated"];
    
    //FIX THIS IF LOOP SO IT WORKS ON INITIAL START!
   if([[NSDate date]timeIntervalSinceDate:lastUpdated] >= kMIN_TIME_SINCE_UPDATE || !self.weatherView.hasData || self.changes ){
    [self.weatherView.activityIndicator startAnimating];
    NSString *city = placemark.locality;
    NSString *state = placemark.administrativeArea;
    
    CZWeatherRequest *request = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
    request.service = [CZOpenWeatherMapService new];
    request.location = [CZWeatherLocation locationWithCity:city state:state];
    [request performRequestWithHandler:^(id data, NSError *error) {
        if (data) {
            __block CZWeatherCondition *condition = (CZWeatherCondition *)data;
            CZWeatherRequest *request = [CZWeatherRequest requestWithType:CZForecastRequestType];
            request.service = [CZOpenWeatherMapService new];
            request.location = [CZWeatherLocation locationWithCity:city state:state];
            [request performRequestWithHandler:^(id data, NSError *error) {
                if (data) {
                    self.weatherView.locationLabel.text = [NSString stringWithFormat: @"%@, %@", city, state];
                    
                    if([[NSUserDefaults standardUserDefaults]boolForKey:@"temp"]){
                        self.weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f℉", condition.temperature.f];
                        self.weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", condition.highTemperature.f,condition.lowTemperature.f];
                        self.currentUnit = @"f";
                    }
                    else{
                        self.weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f℃", condition.temperature.c];
                        self.weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", condition.highTemperature.c,condition.lowTemperature.c];
                        self.currentUnit = @"c";
                    }
                    
                    CGFloat fahrenheit = MIN(MAX(0, condition.temperature.f), 99);
                    NSString *gradientImageName = [NSString stringWithFormat:@"gradient%d.png", (int)floor(fahrenheit / 10.0)];
                   
                    [UIView animateWithDuration:0.3f animations:^{
                        self.weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:gradientImageName]];
                    }];
                   

                    // Current Conditions
                    self.weatherView.conditionIconLabel.text = [NSString stringWithFormat:@"%c", condition.climaconCharacter];
                    self.weatherView.conditionDescriptionLabel.text = [condition.summary capitalizedString];
                    
                    // Forecast
                    NSArray *forecasts = (NSArray *)data;
                    if ([forecasts count] >= 3) {
                        NSDateFormatter *dateFormatter = [NSDateFormatter new];
                        dateFormatter.dateFormat = @"EEE";
                        
                        NSString *iconOne = [NSString stringWithFormat:@"%c", ((CZWeatherCondition *)forecasts[0]).climaconCharacter];
                        self.weatherView.forecastDayOneLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:86400]];
                        self.weatherView.forecastIconOneLabel.text = iconOne;
                        
                        
                        NSString *iconTwo = [NSString stringWithFormat:@"%c", ((CZWeatherCondition *)forecasts[1]).climaconCharacter];
                        self.weatherView.forecastDayTwoLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:172800]];
                        self.weatherView.forecastIconTwoLabel.text = iconTwo;
                        
                        
                        NSString *iconThree = [NSString stringWithFormat:@"%c", ((CZWeatherCondition *)forecasts[2]).climaconCharacter];
                        self.weatherView.forecastDayThreeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:259200]];
                        self.weatherView.forecastIconThreeLabel.text = iconThree;
                    }
                    
                    // Updated
                    NSString *updated = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                       dateStyle:NSDateFormatterMediumStyle
                                                                       timeStyle:NSDateFormatterShortStyle];
                    self.weatherView.updatedLabel.text = [NSString stringWithFormat:@"Updated %@", updated];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"updated"];
                    
                }
                [self.weatherView.activityIndicator stopAnimating];

            }];
        } else {
            [self.weatherView.activityIndicator stopAnimating];
        }
    }];
   }

}

//update weather when receive notifcation
- (void)useNotificationWithString:(NSNotification *)notification
{
    NSString *key = @"currentUnit";
    NSDictionary *dictionary = [notification userInfo];
    NSString *stringValueToUse = [dictionary valueForKey:key];
    if([stringValueToUse isEqualToString:self.currentUnit]){
        self.changes = NO;
    }
    else{
        self.changes = YES;
        [self.locationManager startUpdatingLocation];

    }
}

@end
