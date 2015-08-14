//
//  ViewController.m
//  Morning
//
//  Created by Mike Choi on 1/5/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "MainViewController.h"
#import "TTScrollSlidingPagesController.h"
#import "TTSlidingPage.h"
#import "TTSlidingPageTitle.h"
#import "CZMainViewController.h"
#import "ParallaxCRViewController.h"
#import <FBShimmeringView.h>
#import "ForcedViewController.h"
#import "CWStatusBarNotification.h"

@interface MainViewController (){
    FBShimmeringView *_shimmeringView;
}

@property (strong, nonatomic) TTScrollSlidingPagesController *slider;
@property (strong, nonatomic) NSMutableArray *slidesRead;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *goodmorning = [NSArray arrayWithObjects:@"GUTEN\nMORGEN", @"BONJOUR", @"HOLA", @"안녕하세요", @"BUENOS\nDÍAS", @"доброе\nутро", @"אַ גוטנ מאָרגן", @"早安", @"おはよう", @"Goeiemôre", @"Aloha\nkakahiaka",nil];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    NSInteger hour = [components hour];

    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(10, 104, self.view.bounds.size.width, 234)];
    [self.view addSubview:shimmeringView];
    shimmeringView.contentView = self.descriptionLabel;
    shimmeringView.shimmeringSpeed = 269;
    shimmeringView.shimmering = YES;
    
    if(hour >= 0 && hour < 12){
        NSUInteger randomIndex = arc4random() % [goodmorning count];
        _descriptionLabel.text = [goodmorning objectAtIndex:randomIndex];
    }
    else if(hour >= 12 && hour < 19){
      _descriptionLabel.text = @"GOOD\nAFTERNOON";
    }
    else if(hour >= 19){
        _descriptionLabel.text = @"GOOD\nEVENING";
    }
    
    self.slider = [[TTScrollSlidingPagesController alloc] init];
    self.slider.titleScrollerTextColour = [UIColor blackColor];
    self.slider.titleScrollerInActiveTextColour = [UIColor grayColor];
    self.slider.titleScrollerTextFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:24];
    self.slider.titleScrollerBottomEdgeColour = [UIColor whiteColor];
    self.slider.titleScrollerBottomEdgeHeight = 2;
    
    self.slider.titleScrollerHeight = 65;
    //slider.titleScrollerItemWidth=60;
    self.slider.titleScrollerBackgroundColour = [UIColor whiteColor];

    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
        self.slider.initialPageNumber = 1;
    else
        self.slider.initialPageNumber = 1;
    
    
    self.slider.disableTitleShadow = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        self.slider.hideStatusBarWhenScrolling = YES;
    }
    
    self.slider.dataSource = self;
    self.slider.delegate = self;
    self.slider.view.frame = self.view.frame;
    [self.view addSubview:self.slider.view];
    // [self addChildViewController:self.slider];
    
    [self performSelector:@selector(removeLabels) withObject:nil afterDelay:6];
    
    NSString *notificationName = @"refresh";
    NSString *notificationName2 = @"cafeRefresh";
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationWithString:)
     name:notificationName
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationWithString:)
     name:notificationName2
     object:nil];

    self.slidesRead = [[NSMutableArray alloc] init];
}
-(void)removeLabels{
    [self.descriptionLabel removeFromSuperview];
    [self.copyr removeFromSuperview];
}


#pragma mark TTSlidingPagesDataSource methods
-(int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
        return 3;
    else
        return 7;
}

- (void)didScrollToViewAtIndex:(NSUInteger)index {

    
//    if(![self.slidesRead containsObject:[NSNumber numberWithInteger:index]]){
//        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
//        NSInteger day = [components day];
//        
//        [self.slidesRead addObject:[NSNumber numberWithInteger:index]];
//        
//        if (self.slidesRead.count == 5 && [[NSUserDefaults standardUserDefaults]integerForKey:@"slidesReadDay"] != day){
//            NSLog(@"notification fired!");
//            CWStatusBarNotification *notification = [[CWStatusBarNotification alloc]init];
//            notification.notificationAnimationInStyle = CWNotificationAnimationStyleLeft;
//            notification.notificationAnimationOutStyle = CWNotificationAnimationStyleRight;
//            notification.notificationStyle = CWNotificationStyleNavigationBarNotification;
//            UIView *view = [[NSBundle mainBundle] loadNibNamed:@"notificationView" owner:nil options:nil][0];
//            [notification displayNotificationWithView:view forDuration:3.0];
//        
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"slidesRead"];
//            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
//            NSInteger day = [components day];
//            [[NSUserDefaults standardUserDefaults] setInteger:day forKey:@"slidesReadDay"];
//            
//        }
//    }
   
}

-(TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    
    UIViewController *viewController;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        if (index == 0){
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
        }
        else if(index == 1){
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"int"];
        }
        else if(index == 2){
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pcr"];
        }
    }
    else {

    if (index == 0){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
    }
    else if (index == 1){
        self.weatherVC = [[CZMainViewController alloc]init];
        viewController = self.weatherVC;
    }
    else if (index == 2){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"news"];
    }
    else if (index == 3){
         viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coffeeMap"];
    }
    else if (index == 4){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterViewController"];
    }
    else if (index == 5){
         viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pcr"];
    }
    else if (index == 6){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"stocks"];
    }

    }
    return [[TTSlidingPage alloc] initWithContentViewController:viewController];
}

-(TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    NSArray *searchSettings = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"search"]];
    NSInteger on = [searchSettings indexOfObject:[NSNumber numberWithBool:YES]];
    NSString *searchTitle;
    switch (on) {
        case 0:
            searchTitle = @"CAFÉ";
            break;
        case 1:
            searchTitle = @"GAS";
            break;
        case 2:
            searchTitle = @"BREAKFAST";
            break;
        case 3:
            searchTitle = @"BARS";
            break;
        default:
            break;
    }
    
    TTSlidingPageTitle *title;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable){
        if (index == 0){
            title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"⚙"];
        }
        else if(index == 1){
            title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Error"];
        }
        else if(index == 2){
             title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"C&R"];
        }
    }
    else{
    if (index == 0){
          title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"⚙"];
    }
    else if(index == 1){
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"WEATHER"];
    }
    else if (index ==2){
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"NEWS"];
    }
    else if (index == 3){
       title = [[TTSlidingPageTitle alloc] initWithHeaderText:searchTitle];
    }
    else if (index == 4){
       title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"TWITTER"];
    }
    else if (index == 5){
       title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"C&R"];
    }
    else{
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"STOCKS"];
    }
    }
    return title;
}

- (void)useNotificationWithString:(NSNotification *)notification //use notification method and logic
{
    [self.slider reloadPages];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationPortrait);
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        ForcedViewController *forced = [[ForcedViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
//        forced.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:forced animated:YES completion:nil];
//        [[UIDevice currentDevice] setValue:
//         [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
//                                    forKey:@"orientation"];
//
//    }
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//        ForcedViewController *forced = [[ForcedViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
//        forced.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:forced animated:YES completion:nil];
//        [[UIDevice currentDevice] setValue:
//         [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
//                                    forKey:@"orientation"];
//
//    }
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
