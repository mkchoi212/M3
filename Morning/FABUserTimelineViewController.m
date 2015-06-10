//
//  FABUserTimelineViewController.m
//  Morning
//
//  Created by Mike Choi on 6/3/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

// FABUserTimelineViewController.m
#import "FABUserTimelineViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface FABUserTimelineViewController ()

@property (nonatomic, strong) NSArray *tweets;

@end

@implementation FABUserTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.screenName];
    
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
                self.tweets = [TWTRTweet tweetsWithJSONArray:jsonArray];
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
}

- (void)tweetView:(TWTRTweetView *)tweetView didTapURL:(NSURL *)url {

    UIViewController *webViewController = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webViewController.view = webView;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)setDataSource:(id<TWTRTimelineDataSource>)dataSource {
    
    NSLog(@"self.dataSource description: %@", dataSource);

}

@end