//
//  CompositeParser.m
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "CompositeParser.h"

@implementation CompositeParser
{
    NSMutableArray *parserList;
}

-(id)init
{
    if (self = [super init])
    {
        parserList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addParser:(id<EmoticonParser>)parser
{
    [parserList addObject:parser];
}

-(void)removeParser:(id<EmoticonParser>)parser
{
    [parserList removeObject:parser];
}

-(NSArray *)parsers
{
    return parserList;
}

-(bool)parseEmoticonForText:(NSString *)text useFont:(UIFont *)font toView:(UIView *)view
{
    for (int i = 0; i < parserList.count; ++i)
    {
        id<EmoticonParser> parser = parserList[i];
        
        if ([parser parseEmoticonForText:text useFont:font toView:view])
        {
            return true;
        }
        
        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    return false;
}
@end
