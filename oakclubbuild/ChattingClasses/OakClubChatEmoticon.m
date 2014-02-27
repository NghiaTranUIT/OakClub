//
//  OakClubChatEmoticon.m
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "OakClubChatEmoticon.h"
#import "Define.h"

@implementation OakClubChatEmoticon
{
    NSMutableDictionary *chatEmoticons;
}

@synthesize stickerDomainLink, giftDomainLink, stickerSize, giftSize;

-(id)init
{
    if (self = [super init])
    {
        chatEmoticons = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)addChatEmoticon:(ChatEmoticon *)chatEmot forName:(NSString *)chatEmotName
{
    [chatEmoticons setValue:chatEmot forKey:chatEmotName];
}
-(void)removeChatEmoticonWithName:(NSString *)chatEmotName
{
    [chatEmoticons removeObjectForKey:chatEmotName];
}

-(ChatEmoticon *)chatEmoticonForName:(NSString *)name
{
    return [chatEmoticons valueForKey:name];
}

-(NSDictionary *)chatEmoticions;
{
    return chatEmoticons;
}

+(OakClubChatEmoticon *)instance
{
    static OakClubChatEmoticon *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[OakClubChatEmoticon alloc] init];
        
        NSString *smileysFilePath = [[NSBundle mainBundle] pathForResource:@"SmileyList" ofType:@"plist"];
        ChatEmoticon *smileys = [[ChatEmoticon alloc] initWithContentsOfFile:smileysFilePath andDataFactory:[BundleEmoticonDataFactory instance]];
        [sharedInst addChatEmoticon:smileys forName:key_emoticon_smileys];
        
        NSString *giftFilePath = [[NSBundle mainBundle] pathForResource:@"GiftList" ofType:@"plist"];
        ChatEmoticon *gifts = [[ChatEmoticon alloc] initWithContentsOfFile:giftFilePath andDataFactory:[BundleEmoticonDataFactory instance]];
        [sharedInst addChatEmoticon:gifts forName:key_emoticon_gift];
    });
    
    return sharedInst;
}
@end
