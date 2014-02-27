//
//  CompositeParser.h
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEmoticon.h"
#import "EmoticonParser.h"

@interface CompositeParser : NSObject <EmoticonParser>
-(void)addParser:(id<EmoticonParser>)parser;
-(void)removeParser:(id<EmoticonParser>)parser;

-(NSArray *)parsers;
@end
