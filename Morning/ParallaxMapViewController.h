//
//  ParallaxMapViewController.h
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 06.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "QMBParallaxScrollViewController.h"
#import "DNTutorial.h"
@interface ParallaxMapViewController : QMBParallaxScrollViewController <UIGestureRecognizerDelegate>

- (void)passVenues:(NSArray *)venues;
@property (nonatomic, strong) UITapGestureRecognizer *tgr;


@end
