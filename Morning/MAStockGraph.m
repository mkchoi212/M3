//
//  MAStockGraph.m
//  MAStockGraph
//

#define circleSize 10
#define labelXaxisOffset 10
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "MAStockGraph.h"

float peak;
float trough;

@interface MAStockGraph ()


@end

@implementation MAStockGraph

int numberOfPoints; // The number of points in the graph
Circle *closestDot;
int currentlyCloser;

- (void)reloadGraph {
    [self setNeedsLayout];
}

- (void)commonInit {
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = CGPointMake(self.frame.size.width  / 2,
                                                       self.frame.size.height / 2);
    _spinner.hidesWhenStopped = YES;
    [self addSubview:_spinner];
    [_spinner startAnimating];

    _labelFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    
    // Defaults
    _animationGraphEntranceSpeed = 15;
    _colorXaxisLabel = [UIColor clearColor];
    
    // Set the bottom color to the window's tint color (if no color is set)
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) _colorBottom = [UIColor colorWithRed:229.0/255.0 green:228.0/255.0 blue:226.0/255.0 alpha:1.0]
;
    else _colorBottom = [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:243.0/255.0 alpha:0.2];
    
    _colorTop = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];
    _colorLine = [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:243.0/255.0 alpha:1];
    _alphaTop = 1.0;
    _alphaBottom = 1.0;
    _alphaLine = 1.0;
    _widthLine = 1.0;
    _enableTouchReport = NO;
    trough = 0;
    peak = 0;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
       [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
       [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    NSLog(@"stocks layourSubviews");
    numberOfPoints = self.numberOfPointsInGraph; // The number of points in the graph
    
    self.animateDelegate = [[Animation alloc] init];
    self.animateDelegate.delegate = self;
    
    [self drawGraph];
    [self drawAxes];
    [self lblCompany];
    
    
    if (self.enableTouchReport == YES) {
        // Initialize the vertical gray line that appears where the user touches the graph.
        self.verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.viewForBaselineLayout.frame.size.height)];
        self.verticalLine.backgroundColor = [UIColor grayColor];
        self.verticalLine.alpha = 0;
        [self addSubview:self.verticalLine];
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.frame.size.width, 40)];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.font = [UIFont systemFontOfSize:28.f];
        self.priceLabel.alpha = 0;
        [self addSubview:self.priceLabel];

        
        UIView *panView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
        panView.backgroundColor = [UIColor clearColor];
        [self.viewForBaselineLayout addSubview:panView];
        
        UILongPressGestureRecognizer *panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.delegate = self;
        [panGesture setMinimumPressDuration:0.4];
        [panView addGestureRecognizer:panGesture];
        

    }
}


- (void)drawGraph {
    // Create graph from stock prices
    
    float maxValue = [self maxValue]; // Biggest Y-axis value from all the prices
    float minValue = [self minValue]; // Smallest Y-axis value from all the prices
    
    float positionOnXAxis; // The position on the X-axis of the point currently being created
    float positionOnYAxis; // The position on the Y-axis of the point currently being created
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[Circle class]])
            [subview removeFromSuperview];
    }
    
    //UIView *holdView = [[UIView alloc] initWithFrame:CGRectMake(0,50,300,150)];
    
    for (int i = 0; i < numberOfPoints; i++) {
        
        float dotValue = [[self.pricesArray objectAtIndex:i] floatValue];
        positionOnXAxis = (self.viewForBaselineLayout.frame.size.width/(numberOfPoints - 1))*i;
        positionOnYAxis = (self.viewForBaselineLayout.frame.size.height - 70) - ((dotValue - minValue) / ((maxValue - minValue) / (self.viewForBaselineLayout.frame.size.height - 70))) + 20;
        
        if (dotValue == maxValue) {
            
            peak = positionOnYAxis + 20;
        } if (dotValue == minValue) {
            
            trough = positionOnYAxis + 20;
        }
#warning crashes here on first launch
        
        Circle *dot = [[Circle alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        dot.center = CGPointMake(positionOnXAxis-10, positionOnYAxis+20);
        dot.tag = i+100;
        dot.alpha = 0.0;
        dot.dollarValue = dotValue;
        [self addSubview:dot];
        
    
        
        // no dots
        // [self.animateDelegate animationForDot:i circleDot:circleDot animationSpeed:self.animationGraphEntranceSpeed];
    }
    
    
    float xDot1 = 0.0; // Postion on the X-axis of the first price
    float yDot1 = 0.0; // Postion on the Y-axis of the first price
    float xDot2 = 0.0; // Postion on the X-axis of the next price
    float yDot2 = 0.0; // Postion on the Y-axis of the next price
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[Line class]])
            [subview removeFromSuperview];
    }
    
    for (int i = 0; i < numberOfPoints - 1; i++) {
        
        for (UIView *dot in [self.viewForBaselineLayout subviews]) {
            if (dot.tag == i + 100)  {
                xDot1 = dot.center.x;
                yDot1 = dot.center.y;
            } else if (dot.tag == i + 101) {
                xDot2 = dot.center.x;
                yDot2 = dot.center.y;
            }
        }
        
        Line *line = [[Line alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
        line.opaque = NO;
        line.tag = i + 1000;
        line.alpha = 0;
        line.backgroundColor = [UIColor clearColor];
        
#pragma warning CRASHES HERE ON FIRST EVER LAUNCH!
        line.firstPoint = CGPointMake(xDot1, yDot1);
        line.secondPoint = CGPointMake(xDot2, yDot2);
        line.topColor = self.colorTop;
        line.bottomColor = self.colorBottom;
        line.color = self.colorLine;
        line.topAlpha = self.alphaTop;
        line.bottomAlpha = self.alphaBottom;
        line.lineAlpha = self.alphaLine;
        line.lineWidth = self.widthLine;
        [self addSubview:line];
        [self sendSubviewToBack:line];
        
        [self.animateDelegate animationForLine:i line:line animationSpeed:self.animationGraphEntranceSpeed];
    }
}

- (void)handlePan:(UILongPressGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:self.viewForBaselineLayout];
    
    self.verticalLine.frame = CGRectMake(translation.x, 0, 1, self.viewForBaselineLayout.frame.size.height);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.verticalLine.alpha = 0.2;
    } completion:nil];
    
    closestDot = [self closestDotFromVerticalLine:self.verticalLine];
    closestDot.alpha = 0.8;
    _priceLabel.alpha = 0.8;

    _priceLabel.text = [NSString stringWithFormat:@"$%.02f", closestDot.dollarValue];

    if (closestDot.tag > 99 && closestDot.tag < 1000) {
        if ([self.delegate respondsToSelector:@selector(didTouchGraphWithClosestIndex:)]) {
            [self.delegate didTouchGraphWithClosestIndex:((int)closestDot.tag - 100)];
        }
    }
    
    // Release
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didReleaseGraphWithClosestIndex:)]) [self.delegate didReleaseGraphWithClosestIndex:(closestDot.tag - 100)];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            closestDot.alpha = 0;
            self.verticalLine.alpha = 0;
            _priceLabel.alpha = 0;
        } completion:nil];
    }
}

// Find which dot is currently the closest to the vertical line
- (Circle *)closestDotFromVerticalLine:(UIView *)verticalLine {
    currentlyCloser = 1000;
    
    for (Circle *dot in self.subviews) {
        
        if (dot.tag > 99 && dot.tag < 1000) {
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                dot.alpha = 0;
            } completion:nil];
            
            if (pow(((dot.center.x) - verticalLine.frame.origin.x), 2) < currentlyCloser) {
                currentlyCloser = pow(((dot.center.x) - verticalLine.frame.origin.x), 2);
                closestDot = dot;
            }
        }
    }
    
    return closestDot;
}

// Determines the biggest Y-axis value from all the prices
- (float)maxValue {
    float dotValue;
    float maxValue = 0;
    
    for (int i = 0; i < numberOfPoints; i++) {
        dotValue = [[self.pricesArray objectAtIndex:i] floatValue];
        
        if (dotValue > maxValue) {
            maxValue = dotValue;
        }
    }
    
    return maxValue;
}

// Determines the smallest Y-axis value from all the prices
- (float)minValue {
    float dotValue;
    float minValue = INFINITY;
    
    for (int i = 0; i < numberOfPoints; i++) {
        dotValue = [[self.pricesArray objectAtIndex:i] floatValue];
        
        if (dotValue < minValue) {
            minValue = dotValue;
        }
    }
    
    return minValue;
}

- (void)lblCompany {
    
    UILabel *topLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 25)];
    topLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    topLbl.textColor = self.colorXaxisLabel;
    topLbl.backgroundColor = [UIColor clearColor];
    topLbl.text = [NSString stringWithFormat:@"%@  $%@", self.companyName, self.stockPrice];
    [topLbl sizeToFit];
    [self addSubview:topLbl];

    UILabel *btmLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 250, 25)];
    btmLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    btmLbl.textColor = self.colorXaxisLabel;
    btmLbl.backgroundColor = [UIColor clearColor];
#warning crashes here
    btmLbl.text = [NSString stringWithFormat:@"%@", self.priceInfo];
    NSLog(@"Stock view debugging: %@", self.priceInfo);
    [btmLbl sizeToFit];
    [self addSubview:btmLbl];
    
    UILabel *midLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 250, 60)];
    midLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    midLbl.textColor = self.colorXaxisLabel;
    midLbl.backgroundColor = [UIColor clearColor];
    midLbl.text = [NSString stringWithFormat:@"%@", self.ticker];
    [midLbl sizeToFit];
    midLbl.alpha = 0.2;
    [midLbl setCenter:CGPointMake(self.frame.size.width  / 2,
                                              self.frame.size.height / 2)];
    
    [self insertSubview:midLbl atIndex:0];
    
    
}
- (void)drawAxes {
   // if (![self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabels)]) return;
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]])
            [subview removeFromSuperview];
    }
    // Draw x axis
    int numberOfGaps = (int)self.numberOfGapsBetweenLabels + 1;
    
    if (numberOfGaps >= (numberOfPoints - 1)) {
        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, self.frame.size.height - (labelXaxisOffset + 10), self.frame.size.width/2, 20)];
        firstLabel.text = [self.datesArray objectAtIndex:0];
        firstLabel.font = self.labelFont;
        firstLabel.textAlignment = 0;
        firstLabel.textColor = self.colorXaxisLabel;
        firstLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:firstLabel];
        
        UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 3, self.frame.size.height - (labelXaxisOffset + 10), self.frame.size.width/2, 20)];
        lastLabel.text = [self.datesArray objectAtIndex:(numberOfPoints - 1)];
        lastLabel.font = self.labelFont;
        lastLabel.textAlignment = 2;
        lastLabel.textColor = self.colorXaxisLabel;
        lastLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:lastLabel];
    } else {
        
        for (int i = 1; i <= (numberOfPoints/numberOfGaps); i++) {
            UILabel *labelXAxis = [[UILabel alloc] initWithFrame:CGRectMake(((self.viewForBaselineLayout.frame.size.width/(numberOfPoints-1))*(i*numberOfGaps - 1))-25, self.frame.size.height - labelXaxisOffset-10, 100, 100)];
            labelXAxis.text =  [self.datesArray objectAtIndex:(i * numberOfGaps - 1)];
            [labelXAxis sizeToFit];
            
#warning CRASHES HERE ON FIRST START
            
            [labelXAxis setCenter:CGPointMake(((self.viewForBaselineLayout.frame.size.width/(numberOfPoints-1))*(i*numberOfGaps - 1))-25, self.frame.size.height - labelXaxisOffset-10)];
            labelXAxis.font = self.labelFont;
            labelXAxis.textAlignment = 1;
            labelXAxis.textColor = self.colorXaxisLabel;
            labelXAxis.backgroundColor = [UIColor clearColor];
            [self addSubview:labelXAxis];
        }
    }
    
    // Draw y axis
    int maxPrice = (int)[self maxValue];
    int minPrice = (int)[self minValue];
    //high price
    UILabel *maxLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    maxLbl.text = [NSString stringWithFormat:@"%i", maxPrice];
    NSLog(@"Stock max price: %i", maxPrice);
    maxLbl.font = self.labelFont;
    maxLbl.textColor = self.colorXaxisLabel;
    maxLbl.backgroundColor = [UIColor clearColor];
    maxLbl.alpha = 0.9;
    [maxLbl sizeToFit];
    maxLbl.center = CGPointMake(self.frame.size.width-(maxLbl.frame.size.width/2), peak);
    [self addSubview:maxLbl];
    // midprice
    UILabel *midLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    midLbl.font = self.labelFont;
    midLbl.textColor = self.colorXaxisLabel;
    midLbl.backgroundColor = [UIColor clearColor];
    midLbl.alpha = 0.9;
    midLbl.text = [NSString stringWithFormat:@"%i", (maxPrice+minPrice)/2];
    [midLbl sizeToFit];
    midLbl.center = CGPointMake(self.frame.size.width-(midLbl.frame.size.width/2), ((trough+peak)/2));
    [self addSubview:midLbl];
    // low price
    UILabel *lowLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    lowLbl.font = self.labelFont;
    lowLbl.textColor = self.colorXaxisLabel;
    lowLbl.backgroundColor = [UIColor clearColor];
    lowLbl.alpha = 0.9;
    lowLbl.text = [NSString stringWithFormat:@"%i", minPrice];
    [lowLbl sizeToFit];
    lowLbl.center = CGPointMake(self.frame.size.width-(lowLbl.frame.size.width/2), trough);
    [self addSubview:lowLbl];
}



@end
