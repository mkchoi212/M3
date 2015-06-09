//
//  ViewController.h
//  Morning
//
//  Created by Mike Choi on 1/5/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "TTSlidingPagesDataSource.h"
#import "TTSliddingPageDelegate.h"
#import "CZMainViewController.h"
#import "DNTutorial.h"

@interface MainViewController : UIViewController<TTSlidingPagesDataSource, TTSliddingPageDelegate, DNTutorialDelegate>{
}

@property (strong, nonatomic) CZMainViewController *weatherVC;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyr;
- (void)useNotificationWithString:(NSNotification*)notification;

@end

