//
//  StockTableViewCell.m
//  Morning
//
//  Created by Mike Choi on 6/18/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "StockTableViewCell.h"

@implementation StockTableViewCell
@synthesize maintextlabel, stockPercentageLabel, stockValueLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
