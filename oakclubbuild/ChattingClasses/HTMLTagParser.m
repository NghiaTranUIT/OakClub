//
//  GiftParser.m
//  OakClub
//
//  Created by Salm on 2/14/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "HTMLTagParser.h"

@implementation HTMLTagParser
{
    ChatEmoticon *chatEmoticon;
    
    NSString *type;
    CGSize parseSize;
}

-(id)initWithGiftEmoticon:(ChatEmoticon *)giftEmots andType:(NSString *)_type andSize:(CGSize)size
{
    if (self = [super init])
    {
        chatEmoticon = giftEmots;
        type = _type;
        parseSize = size;
    }
    
    return self;
}

-(bool)parseEmoticonForText:(NSString *)text useFont:(UIFont *)font toView:(UIView *)view
{
    if (![self isValidHTML:text])
    {
        return false;
    }
    
    NSString *srcAttributePattern = @"src=\"[^\"]*\"";
    NSString *giftFilePattern = @"/[^/\\.]*\\.";
    
    NSRegularExpression *srcRegEx = [NSRegularExpression regularExpressionWithPattern:srcAttributePattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *srcAttMatch = [srcRegEx firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (srcAttMatch)
    {
        NSRegularExpression *giftFileRegEx = [NSRegularExpression regularExpressionWithPattern:giftFilePattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *giftFileMatch = [giftFileRegEx firstMatchInString:text options:0 range:srcAttMatch.range];
        
        if (giftFileMatch)
        {
            NSRange giftFileRange = giftFileMatch.range;
            
            // remove / prefix & . suffix char
            ++giftFileRange.location;
            giftFileRange.length -= 2;
            NSString *giftFile = [text substringWithRange:giftFileRange];
            
            return [self editView:view forGiftFile:giftFile];
        }
    }
    
    return false;
}

-(bool)isValidHTML:(NSString *)text
{
    NSString *htmlRegExPattren = nil;
    if (type)
    {
        htmlRegExPattren = [NSString stringWithFormat:@"<img src=\"[^\"]*\"((?!type).)*type=\"%@\"((?!/>).)*/>",
                                      type];
    }
    else
    {
        htmlRegExPattren = [NSString stringWithFormat:@"<img src=\"[^\"]*\"((?!/>).)*/>"];
    }
    
    NSRegularExpression *htmlRegEx = [NSRegularExpression regularExpressionWithPattern:htmlRegExPattren options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *htmlMatch = [htmlRegEx firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if(htmlMatch)
    {
        return (htmlMatch.range.location == 0);
    }
    
    return false;
}

#define LINE_INDENT 10
-(bool)editView:(UIView *)view forGiftFile:(NSString *)gift
{
    CGRect giftFrame = CGRectMake(0, 0, parseSize.width, parseSize.height);
    
    id<EmoticonData> giftEmotData = [chatEmoticon getEmoticonData:gift];
    if(giftEmotData)
    {
        UIImageView *gifImgView = [[UIImageView alloc] initWithFrame:giftFrame];
        [giftEmotData getImageAsycn:^(UIImage *image, NSError *e) {
            [gifImgView setImage:image];
        }];
        gifImgView.backgroundColor = [UIColor clearColor];
        [gifImgView setContentMode:UIViewContentModeScaleAspectFit];
        
        [view addSubview:gifImgView];
        
        giftFrame.size.height += LINE_INDENT;   // cheat for chat footer
        [view setFrame:giftFrame];
        
        return true;
    }
    
    return false;
}
@end
