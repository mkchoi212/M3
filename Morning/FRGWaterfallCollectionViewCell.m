//
//  FRGWaterfallCollectionViewCell.m
//  WaterfallCollectionView
//
//  Created by Miroslaw Stanek on 12.07.2013.
//  Copyright (c) 2013 Event Info Ltd. All rights reserved.
//

#import "FRGWaterfallCollectionViewCell.h"

@interface FRGWaterfallCollectionViewCell()

@end

@implementation FRGWaterfallCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}


- (void) updateCell:(EKReminder *)reminder {
    self.lblTitle.text = reminder.title;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblTitle.adjustsFontSizeToFitWidth = YES;
    //self.notesLabel.text = reminder.notes;
    //self.idLabel.text = [reminder.URL  path];
    
    if([reminder hasAlarms]) {
        EKAlarm *alarm = [reminder.alarms objectAtIndex:0];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm"];
        
        self.dateLabel.text = [df stringFromDate:[alarm absoluteDate]];
    }
    else {
        self.dateLabel.text = nil;
    }
}

@end
