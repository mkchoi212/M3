//
//  TwitterTableViewController.m
//  Morning
//
//  Created by Dan Sinclair on 04/06/2015.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "TwitterTableViewController.h"
#import "TwitterTrendTimelineTableViewController.h"
#import "FABUserTimelineViewController.h"
#import "ZFModalTransitionAnimator.h"

#import "DSUserTimelineViewController.h"

@interface TwitterTableViewController ()

@property (nonatomic, strong) NSMutableArray *trends;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation TwitterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TWITTER VIEW LOADED");
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"TWITTER USER LOGIN");
            self.screenName = [session userName];
            [self loadTrends];
        } else {
            NSLog(@"TWITTER USER LOGIN ERROR: %@", [error localizedDescription]);
            
            [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
                if (guestSession) {
                    NSLog(@"TWITTER USER LOGIN");
                    self.screenName = @"GUEST";
                    [self loadTrends];
                }
                else {
                    NSLog(@"TWITTER USER LOGIN ERROR: %@", [error localizedDescription]);
                }
            }];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)loadTrends {
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/trends/place.json";
    NSDictionary *params = @{@"id" : @"1"};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSArray *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 NSDictionary *dic = json[0];
                 self.trends = [dic objectForKey:@"trends"];
                 [self.tableView reloadData];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 18)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    label.textColor = [UIColor blackColor];
    NSString *string = @"MY TIMELINE";
    
    if (section == 1 ) {
        string = @"TRENDING";
    }
    
    [label setText:string];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return view;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return [self.trends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrendCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TrendCell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"@%@", self.screenName];
        cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:17];
        
    } else if(indexPath.section == 1){
        NSDictionary *trend = [self.trends objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [trend objectForKey:@"name"]];
        cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:17];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.screenName isEqualToString:@"GUEST"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not logged in" message:@"You must log in to Twitter via your device's Settings in order to view your timeline" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDestructive handler:nil];
            [alert addAction:dismiss];
            [self presentViewController:alert animated:true completion:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //FABUserTimelineViewController *modalVC = [[FABUserTimelineViewController alloc]init];
        DSUserTimelineViewController *modalVC = [storyboard instantiateViewControllerWithIdentifier:@"DSUserTimelineViewController"];
        modalVC.screenName = self.screenName;
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:modalVC];
        nav.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemStop) target:self action:@selector(backButtonItemToDismissModal)];
        nav.navigationBar.translucent = NO;
        nav.modalPresentationStyle = UIModalPresentationCustom;
        
        self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
        self.animator.dragable = YES;
        self.animator.bounces = YES;
        self.animator.behindViewAlpha = 0.5f;
        self.animator.behindViewScale = 0.8f;
        self.animator.transitionDuration = 0.7f;
        self.animator.direction = ZFModalTransitonDirectionBottom;
        [self.animator setContentScrollView:modalVC.tableView];
        nav.transitioningDelegate = self.animator;
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        TwitterTrendTimelineTableViewController *modalVC = [[TwitterTrendTimelineTableViewController alloc]init];
        modalVC.trend = [self.trends objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:modalVC];
        nav.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemStop) target:self action:@selector(backButtonItemToDismissModal)];
        nav.navigationBar.translucent = NO;
        nav.modalPresentationStyle = UIModalPresentationCustom;
        
        self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
        self.animator.dragable = YES;
        self.animator.bounces = YES;
        self.animator.behindViewAlpha = 0.5f;
        self.animator.behindViewScale = 0.8f;
        self.animator.transitionDuration = 0.7f;
        self.animator.direction = ZFModalTransitonDirectionBottom;
        [self.animator setContentScrollView:modalVC.tableView];
        nav.transitioningDelegate = self.animator;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)backButtonItemToDismissModal{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end