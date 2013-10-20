//
//  HistoryMessage+init.m
//  OakClub
//
//  Created by Salm on 10/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "HistoryMessage+init.h"

@implementation HistoryMessage(init)

- (id) initMessageFrom:(NSString *)_from atTime:(NSString *)_timeStr toHangout:(NSString *)_toHangout withContent:(NSString*)_body
{
    self = [super init];
    
    if (self)
    {
        self.body = _body;
        self.timeStr = _timeStr;
        self.from = _from;
        self.to = _toHangout;
    }
    
    return self;
}

@end
