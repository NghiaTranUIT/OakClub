//
//  Ethnicity.h
//  OakClub
//
//  Created by VanLuu on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ethnicity : NSObject
@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *name;
-(Ethnicity*)initWithID:(int)ethnicityID andName:(NSString*)nameText;
-(Ethnicity*) initWithID:(int)ethnicityID;
@end
