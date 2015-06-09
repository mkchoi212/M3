//
//  TwitterTrendTimelineTableViewController.h
//  Morning
//
//  Created by Dan Sinclair on 04/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface TwitterTrendTimelineTableViewController : TWTRTimelineViewController

@property (nonatomic, strong) NSDictionary *trend;
- (IBAction)donePressed:(id)sender;


@end
