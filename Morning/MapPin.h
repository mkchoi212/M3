//
//  MapPin.h
//  Morning
//
//  Created by Mike Choi on 1/15/15.
//  Copyright (c) 2015 Life+ Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (assign,nonatomic) NSInteger tag;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle AndCoordinate:(CLLocationCoordinate2D)coordinate tag:(NSInteger)tag;

@end
