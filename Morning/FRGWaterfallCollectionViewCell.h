//
//  FRGWaterfallCollectionViewCell.h
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersManager.h"

@interface FRGWaterfallCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


- (void) updateCell:(EKReminder *)reminder;
@end
