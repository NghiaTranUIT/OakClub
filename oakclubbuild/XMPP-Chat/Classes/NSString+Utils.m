//
//  NSString+Date.m
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "NSString+Utils.h"
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
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //return [dateFormatter stringFromDate:nowUTC];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:DATETIME_FORMAT];
    
	
    
    return [dateFormat stringFromDate:nowUTC];
	
}

- (NSString *) substituteEmoticons {
	/*
	//See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
	
	NSString *res = [self stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];	
	res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
	res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
	res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
    res = [res stringByReplacingOccurrencesOfString:@":))" withString:@"\ue057"];
    res = [res stringByReplacingOccurrencesOfString:@"(y)" withString:@"\ue00e"];
    res = [res stringByReplacingOccurrencesOfString:@"<3" withString:@"\ue022"];
    res = [res stringByReplacingOccurrencesOfString:@":@" withString:@"\ue416"];*/
	
	return self;
	
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

@interface EmoticonString()
@property NSMutableString *textStr;
//@property NSMutableString *emotStr;
@end

@implementation EmoticonString

@synthesize textStr;

NSMutableArray *smileysRange;

- (id) init
{
    self = [super init];
    if (self)
    {
        textStr = [[NSMutableString alloc] init];
//        emotStr = [[NSMutableString alloc] init];
        
        smileysRange = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) insertString:(NSString *)str atIndex:(int)index
{
    int realIndex = [self adaptIndex:index];
    
    if (self.textStr.length > realIndex)
    {
        [self.textStr insertString:str atIndex:realIndex];
    }
    else
    {
        [self.textStr appendString:str];
    }
    
    [self resetSmileys];
}

- (void) removeCharactersInRange:(NSRange)rng
{
    int realIndex = [self adaptIndex:rng.location];
    
    int realLength = rng.length;
    
    for (NSValue *rangeVal in smileysRange)
    {
        NSRange rng = rangeVal.rangeValue;
        if (rng.location >= realIndex && rng.location < realIndex + rng.length)
        {
            realLength += rng.length - 1;
        }
    }
    
    NSRange realRange = NSMakeRange(realIndex, realLength);
    
    [self.textStr deleteCharactersInRange:realRange];
    
    [self resetSmileys];
}

- (int) adaptIndex:(int)index
{
    int result = index;
    for (NSValue *rangeVal in smileysRange)
    {
        NSRange rng = rangeVal.rangeValue;
        if (rng.location < index)
        {
            result += rng.length - 1;
        }
    }
    
    return result;
}

- (NSString *) textString
{
    return textStr;
}

- (void) resetSmileys
{
    [smileysRange removeAllObjects];
    
    NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[[[WordWarpParse alloc] init] parseEmoticonsForText:self.textString withEmoticonData:[[ChatEmoticon instance] allKeys]] copyItems:false];
    
    int caret = 0;
    
    for (NSString *component in components)
    {
        if ([[[ChatEmoticon instance] allKeys] containsObject:component])
        {
            [smileysRange addObject:[NSValue valueWithRange:NSMakeRange(caret, component.length)]];
        }
        else
        {
            caret += component.length;
        }
    }
}

- (NSArray *) smileyRanges
{
    return smileysRange;
}

@end