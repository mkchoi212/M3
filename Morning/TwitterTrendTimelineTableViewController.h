//
//  DSTrendTableViewController.h
//  Morning
//
//  Created by Dan Sinclair on 22/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import "DSTwitterApi.h"

@interface TwitterTrendTimelineTableViewController : UITableViewController <TWTRTweetViewDelegate>

@property (nonatomic, strong) NSDictionary *trend;

@end
