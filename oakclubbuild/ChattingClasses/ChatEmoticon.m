//
//  ChatEmoticon.m
//  OakClub
//
//  Created by Salm on 9/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ChatEmoticon.h"

@implementation ChatEmoticon

+(id) instance
{
    static NSDictionary *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[[self alloc] init] loadSmileys];
    });
    return sharedInst;
}

- (NSDictionary*) loadSmileys
{
    NSString *smileysPath = [[NSBundle mainBundle] pathForResource:@"SmileyList" ofType:@"plist"];
    
    NSDictionary *smileyStringDict = [[NSDictionary alloc] initWithContentsOfFile:smileysPath];
    NSMutableDictionary *smileys = [[NSMutableDictionary alloc] init];
    for (NSString *key in smileyStringDict.allKeys)
    {
        UIImage *smiley = [UIImage imageNamed:[smileyStringDict objectForKey:key]];
        NSLog(@"Load smiley: %@", [smileyStringDict objectForKey:key]);
        
        if (smiley)
        {
            [smileys setValue:smiley forKey:key];
        }
    }
    
    return smileys;
}
@end
