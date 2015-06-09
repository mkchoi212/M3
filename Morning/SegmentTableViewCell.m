//
//  SegmentTableViewCell.m
//  Morning
//
//  Created by Mike Choi on 6/7/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "SegmentTableViewCell.h"

@implementation SegmentTableViewCell
@synthesize segmentControl = _segmentControl;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
