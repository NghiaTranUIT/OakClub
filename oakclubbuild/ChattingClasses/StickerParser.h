//
//  StickerParser.h
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEmoticon.h"
#import "EmoticonParser.h"

@interface StickerParser : NSObject <EmoticonParser>
-(id)initWithEmoticons:(ChatEmoticon *)chatEmot andEmoticonSize:(CGSize)emotSize;
@end