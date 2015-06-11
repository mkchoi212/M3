//
//  SettingsTableViewController.m
//  Morning
//
//  Created by Mike Choi on 1/15/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#pragma mark NSUSERSTANDARD NOTES

#import "SettingsTableViewController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "DetailNewsViewController.h"
#import <MessageUI/MessageUI.h>
#import "AMSmoothAlertView.h"
#import "CWStatusBarNotification.h"

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) UISegmentedControl *tempUnit;
@property (nonatomic, strong) UISwitch *searchChoice;

@end

@implementation SettingsTableViewController

- (void)saveContents {
    NSLog(@"Saving contents: %@", self.contents);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    [self.contents writeToFile:filePath atomically:true];
}

-(void)readContents {
    NSLog(@"reading contents...");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    self.contents = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSLog(@"self.contents: %@", self.contents);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.shouldExpandOnlyOneCell = YES;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"temp"]){
        self.tempUnit.selectedSegmentIndex = 1;
    }
    else{
        self.tempUnit.selectedSegmentIndex = 0;
    }
    
    [self readContents];
    
}

//post notification for weather unit change...
- (void)postNotificationWithString:(NSString *)unit forNotifcationName:(NSString *)notificationName{
    
    NSString *key = @"currentUnit";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:unit forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contents[indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    return  NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = self.contents[indexPath.row][0];
    cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20];
    cell.expandable = YES;
    
    if(indexPath.row == 5){
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.expandable = NO;
    }
    
    else if(indexPath.row == 6){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-120, 0, 120, 120)];
        imgView.image = [UIImage imageNamed:@"FUCKIT"];
        [cell.contentView addSubview:imgView];
        cell.expandable = NO;
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *searchSettings = [[NSUserDefaults standardUserDefaults] arrayForKey:@"search"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryView = nil;
    if (indexPath.row == 0){
        self.tempUnit = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"℉", @"℃", nil]];
        [self.tempUnit setTintColor:[UIColor blackColor]];
        self.tempUnit.frame = CGRectMake(self.view.frame.size.width-90, 17, 85, 28);
        [self.tempUnit addTarget:self action:@selector(valueChanged) forControlEvents: UIControlEventValueChanged];
        cell.accessoryView = self.tempUnit;
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"temp"]){
            self.tempUnit.selectedSegmentIndex = 0;
        }
        else{
            self.tempUnit.selectedSegmentIndex = 1;
        }
        
    }
    //news order
    if (indexPath.row == 1){
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 17, 45, 25)];
        [button setImage:[UIImage imageNamed:@"drag"] forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [button addGestureRecognizer:longPress];
        cell.accessoryView = button;
        cell.tag = 1;
    }
    
    if (indexPath.row == 2){
        self.searchChoice = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = self.searchChoice;
        self.searchChoice.tag = indexPath.subRow-1;
        if([[searchSettings objectAtIndex:indexPath.subRow-1] isEqualToNumber:[NSNumber numberWithBool:YES]])
            [self.searchChoice setOn:YES];
        else
            [self.searchChoice setOn:NO];
        [self.searchChoice addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    //slide order
    else if (indexPath.row == 3){
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 17, 45, 25)];
        [button setImage:[UIImage imageNamed:@"drag"] forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [button addGestureRecognizer:longPress];
        cell.accessoryView = button;
        cell.tag = 3;
    }
    
    else if (indexPath.row == 4){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.contents[indexPath.row][indexPath.subRow]];
    cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:20];
    
    return cell;
}


-(void)searchChanged:(id)sender{
    UISwitch *theSwitch = (UISwitch *)sender;
    
    NSMutableArray *searchSettings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"search"]];
    
    if(theSwitch.isOn)
        [searchSettings replaceObjectAtIndex:theSwitch.tag withObject:[NSNumber numberWithBool:YES]];
    else
        [searchSettings replaceObjectAtIndex:theSwitch.tag withObject:[NSNumber numberWithBool:NO]];
    
    NSInteger temp = 0;
    for (int i = 0; i < searchSettings.count; i++){
        if([[searchSettings objectAtIndex:i] isEqualToNumber:[NSNumber numberWithBool:YES]]){
            temp++;
        }
    }
    if (temp > 1){
        AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Warning" andText:@"You can only make one selection for now..." andCancelButton:NO forAlertType:AlertFailure];
        [alert show];
        [theSwitch setOn:NO];
        [searchSettings replaceObjectAtIndex:theSwitch.tag withObject:[NSNumber numberWithBool:NO]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:searchSettings forKey:@"search"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)valueChanged{
    if (self.tempUnit.selectedSegmentIndex == 1){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"temp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"temp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
#pragma mark Tableview Delegates

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 6){
        return 200.0f;
    }
    else
        return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *searchSettings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"search"]];
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc]init];
    if(indexPath.row == 5){
        
        NSInteger temp = 0;
        for (int i = 0; i < searchSettings.count; i++){
            if([[searchSettings objectAtIndex:i] isEqualToNumber:[NSNumber numberWithBool:YES]]){
                temp++;
            }
        }
        if(temp == 0){
            [searchSettings replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
            [[NSUserDefaults standardUserDefaults] setObject:searchSettings forKey:@"search"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [notification displayNotificationWithMessage:@"Saving changes: searching for Cafés as default" forDuration:3];
        }
        else{
            [notification displayNotificationWithMessage:@"Saving changes" forDuration:3];
            //   NSString *notificationName = @"cafeRefresh";
            //  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
        }
        NSString *unitChange;
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"temp"])
            unitChange = @"f";
        
        else
            unitChange = @"c";
        
        [self postNotificationWithString:unitChange forNotifcationName:@"updateUnit"];
        
    }
}


- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    //about section
    if(indexPath.row == 4){
        if(indexPath.subRow == 1){
            DetailNewsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
            NSString *urlString = @"https://lifeplusdev.wordpress.com";
            NSString *name = @"cool.af";
            detail.url = urlString;
            detail.articleTitle = name;
            [self presentViewController:detail animated:YES completion:nil];
        }
        else if(indexPath.subRow == 2){
            NSString *emailTitle = @"What's good";
            NSString *messageBody = @"Hey, here's what I think: ";
            NSArray *toRecipents = [NSArray arrayWithObject:@"mkchoi212@icloud.com"];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    //one approach..
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellText = selectedCell.textLabel.text;
    
    //NSUInteger path = [self.contents indexOfObject:cellText];
    //now..find the insdexpath of the cell with the cellText
    
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:selectedCell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = selectedCell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    selectedCell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    selectedCell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            //if (indexPath && ![indexPath isEqual:sourceIndexPath] && indexPath.row > 2 && indexPath.row < 12) {
            
            NSLog(@"CELL TAG: %lu", selectedCell.tag);
            if (selectedCell.tag == 1 && indexPath.row > 2 && indexPath.row < 12) {
                
                    // ... update data source.
                    [self.contents[1] exchangeObjectAtIndex:indexPath.row - 1 withObjectAtIndex:sourceIndexPath.row - 1];
                    
                    // ... move the rows.
                    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                    
                    // ... and update source so it is in sync with UI changes.
                    sourceIndexPath = indexPath;
            }
            
            if (selectedCell.tag == 3 && indexPath.row > 4 && indexPath.row < 11) {
                    
                    // ... update data source.
                    [self.contents[3] exchangeObjectAtIndex:indexPath.row - 3 withObjectAtIndex:sourceIndexPath.row - 3];
                    
                    // ... move the rows.
                    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                    
                    // ... and update source so it is in sync with UI changes.
                    sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            selectedCell.hidden = NO;
            selectedCell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = selectedCell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                selectedCell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                [self saveContents];
                
            }];
            
            break;
        }
    }
}

- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}



@end