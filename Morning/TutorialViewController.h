//
//  TutorialViewController.h
//  Morning
//
//  Created by Mike Choi on 2/24/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBShimmeringView.h>
#import "MYIntroductionView.h"
@interface TutorialViewController : UIViewController <MYIntroductionDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MYIntroductionView *introductionView;
@property (nonatomic, strong)CLLocationManager *locationManager;

@end
