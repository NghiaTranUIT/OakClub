//
//  ChatEmoticon.m
//  OakClub
//
//  Created by Salm on 9/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ChatEmoticon.h"
#import "Define.h"

@implementation ChatEmoticon
{
    NSDictionary *emotDict;
    NSArray *emotKeys;
    id<EmoticonDataFactory> dataF;
}

-(id)initWithContentsOfFile:(NSString *)fileName andDataFactory:(id<EmoticonDataFactory>)dataFactory
{
    if (self = [super init])
    {
        NSArray *emotFileData = [[NSArray alloc] initWithContentsOfFile:fileName];
        
        emotKeys = emotFileData[0];
        
        NSDictionary *emotStringDict = emotFileData[1];
        NSMutableDictionary *emoticons = [[NSMutableDictionary alloc] init];
        for (NSString *key in emotStringDict.allKeys)
        {
            NSString *dataLink = [emotStringDict valueForKey:key];
            if (dataLink && ![@"" isEqualToString:dataLink])
            {
                id<EmoticonData> emotData = [dataFactory createEmoticonDataForKey:key andLink:dataLink];
                [emoticons setValue:emotData forKey:key];
            }
        }
        
        emotDict = [NSDictionary dictionaryWithDictionary:emoticons];
    }
    
    return self;
}

-(id)initWithServerConfig:(NSArray *)svData andDataFactory:(id<EmoticonDataFactory>)dataFactory
{
    if (self = [super init])
    {
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        NSMutableDictionary *emoticons = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *emotData in svData)
        {
            NSString *emotKey = emotData[key_symbol];
            NSString *emotDataLink = emotData[key_image];
            
            [keys addObject:emotKey];
            
            id<EmoticonData> emotData = [dataFactory createEmoticonDataForKey:emotKey andLink:emotDataLink];
            [emoticons setValue:emotData forKey:emotKey];
        }
        
        emotKeys = keys;
        emotDict = emoticons;
    }
    
    return self;
}

-(id<EmoticonData>)getEmoticonData:(NSString *)emoticonKey;
{
    return [emotDict valueForKey:emoticonKey];
}

-(NSArray *)emoticonKeys
{
    return emotKeys;
}
@end