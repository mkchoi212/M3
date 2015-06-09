//
//  NoIntViewController.m
//  Morning
//
//  Created by Mike Choi on 3/1/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "NoIntViewController.h"

@interface NoIntViewController ()

@end

@implementation NoIntViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)refresh:(id)sender {
    NSString *notificationName = @"refresh";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}
@end
