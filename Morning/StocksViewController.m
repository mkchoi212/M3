//
//  ViewController.m
//  MAStockGraph
//

#import "StocksViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSLabelPullToRefresh.h"
#import "SearchViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "ModalViewController.h"
#import "StockTableViewCell.h"

@interface StocksViewController ()
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end
@implementation StocksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //notifcation to refresh stocks lis
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(useNotificationWithString:)
     name:@"stockRefresh"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshStockView:)
     name:@"refresh"
     object:nil];
    
    //PULL TO ADD
    
    [self.stockTable ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        int64_t delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [scrollView ins_endPullToRefresh];
            
        });
    }];
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSLabelPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60.0) noneStateText:@"Pull to Add Stocks" triggeredStateText:@"Release to Add Stocks" loadingStateText:@"Loading..."];
    
    self.stockTable.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.stockTable.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
    
}

- (void)loadStocks {
    [self.stockTable reloadData];
}

-(MAStockGraph *)symbolLookup:(NSString *)stockAbbrev atIndex:(NSInteger)index{
    
    MAFinance *stockQuery = [[MAFinance alloc] init];
    MAStockGraph *maV = [[MAStockGraph alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 210)];
    // set the symbol
    stockQuery.symbol = stockAbbrev;
    /* set time period
     MAFinanceTimeFiveDays
     MAFinanceTimeTenDays
     MAFinanceTimeOneMonth
     MAFinanceTimeThreeMonths
     MAFinanceTimeOneYear
     MAFinanceTimeFiveYears
     */
    NSMutableArray *ranges = [[NSUserDefaults standardUserDefaults]objectForKey:@"ranges"];
    NSNumber *selectedRange = [ranges objectAtIndex:index];
    
    switch (selectedRange.integerValue) {
        case 0:
            stockQuery.period = MAFinanceTimeFiveDays;
            break;
        case 1:
            stockQuery.period = MAFinanceTimeTenDays;
            break;
        case 2:
            stockQuery.period = MAFinanceTimeOneMonth;
            break;
        case 3:
            stockQuery.period = MAFinanceTimeThreeMonths;
            break;
        case 4:
            stockQuery.period = MAFinanceTimeOneYear;
            break;
        case 5:
            stockQuery.period = MAFinanceTimeFiveYears;
            break;
        default:
            stockQuery.period = MAFinanceTimeFiveDays;
            [ranges insertObject:[NSNumber numberWithInteger:0] atIndex:index];
            [[NSUserDefaults standardUserDefaults]setObject:ranges forKey:@"ranges"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            break;
    }
    
    
    // fetch the stock from Yahoo Finance
    [stockQuery findStockDataWithBlock:^(NSDictionary *stockData, NSError *error) {
        if (!error) {
            NSLog(@"No error getting stock: %@", stockAbbrev);
            // remove the indicator
            maV.delegate = self;
            // we've got our data
            maV.data = stockData;
            maV.pricesArray = [stockData objectForKey:@"Prices"];
            maV.datesArray = [stockData objectForKey:@"Dates"];
         
            maV.companyName = [[stockData objectForKey:@"StockInformation"] valueForKey:@"Name"];
            maV.ticker = [[stockData objectForKey:@"StockInformation"] valueForKey:@"Symbol"];
            maV.priceInfo = [NSString stringWithFormat:@"%@ (%@)", [[stockData objectForKey:@"StockInformation"]valueForKey:@"Change"], [[stockData objectForKey:@"StockInformation"]valueForKey:@"ChangeinPercent"]];
            maV.stockPrice = [[stockData objectForKey:@"StockInformation"] valueForKey:@"LastTradePriceOnly"];
            maV.numberOfGapsBetweenLabels = 1;
            maV.numberOfPointsInGraph = (int)[maV.pricesArray count];
            maV.backgroundColor = [UIColor colorWithRed:0.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0];
            maV.colorTop = [UIColor clearColor];
            maV.colorBottom = [UIColor clearColor];
            maV.colorLine = [UIColor whiteColor];
            maV.colorXaxisLabel = [UIColor whiteColor];
            maV.widthLine = 1.0;
            maV.enableTouchReport = YES;
            [maV reloadGraph];
            [maV.spinner stopAnimating];
            
        } else {
            // something went wrong, log the error
            NSLog(@"Error getting stock %@ - %@", stockAbbrev, error.localizedDescription);
        }
    }];

    return maV;
    
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *symbols = [[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"];
    
    if(symbols.count == 0){
        UIImage *image = [UIImage imageNamed:@"no_stocks"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.stockTable.contentMode = UIViewContentModeScaleAspectFit;
        self.stockTable.backgroundView = imageView;
        self.stockTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
        self.stockTable.backgroundView = nil;
    
    return symbols.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    StockTableViewCell *cell = (StockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ((cell == nil) || (![cell isKindOfClass:cell.class])){
        cell = [[StockTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *symbols = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"]];
    
    MAStockGraph *loadGraph = [self symbolLookup:[symbols objectAtIndex:indexPath.row] atIndex:indexPath.row];
    cell.daGraph = loadGraph;
    [cell addSubview:loadGraph];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModalViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    StockTableViewCell *selectedStock = (StockTableViewCell *)[self.stockTable cellForRowAtIndexPath:indexPath];
    modalVC.allData = selectedStock.daGraph.data;
    modalVC.arrayIndex = indexPath.row;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.8f;
    self.animator.transitionDuration = 0.7f;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:modalVC.tableView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 230;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= -200) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -200);
    }
}

#pragma mark - dealloc

- (void)dealloc {
    [self.stockTable ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)useNotificationWithString:(NSNotification *)notification //use notification method and logic
{
     NSString *key = @"selectedIndex";
        NSMutableArray *symbols = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"]];
        NSDictionary *dictionary = [notification userInfo];
        NSString *stringValueToUse = [dictionary valueForKey:key];
        if(stringValueToUse != nil){
            [symbols removeObjectAtIndex:[stringValueToUse intValue]];
            [[NSUserDefaults standardUserDefaults] setObject:symbols forKey:@"stocks"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                     [NSIndexPath indexPathForRow:stringValueToUse.intValue inSection:0],
                                     nil];
            [self.stockTable beginUpdates];
            [self.stockTable deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.stockTable endUpdates];
        }
        else{
            NSString *key = @"add";
            NSDictionary *dictionary = [notification userInfo];
            NSNumber *stringValueToUse = [dictionary valueForKey:key];
            if([stringValueToUse isEqualToNumber:[NSNumber numberWithBool:YES]]){
                [self loadStocks];
            }
        }
}



- (void)refreshStockView:(NSNotification *)notification{
    NSLog(@"ASDF");
    NSString *key = @"selectedIndex";
    NSDictionary *dic = [notification userInfo];
    NSString *index = [dic valueForKey:key];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    [self.stockTable beginUpdates];
    [self.stockTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.stockTable endUpdates];
}

@end