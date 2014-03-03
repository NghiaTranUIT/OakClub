//
//  NSDictionary+JSON.m
//  OakClub
//
//  Created by Salm on 2/21/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (BVJSONString)
-(NSString *)JSONDescription
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@implementation NSArray (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end