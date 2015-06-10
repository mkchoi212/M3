//
//  DSTwitterAPI.h
//  Morning
//
//  Created by Dan Sinclair on 09/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^DSTwitterHomeTimelineCompletion)(NSArray *tweets, NSError *error);
typedef void(^DSTwitterRetweetCompletion)(NSError *error);
typedef void(^DSTwitterFavoriteCompletion)(NSError *error);
typedef void(^DSTwitterTweetCotainsImageCompletion)(NSURL *url, NSError *error);

@interface DSTwitterAPI : NSObject

+ (void)getHomeTimeline:(DSTwitterHomeTimelineCompletion)completion;

+ (void)retweetTweetWithID:(NSString *)tweetID completion:(DSTwitterRetweetCompletion)completion;
+ (void)favoriteTweetWithID:(NSString *)tweetID completion:(DSTwitterRetweetCompletion)completion;

+ (void)tweetContainsImage:(NSString *)tweetID completion:(DSTwitterTweetCotainsImageCompletion)completion;

@end
