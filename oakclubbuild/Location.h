//
//  Location.h
//  oakclubbuild
//
//  Created by VanLuu on 5/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject<NSCopying>{
    
}
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *countryCode;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
-(Location *) initWithNSDictionary: (NSMutableDictionary *) loc;
@end
