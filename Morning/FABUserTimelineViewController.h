//
//  FABUserTimelineViewController.h
//  Morning
//
//  Created by Mike Choi on 6/3/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface FABUserTimelineViewController : TWTRTimelineViewController <TWTRTweetViewDelegate>

@property (nonatomic, strong) NSString *screenName;
@end