//
//  RemindersViewController.m
//  Morning
//
//  Created by Mike Choi on 1/21/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "RemindersViewController.h"
#import "MainViewController.h"
#import "InfoCell.h"
#import "EKCalendar+Model.h"
#import "UIColor+BFPaperColors.h"

@interface RemindersViewController()
@end
@implementation RemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This will take care of editing
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Pull-down Refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    // Register to listen to Application becoming active
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [RemindersManager sharedInstance].delegate = self;
    [self refresh];
}

-(NSNumber *)empty{
    NSMutableArray *check = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < [[RemindersManager sharedInstance].calendars count]; ++i){
        EKCalendar *calendar = [[RemindersManager sharedInstance].calendars objectAtIndex:i];
        if (calendar.reminders.count == 0){
            [check addObject:[NSNumber numberWithBool:YES]];
        }
        else{
            [check addObject:[NSNumber numberWithBool:NO]];
        }
    }
    if ([check containsObject:[NSNumber numberWithInt:NO]]){
        //NSLog(@"not empty");
        return [NSNumber numberWithBool:NO];
    }
    else{
       // NSLog(@"empty");
        return [NSNumber numberWithBool:YES];
    }
    
}

- (void)dealloc {
    [RemindersManager sharedInstance].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Pull down refresh invoked
-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    [self refresh];
}


- (void)refresh {
    [[RemindersManager sharedInstance] fetchReminders];
}

- (void)remindersUpdated:(NSArray *)calendars {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

//_______________________________________________________________________________________________________________
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([[self empty] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIImage *image = [UIImage imageNamed:@"no_rem"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.tableView.backgroundView = imageView;
        self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        return [[RemindersManager sharedInstance].calendars count];
    }
    else {
        self.tableView.backgroundView = nil;
        return [[RemindersManager sharedInstance].calendars count];
        
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 18)];
    view.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Raleway" size:14]];
    label.textColor = [UIColor whiteColor];
    EKCalendar *calendar = [[RemindersManager sharedInstance].calendars objectAtIndex:section];
    [label setText:calendar.title];
    
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    EKCalendar *calendar = [[RemindersManager sharedInstance].calendars objectAtIndex:section];
    return [calendar.reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    
    EKCalendar *calendar = [[RemindersManager sharedInstance].calendars objectAtIndex:indexPath.section];
    EKReminder *reminder = [[calendar reminders] objectAtIndex:indexPath.row];
    [cell updateCell:reminder];
    [cell.checkBox addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (void)checkButtonTapped:(id)sender
{
    InfoCell *clickedCell = (InfoCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    clickedCell.titleLabel.textColor = [UIColor lightGrayColor];
    EKCalendar *calendar = [[RemindersManager sharedInstance].calendars objectAtIndex:clickedButtonPath.section];
    EKReminder *reminder = [[calendar reminders] objectAtIndex:clickedButtonPath.row];
    BOOL result = [[RemindersManager sharedInstance] deleteReminder:reminder];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if(result) {
        //should update the data first and then delete the row!
        [self.tableView deleteRowsAtIndexPaths:@[clickedButtonPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    });
    
 }


@end
