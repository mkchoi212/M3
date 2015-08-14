//
//  SettingsTableViewController.h
//  Morning
//
//  Created by Mike Choi on 1/15/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

@interface SettingsTableViewController : UIViewController <SKSTableViewDelegate>

@property (nonatomic, weak) IBOutlet SKSTableView *tableView;

- (void)postNotificationWithString:(NSString *)unit forNotifcationName:(NSString *)notificationName;

@end
