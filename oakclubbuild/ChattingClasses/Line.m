//
//  Line.m
//  ChatTableTest
//
//  Created by Salm on 9/16/13.
//  Copyright (c) 2013 Vu. Luu Quang. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize components, size;

-(id) init
{
    self = [super init];
    if (self)
    {
        components = [[NSMutableArray alloc] init];
        size = CGSizeMake(0, 0);
    }
    
    return self;
}

#define spacePadding 4

-(void) appendText:(NSString *)str withSize:(CGSize)_size andEmotData:(NSArray *)emotData
{
    if (self.components.count == 0)
    {
        [self appendTextImmediately:str withSize:_size];
    }
    else
    {
        NSMutableString *lastStr = [self.components objectAtIndex:[self.components count] - 1];
        if ([emotData containsObject:lastStr] || [emotData containsObject:str])
        {
            [self appendTextImmediately:str withSize:_size];
        }
        else
        {
            [lastStr appendFormat:@" %@", str];
            self.size = CGSizeMake(self.size.width + _size.width + spacePadding, MAX(self.size.height, _size.height));
        }
    }
}

-(void) appendTextImmediately:(NSString *)str withSize:(CGSize)_size
{
    [self.components addObject:[NSMutableString stringWithString:str]];
    self.size = CGSizeMake(self.size.width + _size.width + spacePadding, MAX(self.size.height, _size.height));
}
@end
