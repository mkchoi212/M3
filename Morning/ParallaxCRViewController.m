//
//  ParallaxCRViewController.m
//  Morning
//
//  Created by Mike Choi on 1/14/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "ParallaxCRViewController.h"
#import "CRViewController.h"
#import "RemindersViewController.h"
@interface ParallaxCRViewController ()

@end

@implementation ParallaxCRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    RemindersViewController *reminders = [self.storyboard instantiateViewControllerWithIdentifier:@"reminders"];
    
    CRViewController *calendar = [self.storyboard instantiateViewControllerWithIdentifier:@"cr"];
    
    [self setupWithTopViewController:calendar andTopHeight:200 andBottomViewController:reminders];
    
    self.maxHeight = self.view.frame.size.height-40.0f;
}


@end
