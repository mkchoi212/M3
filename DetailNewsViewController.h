//
//  DetailNewsViewController.h
//  Morning
//
//  Created by Mike Choi on 1/10/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface DetailNewsViewController : UIViewController <UINavigationBarDelegate, UINavigationControllerDelegate, UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (weak, nonatomic) NSString *url;
@property (weak, nonatomic) NSURL *correctedLink;
@property (weak, nonatomic) NSString *articleTitle;
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *datitle;
- (IBAction)shareButton:(id)sender;

@end
