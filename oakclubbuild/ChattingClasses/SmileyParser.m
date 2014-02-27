//
//  SmileyParser.m
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "SmileyParser.h"
#import "WordWarpParse.h"

@implementation SmileyParser
{
    ChatEmoticon *chatEmoticon;
}

-(id)initWithEmoticons:(ChatEmoticon *)chatEmot
{
    if (self = [super init])
    {
        chatEmoticon = chatEmot;
    }
    
    return self;
}

-(bool)parseEmoticonForText:(NSString *)text useFont:(UIFont *)font toView:(UIView *)view
{
    WordWarpParse *wordWarper = [[WordWarpParse alloc] init];
    id<StringMeasurer> strMeasure = [[FontAndEmoticonsStringMeasure alloc] initWithFont:font andEmoticonData:chatEmoticon];
    float maxWidth = 150;
    NSArray *emotKeys = chatEmoticon.emoticonKeys;
    id<LineBuilder> lineBuilder = [[LineBuilderImpl alloc] init];
    
    NSArray *lines = [wordWarper parseText:text byMeasure:strMeasure withMaxWidth:maxWidth andEmoticonData:emotKeys];
    [lineBuilder buildLineWithComponent:lines useFont:font andEmoticonData:chatEmoticon toView:view];
    
    return true;
}
@end
