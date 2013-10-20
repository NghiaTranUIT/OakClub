//
//  MessageStorage.h
//  OakClub
//
//  Created by Salm on 9/19/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryMessage.h"

@interface MessageStorage : NSObject
- (void) addMessage:(HistoryMessage *)msg;
- (NSDictionary *) getMessageAtIndex:(int)index;

- (id) initWithProfileID:(NSString *)profile_ID;
- (int) count;

- (NSArray *) messageContentViews;
- (NSArray *) frames;
@end
