//
//  Location.m
//  oakclubbuild
//
//  Created by VanLuu on 5/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Location.h"
#import "Define.h"
@implementation Location
-(Location *) initWithNSDictionary: (NSMutableDictionary *) loc{
    Location *location = [Location alloc];
    [location setID:[loc valueForKey:key_locationID]];
    [location setName:[loc valueForKey:key_locationName]];
    [location setCountry:[loc valueForKey:key_locationCountry]];
    [location setCountryCode:[loc valueForKey:key_locationCountryCode]];
    [location setLatitude:[[loc valueForKey:key_coordinatesLatitude] doubleValue]];
    [location setLongitude:[[loc valueForKey:key_coordinatesLongitude] doubleValue]];
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
@end
