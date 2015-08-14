//
//  OptionsTableViewController.m
//  Morning
//
//  Created by Mike Choi on 6/21/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "SearchViewController.h"
@interface OptionsTableViewController ()

@property (nonatomic, strong) NSMutableArray *stocks;
@end

@implementation OptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Stocks";
    self.stocks = [[[NSUserDefaults standardUserDefaults]objectForKey:@"stocks"]mutableCopy];
    self.tableView.editing = YES;
    self.navigationController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(bringupStocks)];

     self.navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemStop) target:self action:@selector(backButtonItemToDismissModal)];
}

- (void)viewDidAppear:(BOOL)animated{
    self.stocks = [[[NSUserDefaults standardUserDefaults]objectForKey:@"stocks"]mutableCopy];
    [self.tableView reloadData];
    
}
#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.stocks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = self.stocks[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSString *itemtoMove = self.stocks[sourceIndexPath.row];
    
    [self.stocks removeObjectAtIndex:sourceIndexPath.row];
    [self.stocks insertObject:itemtoMove atIndex:destinationIndexPath.row];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.stocks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)bringupStocks{
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)backButtonItemToDismissModal{
    [[NSUserDefaults standardUserDefaults]setObject:self.stocks forKey:@"stocks"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
