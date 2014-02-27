//
//  GiftParser.h
//  OakClub
//
//  Created by Salm on 2/14/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEmoticon.h"
#import "EmoticonParser.h"

@interface HTMLTagParser : NSObject <EmoticonParser>
-(id)initWithGiftEmoticon:(ChatEmoticon *)giftEmots andType:(NSString *)type andSize:(CGSize)size;
@end
