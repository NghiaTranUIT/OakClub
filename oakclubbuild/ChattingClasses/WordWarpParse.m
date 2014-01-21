//
//  WordWarpParse.m
//  ChatTableTest
//
//  Created by Salm on 9/16/13.
//  Copyright (c) 2013 Vu. Luu Quang. All rights reserved.
//

#import "WordWarpParse.h"
#import "Line.h"

@interface WordWarpParse()
@end

@implementation WordWarpParse

- (NSArray*) parseText:(NSString *)text byMeasure:(id<StringMeasurer>)measure withMaxWidth:(float)maxWidth andEmoticonData:(NSArray *)_emotData
{
    NSArray *sortedEmotData = [_emotData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *s1 = obj1;
        NSString *s2 = obj2;
        
        return s1.length <= s2.length;
    }];
    
    NSString *terminal = @" ";
    NSArray *textComponents = [self parseEmoticonsForText:text withEmoticonData:sortedEmotData];
    NSMutableArray *words = [[NSMutableArray alloc] init];
    for (NSString *component in textComponents)
    {
        if (![sortedEmotData containsObject:component])
        {
            [words addObjectsFromArray:[component componentsSeparatedByString:terminal]];
        }
        else
        {
            [words addObject:component];
        }
    }
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    [lines addObject:[[Line alloc] init]];
    
    for (NSString *word in words)
    {
        [self parseWord:word byMeasure:measure andEmoticonData:sortedEmotData withMaxWidth:maxWidth toParagraph:lines];
    }
    
    return lines;
}

#define spacePadding 4
#define lineBreakRatio 0.7

- (void) parseWord:(NSString *)word byMeasure:(id<StringMeasurer>)measure andEmoticonData:(NSArray *)emotData withMaxWidth:(float)maxWidth toParagraph:(NSMutableArray *)lines
{
    Line *textLine = [lines objectAtIndex:lines.count - 1];
    CGSize wordSize = [measure measureString:word];
    wordSize.width += spacePadding;
    if (wordSize.width + textLine.size.width > maxWidth)
    {
        if (textLine.size.width <= 0)
        {
            NSArray *splitted = [self lineCutText:word byMaxWidth:maxWidth witdMeasure:measure];
            for (NSString *splitWord in splitted)
            {
                [textLine appendText:splitWord withSize:[measure measureString:splitWord] andEmotData:emotData];
                textLine = [[Line alloc] init];
                [lines addObject:textLine];
                //line = [measure measureString:splitWord];
            }
        }
        else
        {
            //[textLine appendFormat:@" %@", word];
            [lines addObject:[[Line alloc] init]];
            //line =
            [self parseWord:word byMeasure:measure andEmoticonData:(NSArray *)emotData withMaxWidth:maxWidth toParagraph:lines ];
        }
    }
    else
    {
        [textLine appendText:word withSize:wordSize andEmotData:emotData];
    }
}

- (NSArray*) lineCutText:(NSString*)text byMaxWidth:(float)maxWidth witdMeasure:(id<StringMeasurer>) measure
{
    NSMutableArray *cutted = [[NSMutableArray alloc] init];
    
    float width = 0;
    int lasti = 0;
    for (int i = 0; i < text.length; ++i)
    {
        float sz = [measure measureString:[text substringWithRange:NSMakeRange(i, 1)]].width;
        
        if (width + sz > maxWidth)
        {
            [cutted addObject:[text substringWithRange:NSMakeRange(lasti, i - lasti)]];
            lasti = i;
            width = 0;
        }
        
        width += sz;
    }
    
    [cutted addObject:[text substringFromIndex:lasti]];
    
    return cutted;
}

- (NSArray *) parseEmoticonsForText:(NSString *)text withEmoticonData:(NSArray *)emotData
{
    NSMutableArray *components = [[NSMutableArray alloc] init];
    for (NSString *emoticon in emotData)
    {
        NSRange range = [text rangeOfString:emoticon];
        if (range.location != NSNotFound)
        {
            NSString *pref, *suff;
            if (range.location > 0)
            {
                pref = [text substringToIndex:range.location];
            }
            
            if (range.location + range.length < text.length)
            {
                suff = [text substringFromIndex:range.location + range.length];
            }
            
            if (pref)
            {
                [components addObjectsFromArray:[self parseEmoticonsForText:pref withEmoticonData:emotData]];
            }
            
            [components addObject:emoticon];
            
            if (suff)
            {
                [components addObjectsFromArray:[self parseEmoticonsForText:suff withEmoticonData:emotData]];
            }
            
            return components;
        }
    }
    
    [components addObject:text];
    
    return components;
}
@end

@interface FontStringMeasure()
@property (weak, nonatomic) UIFont *font;
@end

@implementation FontStringMeasure

@synthesize font = _font;

- (id) initWithFont:(UIFont *)font
{
    self = [super init];
    if (self)
    {
        self.font = font;
    }
    
    return self;
}

-(CGSize) measureString:(NSString*)str
{
	return [str sizeWithFont:self.font];
}

@end

@interface FontAndEmoticonsStringMeasure()
@property NSDictionary *emotData;
@end

@implementation FontAndEmoticonsStringMeasure

@synthesize emotData;

- (id) initWithFont:(UIFont *)font andEmoticonData:(NSDictionary *)data
{
    self = [super initWithFont:font];
    
    if (self)
    {
        self.emotData = data;
    }
    
    return self;
}
-(CGSize) measureString:(NSString*)str
{
    UIImage *img = [self.emotData objectForKey:str];
    if (img != nil)
    {
        return img.size;
    }
    
    return [super measureString:str];
}
@end


@implementation LineBuilderImpl

- (UIView *) buildLineWithComponent:(NSArray *)lines useFont:(UIFont *)font andEmoticonData:(NSDictionary *)data toView:(UIView *)view
{
    static float lineIndent = 10;
    
    float x = 0, y = 0;
    float width = 0;
    for (Line *line in lines)
    {
        x = 0;
        for (NSString *component in line.components)
        {
            UIImage *emot = [data objectForKey:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            if (!emot)
            {
                UILabel *lbl = [[UILabel alloc] init];
                lbl.font = font;
                lbl.text = component;
                [lbl sizeToFit];
                lbl.frame = CGRectMake(x, y + line.size.height - lbl.frame.size.height, lbl.frame.size.width, lbl.frame.size.height);
                lbl.backgroundColor = [UIColor clearColor];
                x += lbl.frame.size.width;
                [view addSubview:lbl];
            }
            else
            {
                UIImageView *imgView = [[UIImageView alloc] initWithImage:emot];
                imgView.backgroundColor = [UIColor clearColor];
                [imgView sizeToFit];
                imgView.frame = CGRectMake(x, y, imgView.frame.size.width, imgView.frame.size.height);
                x += imgView.frame.size.width;
                [view addSubview:imgView];
            }
        }
        width = MAX(width, x);
        y += line.size.height + lineIndent;
    }
    
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, y);
    
    return view;
}

@end