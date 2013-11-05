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
    }
    
    return self;
}

-(void)update
{
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [manager stopUpdatingLocation];
    
    if (delegate)
    {
        [delegate location:self updateFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Stop Location Manager
    [manager stopUpdatingLocation];
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
    NSLog(@"Coord: %@", params);
    
    [delegate location:self updateSuccessWithID:nil andName:nil];
//    [request getPath:URL_setLocationUser parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
//     {
//         NSError *e=nil;
//         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//         NSLog(@"Update location: %@", dict);
//         if (!e && delegate)
//         {
//             [delegate location:self updateSuccessWithID:[dict objectForKey:key_data] andName:[dict objectForKey:key_msg]];
//         }
//         else if (delegate)
//         {
//             [delegate location:self updateFailWithError:e];
//         }
//         
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"Set user location error Code: %i - %@",[error code], [error localizedDescription]);
//         if (delegate)
//         {
//             [delegate location:self updateFailWithError:error];
//         }
//     }];
}
@end
