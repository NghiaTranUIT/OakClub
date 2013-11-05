//
//  LocationUpdate.h
//  OakClub
//
//  Created by Salm on 11/5/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationUpdate;

@protocol LocationUpdateDelegate

-(void)location:(LocationUpdate*)location updateSuccessWithID:(NSString*)locationID andName:(NSString *)name;
-(void)location:(LocationUpdate*)location updateFailWithError:(NSError *)e;

@end

@interface LocationUpdate : NSObject
@property id<LocationUpdateDelegate> delegate;
-(void)update;
@end
