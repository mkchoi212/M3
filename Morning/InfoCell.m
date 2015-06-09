//
//  InfoCell.m
//  RemindersViewer
//
//  Created by Phillipus on 10/10/2012.
//  Copyright (c) 2012 Dada Beatnik. All rights reserved.
//

#import "InfoCell.h"

@interface InfoCell ()

@end

@implementation InfoCell

- (void) updateCell:(EKReminder *)reminder {
    self.titleLabel.text = reminder.title;
    //self.notesLabel.text = reminder.notes;
    //self.idLabel.text = [reminder.URL  path];
    
    if([reminder hasAlarms]) {
        EKAlarm *alarm = [reminder.alarms objectAtIndex:0];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm"];
        
        self.timeLabel.text = [df stringFromDate:[alarm absoluteDate]];
    }
    else {
        self.timeLabel.text = nil;
    }
}

- (id)debugQuickLookObject
{
    NSAttributedString *cr = [[NSAttributedString alloc] initWithString:@""];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:self.titleLabel.attributedText];
    [result appendAttributedString:cr];
    [result appendAttributedString:self.titleLabel.attributedText];
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

@end
