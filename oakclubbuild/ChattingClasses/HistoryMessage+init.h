//
//  HistoryMessage+init.h
//  OakClub
//
//  Created by Salm on 10/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryMessage.h"

@interface HistoryMessage(init)

- (id) initMessageFrom:(NSString *)_from atTime:(NSString *)_timeStr toHangout:(NSString *)_toHangout withContent:(NSString*)body;

@end
