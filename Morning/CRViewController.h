//
//  CRViewController.h
//  Morning
//
//  Created by Mike Choi on 1/14/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
#import "RemindersManager.h"

@interface CRViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
