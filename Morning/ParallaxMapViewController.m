//
//  ParallaxMapViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 06.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "ParallaxMapViewController.h"
#import "CoffeeTableViewController.h"
#import "MapViewController.h"

@interface ParallaxMapViewController ()
@property (nonatomic, strong) CoffeeTableViewController *coffeeTable;
@property (nonatomic, strong) MapViewController *coffeeMap;
@end

@implementation ParallaxMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.coffeeTable = [self.storyboard instantiateViewControllerWithIdentifier:@"coffeeTable"];
    self.coffeeTable.parallax = self;
    
    self.coffeeMap = [self.storyboard instantiateViewControllerWithIdentifier:@"coffeeMap"];
    
    [self setupWithTopViewController:self.coffeeMap andTopHeight:210 andBottomViewController:self.coffeeTable];
    
    self.maxHeight = self.view.frame.size.height-50.0f;
    
}

- (void)passVenues:(NSArray *)venues {
    [self.coffeeMap setResults:venues];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesBegan:touchPoint inView:self.view];
    [DNTutorial completedStepForKey:@"fourthStep"];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesMoved:touchPoint destinationSize:CGSizeMake(0, -100)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    [DNTutorial touchesEnded:touchPoint destinationSize:CGSizeMake(0, -100)];
}


@end
