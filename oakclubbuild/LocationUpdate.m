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
    isUpdated = YES;
    if (delegate)
    {
        [delegate location:self updateSuccessWithLongitude:newLocation.coordinate.longitude andLatitude:newLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [manager stopUpdatingLocation];
    
}

-(void)setUserLocationAtLongitude:(double)longitude andLatitude:(double)latitude useCallback:(void(^)(NSString *locationID, NSString *locationName, NSError *err))callback
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:latitude], [NSNumber numberWithDouble:longitude], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
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
