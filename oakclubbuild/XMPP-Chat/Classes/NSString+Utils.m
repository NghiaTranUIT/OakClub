//
//  NSString+Date.m
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "NSString+Utils.h"
#import "NSString+HTML.h"
#import "ChatEmoticon.h"
#import "WordWarpParse.h"
#import "AppDelegate.h"

@implementation NSString (Utils)

+ (NSString *) getTime:(NSDate*)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:date];
	
}

+ (NSDate*) getDateWithString:(NSString*) timeStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:DATETIME_FORMAT];
    
    return [dateFormat dateFromString:timeStr];
}

+ (NSString *) getCurrentTime {

	NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:DATETIME_FORMAT];
    
    return [dateFormat stringFromDate:nowUTC];
	
}

- (NSString *) formatForChatMessage {
    return [self kv_decodeHTMLCharacterEntities];
}

-(NSString *)formatForJSON
{
    return nil;
}

+(NSString*)formatStringWithName:(NSString*)name andAge:(NSString*)age andNameLength:(int)maxLength{
    NSString* result;
    if([name length] > maxLength){
        name = [name stringByReplacingCharactersInRange:NSMakeRange([name length]-3, 3) withString:@"..."];
    }
    result = [NSString stringWithFormat:@"%@,%@",name,age];
    return result;
}

+(NSString* )localizeString:(NSString*)text{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSString *localizedText = [appDelegate.languageBundle localizedStringForKey:text value:@"" table:nil];
    if (localizedText && ![@"" isEqualToString:localizedText])
        return localizedText;
    return text;
}
@end


NSString *dateToStringInterval(NSDate *pastDate)
//! Method to return a string "xxx days ago" based on the difference between pastDate and the current date and time.
{
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the current date
    NSDate *currentDate = [[NSDate alloc] init];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:currentDate  toDate:pastDate  options:0];
    
    //NSLog(@"Break down: %dmin %dhours %ddays %dmoths",[breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    
    NSString *intervalString;
    if ([breakdownInfo month]) {
        if (-[breakdownInfo month] > 1)
            intervalString = [NSString stringWithFormat:@"%d %@", -[breakdownInfo month], [NSString localizeString:@"months ago"]];
        else
            intervalString = [NSString stringWithFormat:@"1 %@", [NSString localizeString:@"month ago"]];
    }
    else if ([breakdownInfo day]) {
        if (-[breakdownInfo day] > 1)
            intervalString = [NSString stringWithFormat:@"%d %@", -[breakdownInfo day], [NSString localizeString:@"days ago"]];
        else
            intervalString = [NSString stringWithFormat:@"1 %@", [NSString localizeString:@"day ago"]];
    }
    else if ([breakdownInfo hour]) {
        if (-[breakdownInfo hour] > 1)
            intervalString = [NSString stringWithFormat:@"%d %@", -[breakdownInfo hour], [NSString localizeString:@"hours ago"]];
        else
            intervalString = [NSString stringWithFormat:@"1 %@", [NSString localizeString:@"hour ago"]];
    }
    else {
        if (-[breakdownInfo minute] > 1)
            intervalString = [NSString stringWithFormat:@"%d %@", -[breakdownInfo minute], [NSString localizeString:@"minutes ago"]];
        else
            intervalString = [NSString stringWithFormat:@"1 %@", [NSString localizeString:@"minute ago"]];
    }
    
    return intervalString;
}