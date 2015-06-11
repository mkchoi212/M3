/***********************************************************************************
 *
 * Copyright (c) 2014 Robots and Pencils Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import "RPSlidingMenuCell.h"

const CGFloat RPSlidingCellFeatureHeight = 240.0f;
const CGFloat RPSlidingCellCollapsedHeight = 88.0f;
const CGFloat RPSlidingCellDetailTextPadding = 20.0f;
const CGFloat RPSlidingMenuNormalImageCoverAlpha = 0.5f;
const CGFloat RPSlidingMenuFeaturedImageCoverAlpha = 0.3f;

@interface RPSlidingMenuCell ()

@property (strong, nonatomic) UIView *imageCover;

@end

@implementation RPSlidingMenuCell

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self setupTextLabel];
        [self setupDetailTextLabel];
        [self setupImageView];
        self.read = NO;
    }

    return self;
}


#pragma - mark label and image view setups

// We do this in code so there is no resources to bundle up

- (void)setupTextLabel {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenRect.size.width, self.contentView.frame.size.height)];
    self.textLabel.center = self.contentView.center;
    self.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:32];
    self.textLabel.numberOfLines = 3;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textLabel];
}

- (void)setupDetailTextLabel {

    NSAssert(self.textLabel != nil, @"the text label must be set up before this so it can use its frame");
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat startY = self.textLabel.frame.origin.y + self.textLabel.frame.size.height - 20.0f;
    self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(RPSlidingCellDetailTextPadding, startY, screenRect.size.width - (RPSlidingCellDetailTextPadding * 2), self.contentView.frame.size.height - startY)];
    self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.font = [UIFont  fontWithName:@"TimesNewRomanPSMT" size:12];
    self.detailTextLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.detailTextLabel];
    
    CGFloat startImage = self.newsType.frame.origin.y + self.newsType.frame.size.height+20.0f;
    self.newsType = [[UIImageView alloc]initWithFrame:CGRectMake(RPSlidingCellDetailTextPadding, startImage, 30,30)];
    [self.contentView addSubview:self.newsType];
    
}

- (void)setupImageView {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenRect.size.width, RPSlidingCellFeatureHeight)];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.center = self.contentView.center;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    // add a cover that we can fade in a black tint
    self.imageCover = [[UIView alloc] initWithFrame:self.backgroundImageView.frame];
    self.imageCover.backgroundColor = [UIColor blackColor];
    self.imageCover.alpha = 0.6f;
    self.imageCover.autoresizingMask = self.backgroundImageView.autoresizingMask;
    [self.backgroundImageView addSubview:self.imageCover];
    [self.contentView insertSubview:self.backgroundImageView atIndex:0];
    [self.contentView insertSubview:self.imageCover atIndex:1];
    
    self.readImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenRect.size.width, RPSlidingCellFeatureHeight)];
    self.readImage.clipsToBounds = YES;
    self.readImage.center = self.contentView.center;
    self.readImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.checkMark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width/4, screenRect.size.width/4)];
    self.checkMark.center = self.contentView.center;
    self.checkMark.clipsToBounds = YES;
    self.checkMark.contentMode = UIViewContentModeScaleAspectFit;
    
}


- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {

    [super applyLayoutAttributes:layoutAttributes];
    
    CGFloat featureNormaHeightDifference = RPSlidingCellFeatureHeight - RPSlidingCellCollapsedHeight;

    // how much its grown from normal to feature
    CGFloat amountGrown = RPSlidingCellFeatureHeight - self.frame.size.height;
    
    // percent of growth from normal to feature
    CGFloat percentOfGrowth = 1 - (amountGrown / featureNormaHeightDifference);
    
    //Curve the percent so that the animations move smoother
    percentOfGrowth = sin(percentOfGrowth * M_PI_2);
    
    CGFloat scaleAndAlpha = MAX(percentOfGrowth, 0.5f);

    // scale title as it collapses but keep origin x the same and the y location proportional to view height.  Also fade in alpha
    self.textLabel.transform = CGAffineTransformMakeScale(scaleAndAlpha, scaleAndAlpha);
    self.textLabel.center = self.contentView.center;
    self.checkMark.transform = CGAffineTransformMakeScale(scaleAndAlpha, scaleAndAlpha);
    self.checkMark.center = self.contentView.center;

    // keep detail just under text label
    self.detailTextLabel.center = CGPointMake(self.center.x, self.textLabel.center.y + 40.0f);

    // its convenient to set the alpha of the fading controls to the percent of growth value
    self.detailTextLabel.alpha = percentOfGrowth;
    
    // when full size, alpha of imageCover should be 20%, when collapsed should be 90%
    self.imageCover.alpha = RPSlidingMenuNormalImageCoverAlpha - (percentOfGrowth * (RPSlidingMenuNormalImageCoverAlpha - RPSlidingMenuFeaturedImageCoverAlpha));
}

-(void)newsRead{
    self.readImage.image = [UIImage imageNamed:@"readbackground"];
    [self.contentView insertSubview:self.readImage aboveSubview:self.detailTextLabel];

    
    self.checkMark.image = [UIImage imageNamed:@"check"];
    self.checkMark.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [self.contentView insertSubview:self.checkMark aboveSubview:self.readImage];
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.checkMark.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.checkMark.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.checkMark.transform = CGAffineTransformIdentity;
            }];
        }];
    }];

}

- (void)setRead:(BOOL)read {
    if (read == YES) {
        [self newsRead];
    } else {
        [self.readImage removeFromSuperview];
        [self.checkMark removeFromSuperview];
    }
}

@end
