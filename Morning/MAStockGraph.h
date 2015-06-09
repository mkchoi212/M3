//
//  MAStockGraph.h
//  MAStockGraph
//


#import <UIKit/UIKit.h>
#import "Circle.h"
#import "Line.h"
#import "Animation.h"

@protocol StockGraphDelegate <NSObject>

@optional

// Touch events
- (void)didTouchGraphWithClosestIndex:(int)index;
- (void)didReleaseGraphWithClosestIndex:(float)index;

@end

@interface MAStockGraph : UIView <UIGestureRecognizerDelegate, AnimationDelegate>

@property (assign) IBOutlet id <StockGraphDelegate> delegate;

@property (strong, nonatomic) Animation *animateDelegate;

@property (strong, nonatomic) UIView *verticalLine;
@property (strong, nonatomic) UILabel *priceLabel;

@property (strong, nonatomic) UIFont *labelFont;



/// Reload the graph
- (void)reloadGraph;



// Customize
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *pricesArray;
@property (nonatomic, strong) NSArray *datesArray;
@property (nonatomic, strong) NSString *ticker;
@property (nonatomic, strong) NSString *priceInfo;
@property (nonatomic, strong) NSString *stockPrice;
@property (nonatomic) NSInteger numberOfGapsBetweenLabels;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic) int numberOfPointsInGraph;
@property (nonatomic) NSInteger animationGraphEntranceSpeed;

@property (nonatomic) BOOL enableTouchReport;

@property (strong, nonatomic) UIColor *colorBottom;

@property (nonatomic) float alphaBottom;

@property (strong, nonatomic) UIColor *colorTop;

@property (nonatomic) float alphaTop;

@property (strong, nonatomic) UIColor *colorLine;

@property (nonatomic) float alphaLine;

@property (nonatomic) float widthLine;

@property (strong, nonatomic) UIColor *colorXaxisLabel;

@end


