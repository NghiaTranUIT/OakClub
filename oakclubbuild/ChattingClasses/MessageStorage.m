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
#import "CompositeParser.h"
#import "SmileyParser.h"
#import "HTMLTagParser.h"
#import "StickerParser.h"
#import "OakClubChatEmoticon.h"

@interface MessageStorage()
{
    id<EmoticonParser> emotParser;
}
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
        
        [self initEmoticonParser];
    }
    
    return self;
}

-(void)initEmoticonParser
{
    CompositeParser *parser = [[CompositeParser alloc] init];
    
    ChatEmoticon *stickers1 = [[OakClubChatEmoticon instance] chatEmoticonForName:key_emoticon_sticker_1];
    CGSize stickers1Size = [OakClubChatEmoticon instance].giftSize;
    id<EmoticonParser> stickers1Parser = [[HTMLTagParser alloc] initWithGiftEmoticon:stickers1 andType:key_sticker andSize:stickers1Size];
    [parser addParser:stickers1Parser];
    
    ChatEmoticon *gifts = [[OakClubChatEmoticon instance] chatEmoticonForName:key_emoticon_gift];
    CGSize giftSize = [OakClubChatEmoticon instance].giftSize;
    id<EmoticonParser> giftParser = [[HTMLTagParser alloc] initWithGiftEmoticon:gifts andType:nil andSize:giftSize];
    [parser addParser:giftParser];
    
    ChatEmoticon *smileys = [[OakClubChatEmoticon instance] chatEmoticonForName:key_emoticon_smileys];
    [parser addParser:[[SmileyParser alloc] initWithEmoticons:smileys]];
    
    emotParser = parser;
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
    
    UIFont *font =FONT_HELVETICANEUE_LIGHT(14.0);
    UIView *targetView = [[UIView alloc] init];
    
    [emotParser parseEmoticonForText:item.body useFont:font toView:targetView];
    
    [self.contentViews addObject:targetView.subviews];
    [self.contentFrames addObject:[NSValue valueWithCGRect:targetView.frame]];
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
