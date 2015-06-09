//
//  MapPin.m
//  Morning
//
//  Created by Mike Choi on 1/15/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize tag = _tag;

-(id) initWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle AndCoordinate:(CLLocationCoordinate2D)coordinate tag:(NSInteger)tag{
    
    self = [super init];
    
    _title = title;
    _subtitle = subtitle;
    _coordinate = coordinate;
    _tag = tag;
    
    return self;
}

@end
