//
//  StocksViewController.h
//  
//
//  Created by Mike Choi on 3/3/15.
//
//
//
//  ViewController.h
//  MAStockGraph
//


#import <UIKit/UIKit.h>
#import "MAFinance.h"
#import "MAStockGraph.h"


@interface StocksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, StockGraphDelegate>

@property (strong, nonatomic) IBOutlet UITableView *stockTable;

- (void)loadStocks;

@end
