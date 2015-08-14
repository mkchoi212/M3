//
//  ArticleTableViewCell.m
//  
//
//  Created by Mike Choi on 6/27/15.
//
//

#import "ArticleTableViewCell.h"

@implementation ArticleTableViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.articlePicture.clipsToBounds = YES;
    self.articlePicture.layer.cornerRadius = 8.0f;
    _checkmark.alpha = 0.0;
}

@end
