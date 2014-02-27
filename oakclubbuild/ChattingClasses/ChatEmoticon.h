//
//  ChatEmoticon.h
//  OakClub
//
//  Created by Salm on 9/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmoticonData.h"

@interface ChatEmoticon : NSObject
-(id)initWithContentsOfFile:(NSString *)fileName andDataFactory:(id<EmoticonDataFactory>)dataFactory;
-(id)initWithServerConfig:(NSArray *)svData andDataFactory:(id<EmoticonDataFactory>)dataFactory;

-(id<EmoticonData>)getEmoticonData:(NSString *)emoticonKey;

-(NSArray *)emoticonKeys;
@end