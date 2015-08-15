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

+ (void)getHomeTimeline:(DSTwitterTweetsCompletion)completion {
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
                completion(tweets, nil, nil);
                
            }
            else {
                completion(nil, connectionError, nil);
            }
        }];
    }
    else {
        completion(nil, clientError, nil);
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
                completion(connectionError);
            }
        }];
    }
    else {
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
                completion(connectionError);
            }
        }];
    }
    else {
        completion(clientError);
    }
}

+ (void)tweetContainsImage:(NSString *)tweetID completion:(DSTwitterTweetCotainsImageCompletion)completion {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/show.json";
    NSError *clientError;
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tweetID, @"id", nil];
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    completion(nil, jsonError);
                } else {
                    if ([jsonDic.allKeys containsObject:@"extended_entities"]) {
                        if ([jsonDic[@"extended_entities"][@"media"][0][@"type"] isEqualToString:@"photo"]) {
                            completion(jsonDic[@"extended_entities"][@"media"][0][@"media_url"], nil);
                        }
                        else {
                            completion(nil, nil);
                        }
                    } else {
                        completion(nil, nil);
                    }
                }
                
            }
            else {
                completion(nil, connectionError);
            }
        }];
    }
    else {
        completion(nil, clientError);
    }
}

+ (void)getTweetsForTrend:(NSString*)trend completion:(DSTwitterTweetsCompletion)completion {
    NSString *statusesShowEndpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:trend, @"q", @"recent", @"result_type", nil];
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                // handle the response data e.g.
                NSError *jsonError;
                NSMutableIndexSet *sensitiveIDX = [[NSMutableIndexSet alloc]init];
                NSDictionary *jsonDic = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0
                                         error:&jsonError];
                
                NSMutableArray *tweetInfo = [jsonDic objectForKey:@"statuses"];
                
                for (int i = 0; i < tweetInfo.count; i++){
                    NSDictionary *tweet = [tweetInfo objectAtIndex:i];
                    BOOL sensitive = [tweet objectForKey:@"possibily_sensitive"];
                    if (sensitive == YES){
                        [sensitiveIDX addIndex:i];
                        NSLog(@"REMOVED!");
                    }
                }
                
                NSArray *tweets = [TWTRTweet tweetsWithJSONArray:tweetInfo];
                completion(tweets, nil, sensitiveIDX);
                
            }
            else {
                completion(nil, connectionError, nil);
            }
        }];
    }
    else {
        completion(nil, clientError, nil);
    }
}

@end
