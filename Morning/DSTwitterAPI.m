//
//  DSTwitterAPI.m
//  Morning
//
//  Created by Dan Sinclair on 09/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "DSTwitterAPI.h"
#import <TwitterKit/TwitterKit.h>

@implementation DSTwitterAPI

+ (void)getHomeTimeline:(DSTwitterHomeTimelineCompletion)completion {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:nil
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                // handle the response data e.g.
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:0
                                      error:&jsonError];
                NSArray *tweets = [TWTRTweet tweetsWithJSONArray:jsonArray];
                completion(tweets, nil);
                
            }
            else {
                NSLog(@"Error: %@", connectionError);
                completion(nil, connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(nil, clientError);
    }
}

+ (void)retweetTweetWithID:(NSString *)tweetID completion:(DSTwitterRetweetCompletion)completion{
    
    NSString *statusesShowEndpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweetID];
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"POST"
                             URL:statusesShowEndpoint
                             parameters:nil
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                // handle the response data e.g.
                completion(nil);
                
            }
            else {
                NSLog(@"Error: %@", connectionError);
                completion(connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(clientError);
    }
    
}

+ (void)favoriteTweetWithID:(NSString *)tweetID completion:(DSTwitterRetweetCompletion)completion{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/favorites/create.json";
    NSError *clientError;
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tweetID, @"id", nil];
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"POST"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                // handle the response data e.g.
                completion(nil);
                
            }
            else {
                NSLog(@"Error: %@", connectionError);
                completion(connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(clientError);
    }
}

@end
