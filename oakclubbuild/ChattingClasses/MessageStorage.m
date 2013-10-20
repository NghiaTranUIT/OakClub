//
//  MessageStorage.m
//  OakClub
//
//  Created by Salm on 9/19/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "MessageStorage.h"
#import "WordWarpParse.h"
#import "ChatEmoticon.h"

@interface MessageStorage()
@property NSMutableArray *messages;
@property NSMutableArray *contentViews;
@property NSString *profileID;
@property NSMutableArray *contentFrames;
@end

@implementation MessageStorage
@synthesize messages, profileID, contentViews, contentFrames;

- (id) initWithProfileID:(NSString *)profile_ID
{
    self = [super init];
    
    if (self)
    {
        self.messages = [[NSMutableArray alloc] init];
        self.contentViews = [[NSMutableArray alloc] init];
        self.contentFrames = [[NSMutableArray alloc] init];
        self.profileID = [NSString stringWithString:profile_ID];
    }
    
    return self;
}

- (void) addMessage:(HistoryMessage *)item
{
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    
    [m setValue:item.body forKey:@"msg"];
    
    [m setValue:item.timeStr forKey:@"time"];
    
    if([item.from isEqualToString:self.profileID] )
    {
        [m setObject:item.from forKey:@"sender"];
    }
    else
    {
        [m setObject:@"you" forKey:@"sender"];
    }
    
    [messages addObject:m];
    
    UIFont *font = [UIFont systemFontOfSize:14.0];
    
    NSArray *lines = [[[WordWarpParse alloc] init] parseText:item.body byMeasure:[[FontAndEmoticonsStringMeasure alloc] initWithFont:font andEmoticonData:[ChatEmoticon instance]] withMaxWidth:200 andEmoticonData:[[ChatEmoticon instance] allKeys]];
    UIView *view = [[[LineBuilderImpl alloc] init] buildLineWithComponent:lines useFont:font andEmoticonData:[ChatEmoticon instance] toView:[[UIView alloc] init]];
    
    [self.contentViews addObject:view.subviews];
    [self.contentFrames addObject:[NSValue valueWithCGRect:view.frame]];
}

- (NSDictionary *) getMessageAtIndex:(int)index
{
    return [self.messages objectAtIndex:index];
}

- (int) count
{
    return [self.messages count];
}

- (NSArray *) messageContentViews
{
    return self.contentViews;
}

- (NSArray *) frames
{
    return  self.contentFrames;
}
@end
