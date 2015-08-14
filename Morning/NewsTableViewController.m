//
//  NewsTableViewController.m
//  
//
//  Created by Mike Choi on 6/27/15.
//
//

#import "NewsTableViewController.h"
#import "ArticleTableViewCell.h"
#import "NSDate+HumanizedTime.h"
#import "DetailNewsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>

@interface NewsTableViewController() {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *date;
    NSMutableString *media;
    NSString *element;
    NSString *categoryName;
}
@property (nonatomic, weak) NSIndexPath *readIDX;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NewsTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.editing = NO;
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://rss.cnn.com/rss/cnn_topstories.rss"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"%li", (long)self.readIDX.row);
    NSIndexPath *selectedidx = [NSIndexPath indexPathForRow:self.readIDX.row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[selectedidx] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark Tableview Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if (!cell) {
        cell = [[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    [cell.shareButton addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkmark.alpha = 0.0;
    NSString *title = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    NSString *orgdate = [[feeds objectAtIndex:indexPath.row] objectForKey: @"pubDate"];
    NSString *thumbnail = [[[feeds objectAtIndex:indexPath.row] objectForKey: @"media:thumbnail"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"E, dd MMM yyyy HH:mm:ss zzz"];    //Sat, 27 Jun 2015 12:13:40 EDT
    NSTimeZone *zone = [[NSTimeZone alloc]initWithName:@"UTC"];
    [dateFormatter setTimeZone: zone];
    NSDate *date = [dateFormatter dateFromString:orgdate];
    
    cell.articleName.text = [[[feeds objectAtIndex:indexPath.row] objectForKey: @"title"] uppercaseString];
    cell.categoryLabel.text = [NSString stringWithFormat:@"%@", [date stringWithHumanizedTimeDifference:NSDateHumanizedSuffixAgo withFullString:YES]];
    
    [cell.articlePicture sd_setImageWithURL:[NSURL URLWithString:thumbnail]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [UIView animateWithDuration:2.0 animations:^{
                                     cell.articlePicture.image = image;
                                     cell.articlePicture.alpha = 1.0;
                                 }];
                             }];
  
    
        NSMutableArray *readArticles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"read"]];
    if([readArticles containsObject:title]){
        cell.checkmark.alpha = 0.8;
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 148.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    DetailNewsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    NSString *urlString = [feeds[indexPath.row] objectForKey: @"feedburner:origLink"];
    NSString *name = [feeds[indexPath.row] objectForKey:@"title"];
    
    //save article name once pressed
    NSMutableArray *readArticles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"read"]];
    if (![readArticles containsObject:name]) {
        [readArticles addObject:name];
        [[NSUserDefaults standardUserDefaults] setObject:readArticles forKey:@"read"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.readIDX = indexPath;
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    detail.url = urlString;
    detail.articleTitle = name;
    [self presentViewController:detail animated:YES completion:nil];
}


#pragma mark RSS FEED PARSER
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        date    = [[NSMutableString alloc] init];
        
    }
    if ( [element isEqualToString:@"media:thumbnail"] )
    {
        media = [[NSMutableString alloc] initWithString:[attributeDict valueForKey:@"url"]];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"feedburner:origLink"];
        [item setObject:date forKey:@"pubDate"];
        [item setObject:media forKey:@"media:thumbnail"];
        [feeds addObject:[item copy]];
    }
    
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"feedburner:origLink"]) {
        [link appendString:string];
    }
    else if ([element isEqualToString:@"pubDate"]) {
        [date appendString:string];
    }
    else if ([element isEqualToString:@"media:thumbnail"]) {
        [media appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.tableView reloadData];
}


- (void)sharePressed:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil){
        NSString *textToShare = [[feeds objectAtIndex:indexPath.row]objectForKey:@"title"];
        NSString *urlString = [feeds[indexPath.row] objectForKey: @"feedburner:origLink"];
        NSString *orgdate = [[feeds objectAtIndex:indexPath.row] objectForKey: @"pubDate"];
        NSArray *objectsToShare = @[textToShare, urlString, orgdate];
        UIActivityViewController *shareVC = [[UIActivityViewController alloc]initWithActivityItems:objectsToShare applicationActivities:nil];
        shareVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo, UIActivityTypeSaveToCameraRoll, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr];
        [self presentViewController:shareVC animated:YES completion:nil];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


@end
