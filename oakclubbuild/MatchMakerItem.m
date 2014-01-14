//
//  MatchMakerItem.m
//  OakClub
//
//  Created by Salm on 1/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "MatchMakerItem.h"
#import "UIView+Localize.h"

@implementation MatchMakerItem
@synthesize friend1 = _friend1, friend2 = _friend2, matchTime = _matchTime, status = _status, isSent;

-(id)initWithFriend1:(Profile *)friend1 friend2:(Profile *)friend2 matchTime:(NSString *)matchTime requestStatus:(BOOL)status andSendStatus:(BOOL) sendStatus
{
    if (self = [super init])
    {
        _friend1 = friend1;
        _friend2 = friend2;
        _matchTime = [NSString stringWithString:matchTime];
        _status = status;
        isSent = sendStatus;
    }
    
    return self;
}

-(NSString *)s_Status
{
    if (_status)
    {
        return [@"Active" localize];
    }
    else
    {
        return [@"Inactive" localize];
    }
}
@end
