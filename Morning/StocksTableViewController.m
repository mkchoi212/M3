//
//  StocksTableViewController.m
//  Morning
//
//  Created by Mike Choi on 6/11/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "StocksTableViewController.h"
#import "JCStockGraphPageController.h"
#import "JCStockPriceStore.h"
#import "ZFModalTransitionAnimator.h"
#import "JCPriceDataPoint.h"
#import "StockTableViewCell.h"
#import "OptionsTableViewController.h"

@interface StocksTableViewController ()

@property (strong, nonatomic) JCStockGraphPageController *graphPageController;
@property (strong, nonatomic) NSMutableArray *graphs;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation StocksTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphs = [[NSUserDefaults standardUserDefaults]objectForKey:@"stocks"];
    self.segmentcontrol.tintColor = [UIColor whiteColor];

    [self.segmentcontrol setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.f green:122.0/255.f blue:255.0/255.f alpha:1.0]} forState:UIControlStateSelected];
    [self.segmentcontrol setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateNormal];
    
    self.graphPageController = [self getStockGraph:[self.graphs objectAtIndex:0]];
    self.graphPageController.view.tag = 1;

    for (int i = 1; i < self.graphs.count; i++){
        [self getStockGraph:[self.graphs objectAtIndex:i]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stocksTable reloadData];

    });
    
    [self.stockView insertSubview:self.graphPageController.view belowSubview:self.segmentcontrol];

    // Get the subviews of the view
    NSArray *subviews = [self.stockView subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
    }
    

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.graphs = [[NSUserDefaults standardUserDefaults]objectForKey:@"stocks"];
    [self getStockGraph:[self.graphs lastObject]];
    [self.stocksTable reloadData];
}

- (JCStockGraphPageController *)getStockGraph:(NSString *)stockName{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight2 = screenRect.size.height/2;
    
    JCStockGraphPageController *stockPage = [[JCStockGraphPageController alloc] initWithTicker:stockName];
    stockPage.view.frame           = CGRectMake(0, 0, screenWidth, screenHeight2-20);
    stockPage.graphOffset          = CGPointMake(8, 0);
    stockPage.graphSize            = CGSizeMake(screenWidth-30, screenHeight2/1.5);
    stockPage.graphOptions = kGraphRange5Year;
    [self.stocksTable reloadData];

    return stockPage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    StockTableViewCell *cell = [self.stocksTable dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *addCell = [self.stocksTable dequeueReusableCellWithIdentifier:@"add"];
    if (cell == nil | addCell == nil){
        cell = [[StockTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        addCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"add"];
    }
    cell.stockValueLabel.font = [UIFont fontWithName:@"Arial" size:19.0];
    cell.stockPercentageLabel.font = [UIFont fontWithName:@"Arial" size:19.0];
    cell.stockPercentageLabel.textColor = [UIColor whiteColor];
    cell.stockPercentageLabel.clipsToBounds = YES;
    addCell.accessoryView = nil;
    cell.stockValueLabel.text = nil;
    cell.stockPercentageLabel.text = nil;
    addCell.textLabel.text = nil;
    addCell.detailTextLabel.textColor = [UIColor clearColor];

    
    if (indexPath.row != self.graphs.count){
        NSString *ticker = [self.graphs objectAtIndex:indexPath.row];
        cell.maintextlabel.text = ticker;
        NSDictionary *dic =  [[JCStockPriceStore sharedInstance]loadCacheForTicker:ticker];
        NSArray *points = [dic objectForKey:@"data"];
        JCPriceDataPoint *final = [points lastObject];
        JCPriceDataPoint *reference = [points objectAtIndex:points.count-2];
        
        cell.stockPercentageLabel.text = [NSString stringWithFormat:@"%.2f%% ", ((final.closePrice-reference.closePrice)/final.closePrice)*100.0];
        cell.stockValueLabel.text = [NSString stringWithFormat:@"%.2f", final.closePrice];
        
        if([cell.stockPercentageLabel.text stringByReplacingOccurrencesOfString:@"%" withString:@""].doubleValue < 0.0){
            cell.stockPercentageLabel.backgroundColor = [UIColor redColor];
            cell.stockPercentageLabel.layer.cornerRadius = 5.0f;
        }
        else{
            cell.stockPercentageLabel.backgroundColor = [UIColor colorWithRed:0.298 green:0.851 blue:0.392 alpha:1];
            cell.stockPercentageLabel.layer.cornerRadius = 5.0f;
        }
    }
    else{
        addCell.textLabel.text = @"OPTIONS";
        addCell.accessoryType = UITableViewCellAccessoryDetailButton;
        return addCell;
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row != self.graphs.count){
        for (UIView *subView in self.stockView.subviews){
            if (subView.tag == 1){
                [subView removeFromSuperview];
            }
        }
        
        StockTableViewCell *selectedCell = (StockTableViewCell *)[self.stocksTable cellForRowAtIndexPath:indexPath];
        self.graphPageController = [self getStockGraph:selectedCell.maintextlabel.text];
        self.graphPageController.view.tag = 1;
        [self.stockView insertSubview:self.graphPageController.view belowSubview:self.segmentcontrol];
    }
    else{
        OptionsTableViewController *searchVC = [[OptionsTableViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
        nav.navigationBar.translucent = NO;
        [self presentViewController:nav animated:YES completion:nil];

    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.graphs.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (IBAction)segmentControl:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {
            //GRAPH ORDERS ARE REVERSED...
        case 0:
            [self.graphPageController scrollToRange:kGraphRange5Year];
            break;
        case 1:
            [self.graphPageController scrollToRange:kGraphRange1Year];
            break;
        case 2:
            [self.graphPageController scrollToRange:kGraphRange3Month];
            break;
        case 3:
            [self.graphPageController scrollToRange:kGraphRange1Month];
            break;
        case 4:
            [self.graphPageController scrollToRange:kGraphRange1Week];
            break;
        default:
            break;
    }
}

- (void)backButtonItemToDismissModal{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end

