//
//  Location.m
//  oakclubbuild
//
//  Created by VanLuu on 5/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Location.h"
#import "Define.h"
#import <CoreLocation/CoreLocation.h>

@implementation Location
-(Location *) initWithNSDictionary: (NSMutableDictionary *) loc{
    Location *location = [Location alloc];
    [location setID:[loc valueForKey:key_locationID]];
    [location setName:[loc valueForKey:key_locationName]];
    [location setCountry:[loc valueForKey:key_locationCountry]];
    [location setCountryCode:[loc valueForKey:key_locationCountryCode]];
    NSMutableDictionary *coord = [loc valueForKey:key_locationCoordinates];
    [location setLatitude:[[coord valueForKey:key_coordinatesLatitude] doubleValue]];
    [location setLongitude:[[coord valueForKey:key_coordinatesLongitude] doubleValue]];
    NSLog(@"%@", loc);
    return location;
}
-(Location *) initWithNSDictionaryFromFB:(NSMutableDictionary *)loc
{
    Location *location = [Location alloc];
    [location setID:[loc valueForKey:key_locationID]];
    [location setName:[loc valueForKey:key_locationName]];
    [location setCountry:[loc valueForKey:key_locationCountry]];
    [location setCountryCode:[loc valueForKey:key_locationCountryCode]];
    NSMutableDictionary *coord = [loc valueForKey:key_locationCoordinates];
    [location setLatitude:[[coord valueForKey:key_coordinatesLatitude] doubleValue]];
    [location setLongitude:[[coord valueForKey:key_coordinatesLongitude] doubleValue]];
    NSLog(@"%@", loc);
    return location;
}

-(id) copyWithZone: (NSZone *) zone{
    Location *copyObj = [[Location allocWithZone: zone] init];
    copyObj.ID = self.ID;
    copyObj.name = [self.name copyWithZone:zone];
    copyObj.country = [self.country copyWithZone:zone];
    copyObj.countryCode = [self.countryCode copyWithZone:zone];
    copyObj.latitude = self.latitude;
    copyObj.longitude = self.longitude;
    return copyObj;
}

+(double)getDistanceFromLongitude:(double)frLong latitude:(double)frLat toLongitude:(double)toLong latitude:(double)toLat
{
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:frLat longitude:frLong];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:toLat longitude:toLong];
    
    return [loc1 distanceFromLocation:loc2];
}
@end
