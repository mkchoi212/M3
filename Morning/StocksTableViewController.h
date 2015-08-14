//
//  StocksTableViewController.h
//  Morning
//
//  Created by Mike Choi on 6/11/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StocksTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *stocksTable;
- (IBAction)segmentControl:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol;
@property (weak, nonatomic) IBOutlet UIView *stockView;

@end
