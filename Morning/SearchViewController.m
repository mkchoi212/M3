//
//  SearchViewController.m
//  Today's Stocks
//
//  Created by Noah Martin on 9/22/14.
//
//

#import "SymbolSearch.h"
#import "StockRequest.h"
#import "SearchViewController.h"
#import "CWStatusBarNotification.h"

@interface SearchViewController() <UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults; // Filtered search results
@end

@implementation SearchViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray array];
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.showsCancelButton = YES;
    [self.searchController.searchBar setShowsCancelButton:YES animated:YES];
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString* searchString = [searchController.searchBar text];
    SymbolSearch* search = [[SymbolSearch alloc] init];
    [search lookupSymbol:searchString withBlock:^(NSArray* results) {
        self.searchResults = results;
        [((UITableViewController*) self.searchController.searchResultsController).tableView reloadData];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];

    NSMutableArray *symbols = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"stocks"]];
    if([symbols containsObject:cell.textLabel.text]){
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        CWStatusBarNotification *notification = [[CWStatusBarNotification alloc]init];
        [notification displayNotificationWithMessage:[NSString stringWithFormat:@"'%@' is already on your list", cell.textLabel.text]forDuration:2];
    }
    else{
        [symbols addObject:cell.textLabel.text];
        [[NSUserDefaults standardUserDefaults] setObject:symbols forKey:@"stocks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self postNotificationWithString:[NSNumber numberWithBool:YES]];
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    }

}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DefaultCell"];
    }
    NSDictionary* result = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [result objectForKey:@"symbol"];
    cell.detailTextLabel.text = [result objectForKey:@"name"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (void)postNotificationWithString:(NSNumber *)added //post notification method and logic
{
    NSString *notificationName = @"stockRefresh";
    NSString *key = @"add";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:added forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

@end
