//
//  OakClubChatEmoticon.h
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "ChatEmoticon.h"

@interface OakClubChatEmoticon : NSObject
@property NSString *stickerDomainLink, *giftDomainLink;
@property CGSize stickerSize, giftSize;

-(void)addChatEmoticon:(ChatEmoticon *)chatEmot forName:(NSString *)chatEmotName;
-(void)removeChatEmoticonWithName:(NSString *)chatEmotName;

-(ChatEmoticon *)chatEmoticonForName:(NSString *)name;

-(NSDictionary *)chatEmoticions;

+(OakClubChatEmoticon *)instance;
@end
