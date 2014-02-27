//
//  StickerParser.m
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "StickerParser.h"

@implementation StickerParser
{
    ChatEmoticon *chatEmoticon;
    CGSize emoticonSize;
}

-(id)initWithEmoticons:(ChatEmoticon *)chatEmot andEmoticonSize:(CGSize)emotSize
{
    if (self = [super init])
    {
        chatEmoticon = chatEmot;
        emoticonSize = emotSize;
    }
    
    return self;
}

-(bool)parseEmoticonForText:(NSString *)text useFont:(UIFont *)font toView:(UIView *)view
{
    if (![self isSticker:text])
    {
        return false;
    }
    
    NSRange stickerNameRange = NSMakeRange(1, text.length - 2);
    NSString *stickerName = [text substringWithRange:stickerNameRange];
    
    id<EmoticonData> emotData = [chatEmoticon getEmoticonData:stickerName];
    if (emotData)
    {
        CGRect emotRect;
        emotRect.size = emoticonSize;
        
        UIImageView *emotImgView = [[UIImageView alloc] initWithFrame:emotRect];
        [emotData getImageAsycn:^(UIImage *image, NSError *e) {
            [emotImgView setImage:image];
        }];
        
        [view setFrame:emotRect];
        [view addSubview:emotImgView];
        
        return true;
    }
    
    return false;
}

-(bool)isSticker:(NSString *)text
{
    NSString *stickerRegExPattren = @"([^)]*)";
    
    NSRegularExpression *stickerRegEx = [NSRegularExpression regularExpressionWithPattern:stickerRegExPattren options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *stickerMatch = [stickerRegEx firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if(stickerMatch)
    {
        return (stickerMatch.range.location == 0) && (stickerMatch.range.length == text.length - 1);
    }
    
    return false;
}
@end
