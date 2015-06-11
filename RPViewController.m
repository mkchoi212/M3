//
//  RPViewController.m
//  RPSlidingMenuDemo
//
//  Created by Paul Thorsteinson on 2/24/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "RPViewController.h"
#import "DetailNewsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+HumanizedTime.h"

@interface RPViewController () <UIScrollViewDelegate>{
    NSXMLParser *parser;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *date;
    NSString *element;
    NSInteger selectedItem;
    NSMutableArray *search;
    NSMutableArray *resultArray;
    NSString *categoryName;
    
}

@property (strong, nonatomic) NSMutableArray *imageLinks;
@end

@implementation RPViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _feeds = [[NSMutableArray alloc] init];
    NSString *urlString = @"http://rss.cnn.com/rss/";
    NSArray *newsSettings = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"news"]];
    for(NSInteger i = 0; i < newsSettings.count; ++i){
        if([[newsSettings objectAtIndex:i] isEqualToNumber:[NSNumber numberWithBool:YES]]){
            switch (i) {
                case 0:
                    urlString = [urlString stringByAppendingString:@"cnn_topstories.rss"];
                    break;
                case 1:
                    urlString = [urlString stringByAppendingString:@"cnn_world.rss"];
                    break;
                case 2:
                    urlString = [urlString stringByAppendingString:@"cnn_US.rss"];
                    break;
                case 3:
                    urlString = [urlString stringByAppendingString:@"money_latest.rss"];
                    break;
                case 4:
                    urlString = [urlString stringByAppendingString:@"cnn_allpolitics.rss"];
                    break;
                case 5:
                    urlString = [urlString stringByAppendingString:@"edition_sport.rss"];
                    break;
                case 6:
                    urlString = [urlString stringByAppendingString:@"cnn_tech.rss"];
                    break;
                case 7:
                    urlString = [urlString stringByAppendingString:@"cnn_showbiz.rss"];
                    break;
                default:
                    break;
            }
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    //[self parseImageUrlFromJSON];
    //[self.collectionView reloadData];
    UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bck"]];
    back.contentMode = UIViewContentModeScaleAspectFit;
    self.collectionView.backgroundView = back;
    
}

#pragma mark DOWNLOAD IMAGES
- (void)composeURL:(void (^)(BOOL done))completion
{
    search = [[NSMutableArray alloc] init];
    for (int i = 0; i<_feeds.count; i++){
        NSString *query;
        NSString *query1 = [[_feeds objectAtIndex:i] objectForKey: @"title"];
        NSString *query2 = [query1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        query = [query2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *cnn = @"+cnn";
        NSString *temp = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@%@&start=1&rsz=1", query, cnn];
        NSString *temp1 = [temp stringByReplacingOccurrencesOfString:@"'" withString:@""];
        NSString *urlString = [temp1 stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString* webStringURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:webStringURL];
        [search addObject:url];
        if (search.count == _feeds.count) {
            completion(true);
        }
    }
}

- (void)parseJSON:(void (^)(BOOL done))completion
{
    [self composeURL:^(BOOL done) {
        if (done == true) {
            //if(7!=0){
                resultArray = [[NSMutableArray alloc]init];
                for (int i = 0; i <_feeds.count; ++i){
                    NSURL *url = [search objectAtIndex:i];
                    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    [resultArray addObject:resultObject];
                }
            //}
            completion(true);
        }
    }];
}

-(void)parseImageUrlFromJSON
{
    [self parseJSON:^(BOOL done) {
        if (done == true ) {
            self.imageLinks = [[NSMutableArray alloc] init];
            for (int i = 0; i<_feeds.count; ++i){
                NSDictionary *dict = [resultArray objectAtIndex:i];
                if (dict) {
                    if ([[dict objectForKey:@"responseStatus"] intValue] != 403) {
                        NSArray *jsonArray = [[dict objectForKey:@"responseData"] objectForKey:@"results"];
                        if (jsonArray) {
                            for (NSDictionary *jsonDict in jsonArray) {
                                if (jsonDict) {
                                    NSString *imageURL = [jsonDict objectForKey:@"url"];
                                    [self.imageLinks addObject:imageURL];
                                }
                            }
                        }
                    }
                } 
            }
        }
    }];
}

- (void)dsparse
{
    self.imageLinks = [[NSMutableArray alloc] init];
    for (int i = 0; i<_feeds.count; i++){
        NSString *query = [[_feeds objectAtIndex:i] objectForKey: @"title"];
        query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        query = [query stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        query = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@+cnn&start=1&rsz=1", query];
        query = [query stringByReplacingOccurrencesOfString:@"'" withString:@""];
        query = [query stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *webStringURL = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:webStringURL];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                NSError *error;
                id dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (dict) {
                    if ([[dict objectForKey:@"responseStatus"] intValue] != 403) {
                        NSArray *jsonArray = [[dict objectForKey:@"responseData"] objectForKey:@"results"];
                        if (jsonArray) {
                            for (NSDictionary *jsonDict in jsonArray) {
                                if (jsonDict) {
                                    NSString *imageURL = [jsonDict objectForKey:@"url"];
                                    [self.imageLinks addObject:imageURL];
                                } else {
                                    [self.imageLinks addObject:@""];
                                }
                            }
                        } else {
                            [self.imageLinks addObject:@""];
                        }
                    } else {
                        [self.imageLinks addObject:@""];
                    }
                } else {
                    [self.imageLinks addObject:@""];
                }
                if (i == _feeds.count -1) {
                    [self.collectionView reloadData];
                }
            }
        }];
    }
}

#pragma mark RSS FEED SETUP

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        date    = [[NSMutableString alloc] init];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"feedburner:origLink"];
        [item setObject:date forKey:@"pubDate"];
        
        [_feeds addObject:[item copy]];
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
    
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    //[self parseImageUrlFromJSON];
    [self dsparse];
    
    
}

#pragma mark - RPSlidingMenuViewController


-(NSInteger)numberOfItemsInSlidingMenu{
    return _feeds.count;
}

- (void)customizeCell:(RPSlidingMenuCell *)slidingMenuCell forRow:(NSInteger)row{
    
    NSString *url = nil;
    
    if (self.imageLinks.count > 0) {
        url = [self.imageLinks objectAtIndex:row];
    }

    [slidingMenuCell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"black"] completed:nil];
    slidingMenuCell.textLabel.text = [[_feeds objectAtIndex:row] objectForKey: @"title"];
    slidingMenuCell.detailTextLabel.text = [[_feeds objectAtIndex:row] objectForKey: @"pubDate"];
    
    categoryName = [_feeds[row] objectForKey: @"feedburner:origLink"];
    
    if([categoryName containsString:@"/world/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"globe"];
    else if([categoryName containsString:@"/us/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"us"];
    else if([categoryName containsString:@"/politics/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"politics"];
    else if([categoryName containsString:@"/asia/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"asia"];
    else if([categoryName containsString:@"/entertainment/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"entertainment"];
    else if([categoryName containsString:@"/tech/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"tech"];
    else if([categoryName containsString:@"/finance/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"finance"];
     else if([categoryName containsString:@"/sport/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"sports"];
    else if([categoryName containsString:@"/travel/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"travel"];
    else if([categoryName containsString:@"/living/"])
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"living"];
    else
        slidingMenuCell.newsType.image = [UIImage imageNamed:@"top"];
    
    slidingMenuCell.read = [[[NSUserDefaults standardUserDefaults] objectForKey:@"read"] containsObject:_feeds[row]];
    

    
}
- (void)slidingMenu:(RPSlidingMenuViewController *)slidingMenu didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    [super slidingMenu:slidingMenu didSelectItemAtIndexPath:indexPath];

    
    // when a row is tapped do some action
    selectedItem = indexPath.row;
    DetailNewsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    NSString *urlString = [_feeds[selectedItem] objectForKey: @"feedburner:origLink"];
    NSString *name = [_feeds[selectedItem] objectForKey:@"title"];
    
    //save article name once pressed
    NSMutableArray *searchSettings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"read"]];
    if (![searchSettings containsObject:_feeds[selectedItem]]) {
        [searchSettings addObject:_feeds[selectedItem]];
        [[NSUserDefaults standardUserDefaults] setObject:searchSettings forKey:@"read"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    
    
    detail.url = urlString;
    detail.articleTitle = name;
    [self presentViewController:detail animated:YES completion:nil];
    
    
}


@end
