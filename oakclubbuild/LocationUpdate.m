//
//  LocationUpdate.m
//  OakClub
//
//  Created by Salm on 11/5/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "LocationUpdate.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationUpdate() <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    BOOL isUpdated;
}
@end

@implementation LocationUpdate
@synthesize delegate;

-(id) init
{
    if (self = [super init])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        isUpdated = YES;
    }
    
    return self;
}

-(void)update
{
    [locationManager startUpdatingLocation];
    isUpdated = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [manager stopUpdatingLocation];
    isUpdated = YES;
    
    if (delegate)
    {
        [delegate location:self updateFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (isUpdated)
    {
        return;
    }
    
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    isUpdated = YES;
    
    // Stop Location Manager
    [manager stopUpdatingLocation];
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"37.785834", @"-122.406417", nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];

    NSLog(@"Coord: %@", params);
    [request setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"POST" path:URL_setLocationUser parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    
    //[delegate location:self updateSuccessWithID:nil andName:nil];
    [operation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Update location: %@", dict);
         if (!e && delegate)
         {
             [delegate location:self updateSuccessWithID:[dict objectForKey:key_data] andName:[dict objectForKey:key_msg]];
         }
         else if (delegate)
         {
             [delegate location:self updateFailWithError:e];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Set user location error Code: %i - %@",[error code], [error localizedDescription]);
         if (delegate)
         {
             [delegate location:self updateFailWithError:error];
         }
     }];
    
    [operation start];
}
@end
