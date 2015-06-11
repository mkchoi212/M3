//
//  ForcedViewController.m
//  ForcedRotation
//
//  Created by Tom Parry on 15/11/12.
//  Copyright (c) 2012 b2cloud. All rights reserved.

// http://www.jsonline.com/rss?c=y&path=/news

#import "ForcedViewController.h"
#import "PWParallaxScrollView.h"

@interface ForcedViewController () <PWParallaxScrollViewDataSource, PWParallaxScrollViewDelegate> {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSString *element;
}

@property (nonatomic, strong) PWParallaxScrollView *scrollView;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation ForcedViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    feeds = [[NSMutableArray alloc]init];
    NSURL *url = [NSURL URLWithString:@"http://hosted.ap.org/lineups/TOPHEADS.rss?SITE=AP&SECTION=HOME"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    [feeds insertObject:@"10 THINGS TO KNOW FOR TODAY" atIndex:0];
    
    [self initControl];
    [self reloadData];
}

-(IBAction)prev:(id)sender
{
    [_scrollView prevItem];
}

- (IBAction)next:(id)sender
{
    [_scrollView nextItem];
}

- (IBAction)jumpToItem:(id)sender
{
    [_scrollView moveToIndex:0];
}

#pragma mark - PWParallaxScrollViewSource

- (NSInteger)numberOfItemsInScrollView:(PWParallaxScrollView *)scrollView
{
    self.pageControl.numberOfPages = [feeds count];
    return self.pageControl.numberOfPages;
}

- (UIView *)backgroundViewAtIndex:(NSInteger)index scrollView:(PWParallaxScrollView *)scrollView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor blackColor];
    return imageView;
}

- (UIView *)foregroundViewAtIndex:(NSInteger)index scrollView:(PWParallaxScrollView *)scrollView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
 
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, screenHeight, screenWidth)];

    if(index == 0){
        label.text = [feeds objectAtIndex:0];
        [label setAlpha:1.0f];
        [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:200]];
        [label setUserInteractionEnabled:NO];
    }
    else{
        label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, screenHeight-120, screenWidth)];
        NSString *title = [[feeds objectAtIndex:index] objectForKey: @"title"];
        label.textColor = [UIColor whiteColor];
        [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:250]];
        [label setUserInteractionEnabled:YES];
        label.text = [title uppercaseString];
    }
    
    label.adjustsFontSizeToFitWidth=YES;
    label.numberOfLines = 0;
    [label setBackgroundColor:[UIColor blackColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentNatural];

    
    return label;
}

- (void)test
{
    NSLog(@"hit test");
}

#pragma mark - PWParallaxScrollViewDelegate

- (void)parallaxScrollView:(PWParallaxScrollView *)scrollView didChangeIndex:(NSInteger)index
{
    _pageControl.currentPage = index;
}

- (void)parallaxScrollView:(PWParallaxScrollView *)scrollView didEndDeceleratingAtIndex:(NSInteger)index
{
    
}

#pragma mark - view's life cycle

- (void)initControl
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.scrollView = [[PWParallaxScrollView alloc]initWithFrame:CGRectMake(0, 0, screenHeight , screenWidth)];
    _scrollView.foregroundScreenEdgeInsets = UIEdgeInsetsZero;
    [self.view insertSubview:_scrollView atIndex:0];
}

- (void)reloadData
{
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (toInterfaceOrientation==UIInterfaceOrientationPortrait) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc]init];

    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        [item setObject:link forKey:@"description"];
        [feeds addObject:[item copy]];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [link appendString:string];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
