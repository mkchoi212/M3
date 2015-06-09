//
//  CoffeeTableViewController.h
//  Morning
//
//  Created by Mike Choi on 1/12/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMBParallaxScrollViewController.h"
#import "ParallaxMapViewController.h"

@interface CoffeeTableViewController : UIViewController <QMBParallaxScrollViewHolder, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *venues;

@property (nonatomic, strong) ParallaxMapViewController *parallax;
@end
