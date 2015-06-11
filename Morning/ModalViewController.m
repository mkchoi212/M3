//
//  ModalViewController.m
//  ZFModalTransitionDemo
//
//  Created by Amornchai Kanokpullwad on 6/4/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ModalViewController.h"
#import "AMSmoothAlertView.h"
#import "SegmentTableViewCell.h"
@interface ModalViewController ()

@end

@implementation ModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stockName.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:72]];
    [self.tableView reloadData];
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 12;
    //[[[self.allData objectForKey:@"StockInformation"] allKeys]count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *retCell;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.text = nil;
    cell.textLabel.text = nil;
    
    if(indexPath.row == 0){     //percentage change
        cell.textLabel.text = [[[self.allData objectForKey:@"StockInformation"] allKeys]objectAtIndex:37];
        
        NSString *percentChange = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:37]];
        cell.detailTextLabel.layer.cornerRadius = 5;
        if([percentChange hasPrefix:@"+"])
            cell.detailTextLabel.backgroundColor = [UIColor greenColor];
        else
            cell.detailTextLabel.backgroundColor = [UIColor redColor];
        
        cell.detailTextLabel.text = percentChange;
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        retCell = cell;
    }
    if(indexPath.row == 1){     //open price
        cell.textLabel.text = [[[self.allData objectForKey:@"StockInformation"] allKeys]objectAtIndex:40];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:40]];
        retCell = cell;
    }
    if(indexPath.row == 2){     //days' high
        cell.textLabel.text = @"Day's High";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:68]];
        retCell = cell;
    }
    if(indexPath.row == 3){     //days' low
        cell.textLabel.text = @"Day's Low";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:31]];
        retCell = cell;
    }
    if(indexPath.row == 4){     //volume
        cell.textLabel.text = [[[self.allData objectForKey:@"StockInformation"] allKeys]objectAtIndex:30];
        
        NSString *volume = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:30]];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:volume];
        cell.detailTextLabel.text = [self suffixNumber:myNumber];
        retCell = cell;
    }
    if(indexPath.row == 5){     //price-earning ratio
        cell.textLabel.text = [[[self.allData objectForKey:@"StockInformation"] allKeys]objectAtIndex:80];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:80]];
        retCell = cell;
    }
    if(indexPath.row == 6){     //market cap
        cell.textLabel.text = @"Market Cap";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:4]];
        retCell = cell;
    }
    if(indexPath.row == 7){
        cell.textLabel.text = @"50 day moving average";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:26]];
        retCell = cell;
    }
    if(indexPath.row == 8){     //1 year target price
        cell.textLabel.text = @"1 year targe price";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:36]];
        retCell = cell;
    }
    if(indexPath.row == 9){     //percent change from year high
        cell.textLabel.text = @"% Change from year high";
        NSString *percent = [NSString stringWithFormat:@"%@", [[[self.allData objectForKey:@"StockInformation"] allValues]objectAtIndex:82]];
        cell.detailTextLabel.text = percent;
        cell.detailTextLabel.layer.cornerRadius = 5;
            if([percent hasPrefix:@"+"])
                cell.detailTextLabel.backgroundColor = [UIColor greenColor];
            else
                cell.detailTextLabel.backgroundColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        retCell = cell;
    }
    
    retCell.selectionStyle = UITableViewCellSelectionStyleNone;

    if(indexPath.row == 10){
        SegmentTableViewCell *c = (SegmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"segment"];
        if (c == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SegmentTableViewCell" owner:self options:nil];
            c = [nib objectAtIndex:0];
        }
        
        [c.segmentControl addTarget:self action:@selector(segmentSwitch:) forControlEvents: UIControlEventValueChanged];
        NSArray *ranges = [[NSUserDefaults standardUserDefaults]objectForKey:@"ranges"];
        NSNumber *selectedRange = [ranges objectAtIndex:self.arrayIndex];
        
        c.segmentControl.selectedSegmentIndex = selectedRange.integerValue;
        retCell = c;
    }

    if(indexPath.row == 11){
        cell.backgroundColor = [UIColor redColor];
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        UILabel *nope = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 50)];
        nope.text = @"DELETE";
        nope.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
        nope.textAlignment = NSTextAlignmentCenter;
        nope.textColor = [UIColor whiteColor];
        [cell addSubview:nope];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        retCell = cell;
    }
    
    return retCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 11){
        AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Delete Stock" andText:@"You are about to delete the stock from your list" andCancelButton:YES forAlertType:AlertFailure];
        [alert show];
        alert.completionBlock = ^void (AMSmoothAlertView *alertObj, UIButton *button) {
            if(button == alertObj.defaultButton) {
                [self dismissViewControllerAnimated:YES completion:nil];
                
                NSString *stockIndex = [NSString stringWithFormat:@"%ld", (long)self.arrayIndex];
                [self postNotificationWithString:stockIndex withName:@"stockRefresh"];
            }
        };
    }
}

- (void)postNotificationWithString:(NSString *)tableIndex withName:(NSString *)notificationName //post notification method and logic
{
    NSString *key = @"selectedIndex";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:tableIndex forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

//for the segment control
- (IBAction)segmentSwitch:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    NSMutableArray *stockRanges = [[[NSUserDefaults standardUserDefaults]objectForKey:@"ranges"]mutableCopy];
    [stockRanges replaceObjectAtIndex:self.arrayIndex withObject:[NSNumber numberWithInteger:selectedSegment]];
    
    [[NSUserDefaults standardUserDefaults]setObject:stockRanges forKey:@"ranges"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (NSString *)suffixNumber:(NSNumber *)number
{
    if (!number)
        return @"";
    
    long long num = [number longLongValue];
    if (num < 1000)
        return [NSString stringWithFormat:@"%lld",num];
    
    int exp = (int) (log(num) / log(1000));
    NSArray * units = @[@"K",@"M",@"G",@"T",@"P",@"E"];
    
    int onlyShowDecimalPlaceForNumbersUnder = 10; // Either 10, 100, or 1000 (i.e. 10 means 12.2K would change to 12K, 100 means 120.3K would change to 120K, 1000 means 120.3K stays as is)
    NSString *roundedNumStr = [NSString stringWithFormat:@"%.1f", (num / pow(1000, exp))];
    int roundedNum = [roundedNumStr intValue];
    if (roundedNum >= onlyShowDecimalPlaceForNumbersUnder) {
        roundedNumStr = [NSString stringWithFormat:@"%.0f", (num / pow(1000, exp))];
        roundedNum = [roundedNumStr intValue];
    }
    
    if (roundedNum >= 1000) { // This fixes a number like 999,999 from displaying as 1000K by changing it to 1.0M
        exp++;
        roundedNumStr = [NSString stringWithFormat:@"%.1f", (num / pow(1000, exp))];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@", roundedNumStr, [units objectAtIndex:(exp-1)]];
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (IBAction)closeButtonPressed:(id)sender
{
    NSArray *ranges = [[NSUserDefaults standardUserDefaults]objectForKey:@"ranges"];
    NSNumber *selectedRange = [ranges objectAtIndex:self.arrayIndex];
    [self postNotificationWithString:[NSString stringWithFormat:@"%i", selectedRange.intValue] withName:@"refresh"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
