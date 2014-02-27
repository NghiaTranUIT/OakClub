//
//  WordWarpParse.h
//  ChatTableTest
//
//  Created by Salm on 9/16/13.
//  Copyright (c) 2013 Vu. Luu Quang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"
#import "ChatEmoticon.h"

@protocol StringMeasurer <NSObject>

@required
-(CGSize) measureString:(NSString*)str;

@end

@protocol LineBuilder <NSObject>

@required
- (UIView *) buildLineWithComponent:(NSArray *)lines useFont:(UIFont *)font andEmoticonData:(ChatEmoticon *)data toView:(UIView *)view;

@end

@interface WordWarpParse : NSObject
- (NSArray*) parseText:(NSString *)text byMeasure:(id<StringMeasurer>)measure withMaxWidth:(float)maxWidth andEmoticonData:(NSArray *)emotData;
- (NSArray *) parseEmoticonsForText:(NSString *)text withEmoticonData:(NSArray *)emotData;
@end

@interface FontStringMeasure : NSObject <StringMeasurer>
- (id) initWithFont:(UIFont *)font;
-(CGSize) measureString:(NSString*)str;
@end

@interface FontAndEmoticonsStringMeasure : FontStringMeasure
- (id) initWithFont:(UIFont *)font andEmoticonData:(ChatEmoticon *)data;
-(CGSize) measureString:(NSString*)str;
@end

@interface LineBuilderImpl : NSObject <LineBuilder>

- (UIView *) buildLineWithComponent:(NSArray *)lines useFont:(UIFont *)font andEmoticonData:(NSDictionary *)data toView:(UIView *)view;

@end