//
//  RemindersViewController.h
//  Morning
//
//  Created by Mike Choi on 1/21/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersManager.h"

@interface RemindersViewController : UITableViewController<RemindersDelegate>
-(BOOL)emptyReminders;

@end
