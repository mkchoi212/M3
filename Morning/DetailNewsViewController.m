//
//  DetailNewsViewController.m
//  Morning
//
//  Created by Mike Choi on 1/10/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "DetailNewsViewController.h"
#import "NJKWebViewProgressView.h"
@interface DetailNewsViewController () <NSURLSessionTaskDelegate>{
    IBOutlet __weak UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL _sessionChecked;

}
@property (strong, nonatomic)NSURL *myUrl;

@end

@implementation DetailNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subtitle.text = self.url;
    self.datitle.text = self.articleTitle;
    
    //fixing corrupt URL from RSS feed...
    NSString *correctedString = [self.url stringByReplacingOccurrencesOfString:@".html\n" withString:@".html?\n"];
    self.myUrl = [NSURL URLWithString: [correctedString stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_myUrl];

    [_webView loadRequest:request];
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigaitonBarBounds = self.navbar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navbar addSubview:_progressView];
    _sessionChecked = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_progressView removeFromSuperview];
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)shareButton:(id)sender {
    NSString *prompt = @"\nCheck this article I found on an app called 'Morning'";
    NSArray *activityItems = @[self.myUrl, prompt];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

@end
