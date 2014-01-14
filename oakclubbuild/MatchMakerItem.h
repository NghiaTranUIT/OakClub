//
//  MatchMakerItem.h
//  OakClub
//
//  Created by Salm on 1/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@interface MatchMakerItem : NSObject
@property (weak, nonatomic) Profile* friend1;
@property (weak, nonatomic) Profile* friend2;

@property (strong, nonatomic) NSString *matchTime;
@property BOOL status;
@property (readonly) NSString *s_Status;
@property BOOL isSent;

-(id)initWithFriend1:(Profile *)friend1 friend2:(Profile *)friend2 matchTime:(NSString *)matchTime requestStatus:(BOOL)status andSendStatus:(BOOL) sendStatus;
@end
