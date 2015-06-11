//
//  DSUserTimelineViewController.m
//  Morning
//
//  Created by Dan Sinclair on 09/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "DSUserTimelineViewController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@interface DSUserTimelineViewController ()

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;

@end

@implementation DSUserTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.screenName];
<<<<<<< HEAD
=======
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
>>>>>>> origin/master
    
    self.prototypeCell = [[TWTRTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self loadTweets];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTweets {

    [DSTwitterAPI getHomeTimeline:^(NSArray *tweets, NSError *error) {
        if (error == nil) {
            self.tweets = tweets;
            [self.tableView reloadData];
        }
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tweets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
   
    
    TWTRTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.tweetView.delegate = self;
    [cell configureWithTweet:tweet];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TWTRTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    UITableViewRowAction *retweetAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Retweet" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [DSTwitterAPI retweetTweetWithID:tweet.tweetID completion:^(NSError *error) {
            if (error == nil) {
                NSLog(@"retweeted!");
            }
            else {
                NSLog(@"Error retweeting: %@", error);
            }
            [self.tableView setEditing:NO animated:YES];
        }];
    }];
    retweetAction.backgroundColor = [UIColor colorWithRed:0.298 green:0.851 blue:0.392 alpha:1];
    
    UITableViewRowAction *favoriteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [DSTwitterAPI favoriteTweetWithID:tweet.tweetID completion:^(NSError *error) {
            if (error == nil) {
                NSLog(@"favorited!");
            }
            else {
                NSLog(@"Error favoriting: %@", [error localizedDescription]);
            }
            [self.tableView setEditing:NO animated:YES];
        }];
    }];
    
    favoriteAction.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
    
    
    return @[retweetAction, favoriteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TWTRTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:self.tableView.frame.size.width];
}

- (void)tweetView:(TWTRTweetView *)tweetView didTapURL:(NSURL *)url {
    
    UIViewController *webViewController = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webViewController.view = webView;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)tweetView:(TWTRTweetView *)tweetView didSelectTweet:(TWTRTweet *)tweet {
    
    [DSTwitterAPI tweetContainsImage:tweet.tweetID completion:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"Error checking media in tweet: %@", error);
        } else {
            if (url != nil){
                JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                //for some reason, this works...
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                UIImage *img = [[UIImage alloc]initWithData:data];

                imageInfo.image = img;
                imageInfo.referenceRect = tweetView.frame;
                imageInfo.referenceView = tweetView.superview;
                imageInfo.referenceContentMode = tweetView.contentMode;
                imageInfo.referenceCornerRadius = tweetView.layer.cornerRadius;
                
                // Setup view controller
                JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                       initWithImageInfo:imageInfo
                                                       mode:JTSImageViewControllerMode_Image
                                                       backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
                
                [imageViewer showFromViewController:self.navigationController transition:JTSImageViewControllerTransition_FromOriginalPosition];
            }
        }
    }];
}


@end
