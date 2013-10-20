//
//  Gender.h
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gender : NSObject<NSCopying>
@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *text;
-(Gender*)initWithID:(int)genderID;
-(Gender*)initWithNSString:(NSString*)genderText;
@end
