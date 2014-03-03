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
#import "NSDictionary+JSON.h"

@interface LocationUpdate() <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    BOOL isUpdated;
    
    NSMutableArray *callbacks;
}
@end

@implementation LocationUpdate

-(id) init
{
    if (self = [super init])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        isUpdated = YES;
        
        callbacks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)updateWithCompletion:(void (^)(double longi, double lati, NSError *e))completion
{
    [locationManager startUpdatingLocation];
    isUpdated = NO;
    
    [callbacks addObject:completion];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (isUpdated)
    {
        return;
    }
    
    NSLog(@"update location didFailWithError: %@", error);
    [manager stopUpdatingLocation];
    isUpdated = YES;
    
    for (int i = 0; i < callbacks.count; ++i)
    {
        void (^callback)(double longi, double lati, NSError *e) = [callbacks objectAtIndex:i];
        callback(0, 0, error);
    }
    
    [callbacks removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (isUpdated)
    {
        return;
    }
    
    NSLog(@"didUpdateToLocation: %@", newLocation);
    isUpdated = YES;
    
    // Stop Location Manager
    [manager stopUpdatingLocation];
    
    
    for (int i = 0; i < callbacks.count; ++i)
    {
        void (^callback)(double longi, double lati, NSError *e) = [callbacks objectAtIndex:i];
        callback(newLocation.coordinate.longitude, newLocation.coordinate.latitude, nil);
    }
    
    [callbacks removeAllObjects];
    
}

-(void)setUserLocationAtLongitude:(double)longitude andLatitude:(double)latitude useCallback:(void(^)(NSString *locationID, NSString *locationName, NSError *err))callback
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:latitude], [NSNumber numberWithDouble:longitude], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
    NSLog(@"Coord: %@", [params JSONDescription]);
    [request setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"POST" path:URL_setLocationUser parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    
    //[delegate location:self updateSuccessWithID:nil andName:nil];
    [operation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Update location: %@", dict);
         if (!e && callback)
         {
             callback([dict objectForKey:key_data], [dict objectForKey:key_msg], nil);
         }
         else if (callback)
         {
             callback(nil, nil, e);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Set user location error Code: %i - %@",[error code], [error localizedDescription]);
         if (callback) {
             callback(nil, nil, error);
         }
     }];
    
    [operation start];
}
@end
