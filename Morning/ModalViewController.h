//
//  ModalViewController.h
//  ZFModalTransitionDemo
//
//  Created by Amornchai Kanokpullwad on 6/4/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *stockName;
@property (strong, nonatomic) NSDictionary *allData;
@property (nonatomic) NSInteger arrayIndex;

@end
