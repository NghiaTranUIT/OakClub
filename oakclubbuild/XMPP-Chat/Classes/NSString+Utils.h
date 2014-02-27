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
- (NSString *) formatForChatMessage;
+(NSString*)formatStringWithName:(NSString*)name andAge:(NSString*)age andNameLength:(int)maxLength;
+(NSString* )localizeString:(NSString*)text;
@end


NSString *dateToStringInterval(NSDate *pastDate);