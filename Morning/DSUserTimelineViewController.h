//
//  DSUserTimelineViewController.h
//  Morning
//
//  Created by Dan Sinclair on 09/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import "DSTwitterApi.h"

@interface DSUserTimelineViewController : UITableViewController <TWTRTweetViewDelegate>

@property (nonatomic, strong) NSString *screenName;

@end
