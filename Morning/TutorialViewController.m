//
//  TutorialViewController.m
//  Morning
//
//  Created by Mike Choi on 2/24/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "TutorialViewController.h"
#import "SKPanoramaView.h"
#import "MainViewController.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface TutorialViewController (){
    FBShimmeringView *_shimmeringView;
    UIView *_contentView;
    UILabel *_logoLabel;
}

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self showLinkedinAnimation];
    [self shimmer];
    
}

- (void)shimmer{
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0.0f,self.view.bounds.size.height/2-self.view.bounds.size.height/5,self.view.bounds.size.width,self.view.bounds.size.height/4)];
    [self.view addSubview:shimmeringView];
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = NSLocalizedString(@"Morning", nil);
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60];
    shimmeringView.contentView = loadingLabel;
    shimmeringView.shimmeringSpeed = 250;
    shimmeringView.shimmering = YES;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [FBShimmeringView beginAnimations:nil context:nil];
        [FBShimmeringView setAnimationDuration:1.0];
        [FBShimmeringView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view] cache:YES];
        [shimmeringView setFrame:CGRectMake(0.0f,10,self.view.bounds.size.width,self.view.bounds.size.height/4)];
        [FBShimmeringView commitAnimations];
        shimmeringView.shimmering = NO;
        [self da_panels];
        
    });
}
                   

- (void) showLinkedinAnimation
{
    SKPanoramaView *panoramaView = [[SKPanoramaView alloc] initWithFrame:self.view.frame image:[UIImage imageNamed:@"nyc"]];
    panoramaView.animationDuration = 90;
    [self.view addSubview:panoramaView];
    [panoramaView startAnimating];
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.4;
    [panoramaView addSubview:overlayView];

}



-(void)da_panels{
    
    //STEP 1 Construct Panels
    MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"ic"] title:@"Welcome..." description:@"Hey, welcome to Morning" ];
    
    //You may also add in a title for each panel
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"all"] title:@"All-in-One" description:@"Morning contains everything you would want and need to know when you wake up"];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"coffee"] title:@"Coffee?" description:@"Morning will show you the nearest cafés and tell you how to get there"];
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"weather"] title:@"Weather" description:@"Will you need a jacket or an umbrella? Or both?"];
    MYIntroductionPanel *panel5 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"tweet"] title:@"Social Media" description:@"Don't forget social media... Twitter is built right in"];
    MYIntroductionPanel *panel6 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"more"] title:@"More..." description:@"And please accept the privacy authorization requests.. Nothing fishy is going on here"];
  
    
    self.introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height) headerText:@"" panels:@[panel, panel2,panel3,panel4,panel5,panel6] languageDirection:MYLanguageDirectionLeftToRight];
    
    
    [_introductionView.HeaderImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_introductionView.HeaderLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_introductionView.HeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_introductionView.PageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_introductionView.SkipButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    
    
    
    //Set delegate to self for callbacks (optional)
    _introductionView.delegate = self;
    
    //STEP 3: Show introduction view
    [_introductionView showInView:self.view animateDuration:2.0];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sample Delegate Methods

-(void)introductionDidFinishWithType:(MYFinishType)finishType{
    if (finishType == MYFinishTypeSkipButton) {
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0.0f,self.view.bounds.size.height/2-self.view.bounds.size.height/5,self.view.bounds.size.width,self.view.bounds.size.height/3)];
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = NSLocalizedString(@"Setting up your home screen", nil);
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.numberOfLines = 0;
        loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        shimmeringView.contentView = loadingLabel;
        shimmeringView.shimmeringSpeed = 250;
        shimmeringView.shimmering = YES;
        [self.view addSubview:shimmeringView];

        
        MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"sickaf"];
        main.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:main animated:YES completion:nil];
    }
    else if (finishType == MYFinishTypeSwipeOut){
        
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0.0f,self.view.bounds.size.height/2-self.view.bounds.size.height/5,self.view.bounds.size.width,self.view.bounds.size.height/3)];
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = NSLocalizedString(@"Setting up your home screen", nil);
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.numberOfLines = 0;
        loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        shimmeringView.contentView = loadingLabel;
        shimmeringView.shimmeringSpeed = 250;
        shimmeringView.shimmering = YES;
        [self.view addSubview:shimmeringView];
        MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"sickaf"];
        main.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:main animated:YES completion:nil];
    }
    
}


-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    if(panelIndex == 5){
        self.introductionView.SkipButton.titleLabel.text = @"Go";
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        #ifdef __IPHONE_8_0
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self requestAuthorization];
        }
        #endif
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


@end
