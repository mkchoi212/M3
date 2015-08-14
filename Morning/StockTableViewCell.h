//
//  StockTableViewCell.h
//  Morning
//
//  Created by Mike Choi on 6/18/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *maintextlabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockValueLabel;
@end
