//
//  CalendarController.m
//  hackathonWeather
//
//  Created by Lucas Farah on 9/19/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

#import "CalendarController.h"
@import EventKit;
@import EventKitUI;
@import MapKit;
@implementation CalendarController


- (CLLocationCoordinate2D)getLocation:(NSString *)address {
  
  CLLocationCoordinate2D center;
  NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
  NSData *responseData = [[NSData alloc] initWithContentsOfURL:
                          [NSURL URLWithString:req]];    NSError *error;
  NSMutableDictionary *responseDictionary = [NSJSONSerialization
                                             JSONObjectWithData:responseData
                                             options:nil
                                             error:&error];
  if( error )
  {
    NSLog(@"%@", [error localizedDescription]);
    center.latitude = 0;
    center.longitude = 0;
    return center;
  }
  else {
    NSArray *results = (NSArray *) responseDictionary[@"results"];
    NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:0];
    NSDictionary *geometry = (NSDictionary *) [firstItem objectForKey:@"geometry"];
    NSDictionary *location = (NSDictionary *) [geometry objectForKey:@"location"];
    NSNumber *lat = (NSNumber *) [location objectForKey:@"lat"];
    NSNumber *lng = (NSNumber *) [location objectForKey:@"lng"];
    
    center.latitude = [lat doubleValue];
    center.longitude = [lng doubleValue];
    return center;
  }
}
//-(void)getAddress
//{
//  NSDate *start = [NSDate dateWithTimeIntervalSinceNow:0];
//  NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:86400];
//  
//  // use Dictionary for remove duplicates produced by events covered more one year segment
//  NSMutableDictionary *eventsDict = [NSMutableDictionary dictionaryWithCapacity:1024];
//  
//  NSDate* currentStart = [NSDate dateWithTimeInterval:0 sinceDate:start];
//  
//  int seconds_in_year = 60*60*24;
//  
//  // enumerate events by one year segment because iOS do not support predicate longer than 4 year !
//  //    while ([currentStart compare:finish] == NSOrderedAscending) {
//  
//  NSDate* currentFinish = [NSDate dateWithTimeInterval:seconds_in_year sinceDate:currentStart];
//  
//  if ([currentFinish compare:finish] == NSOrderedDescending) {
//    currentFinish = [NSDate dateWithTimeInterval:0 sinceDate:finish];
//  }
//  EKEventStore *eventStore = [[EKEventStore alloc] init];
//  // Get the appropriate calendar
//  NSCalendar *calendar = [NSCalendar currentCalendar];
//  
//  // Create the start date components
//  NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//  oneDayAgoComponents.day = -1;
//  NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:0];
//  
//  // Create the end date components
//  NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//  oneYearFromNowComponents.year = 1;
//  NSDate *oneYearFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
//  
//  // Create the predicate from the event store's instance method
//  NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:oneDayAgo
//                                                               endDate:oneYearFromNow
//                                                             calendars:nil];
//  
//  // Fetch all events that match the predicate
//  NSArray *events = [eventStore eventsMatchingPredicate:predicate];
//  EKEvent *nextEvent = events[0];
//  NSSTrnextEventAddress = nextEvent.location;
//  NSLog(@"%@",nextEventAddress);
//  
//}
@end
