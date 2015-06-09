//
//  InfoCell.h
//  RemindersViewer
//
//  Created by Phillipus on 10/10/2012.
//  Copyright (c) 2012 Dada Beatnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersManager.h"
#import "BFPaperCheckbox.h"

@interface InfoCell : UITableViewCell <BFPaperCheckboxDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet BFPaperCheckbox *checkBox;
- (void) updateCell:(EKReminder *)reminder;

@end
