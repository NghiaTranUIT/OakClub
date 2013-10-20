//
//  NSString+Date.h
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Utils)


+ (NSString *) getTime:(NSDate*)date;
+ (NSDate*) getDateWithString:(NSString*) timeStr;
+ (NSString *) getCurrentTime;
- (NSString *) substituteEmoticons;
+(NSString*)formatStringWithName:(NSString*)name andAge:(NSString*)age andNameLength:(int)maxLength;
@end


NSString *dateToStringInterval(NSDate *pastDate);

@interface EmoticonString : NSObject
- (void) insertString:(NSString *)str atIndex:(int)index;
- (void) removeCharactersInRange:(NSRange)rng;
- (NSString *) textString;
- (NSArray*) smileyRanges;
@end

