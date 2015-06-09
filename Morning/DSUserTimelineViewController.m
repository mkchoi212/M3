//
//  DSUserTimelineViewController.m
//  Morning
//
//  Created by Dan Sinclair on 09/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "DSUserTimelineViewController.h"
#import "DSTweetViewController.h"

@interface DSUserTimelineViewController ()

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;

@end

@implementation DSUserTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.screenName];
    //TWTRAPIClient *APIClient = [[Twitter sharedInstance] APIClient];
    
    /*TWTRUserTimelineDataSource *userTimelineDataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:self.screenName APIClient:APIClient];
     [userTimelineDataSource includeReplies];
     [userTimelineDataSource includeRetweets];
     self.dataSource = userTimelineDataSource;*/
    
    self.prototypeCell = [[TWTRTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self loadTweets];
    
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
        else {
            NSLog(@"error getting home timeline: %@", error);
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
        }];
    }];
    retweetAction.backgroundColor = [UIColor greenColor];
    
    UITableViewRowAction *favoriteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Favorite" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [DSTwitterAPI favoriteTweetWithID:tweet.tweetID completion:^(NSError *error) {
            if (error == nil) {
                NSLog(@"favorited!");
            }
            else {
                NSLog(@"Error favoriting: %@", error);
            }
        }];
    }];
    favoriteAction.backgroundColor = [UIColor yellowColor];
    
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
    
    [self performSegueWithIdentifier:@"ShowTweet" sender:tweet];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTweet"]) {
        DSTweetViewController *vc = segue.destinationViewController;
        vc.tweet = (TWTRTweet*)sender;
         NSLog(@"Did select Tweet: %@", (TWTRTweet*)sender);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
