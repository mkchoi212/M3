//
//  TwitterTrendTimelineTableViewController.m
//  Morning
//
//  Created by Dan Sinclair on 04/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "TwitterTrendTimelineTableViewController.h"

@implementation TwitterTrendTimelineTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = false;
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];

    
    [self loadTrend];
    
}

- (void)loadTrend {
    NSLog(@"loading trend with name: %@", self.trend[@"name"]);
    self.navigationItem.title = self.trend[@"name"];
    TWTRAPIClient *APIClient = [[Twitter sharedInstance] APIClient];
    TWTRSearchTimelineDataSource *searchTimelineDataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:self.trend[@"name"] APIClient:APIClient];
    self.dataSource = searchTimelineDataSource;
}

-(void)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end