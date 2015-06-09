//
//  Venue.m
//  CoffeeKit
//
//  Created by Scott McAlister on 1/21/14.
//  Copyright (c) 2014 4 Arrows Media, LLC. All rights reserved.
//

#import "Venue.h"

@implementation Venue

-(NSComparisonResult)compareDistance:(Venue *)otherObject{
    return [self.location.distance compare:otherObject.location.distance];
}

-(NSComparisonResult)compareStats:(Venue *)otherObject{
    return [self.stats.checkins compare:otherObject.stats.checkins];
}
@end