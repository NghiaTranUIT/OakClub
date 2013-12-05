//
//  LocationUpdate.h
//  OakClub
//
//  Created by Salm on 11/5/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LocationUpdate : NSObject
-(void)updateWithCompletion:(void(^)(double longitude, double latitude, NSError *e))completion;
-(void)setUserLocationAtLongitude:(double)longitude andLatitude:(double)latitude useCallback:(void(^)(NSString *locationID, NSString *locationName, NSError *err))callback;
@end