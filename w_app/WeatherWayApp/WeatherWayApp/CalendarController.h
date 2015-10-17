//
//  CalendarController.h
//  hackathonWeather
//
//  Created by Lucas Farah on 9/19/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//
@import CoreLocation;
#import <Foundation/Foundation.h>

@interface CalendarController : NSObject
- (CLLocationCoordinate2D)getLocation:(NSString *)address;
@end
