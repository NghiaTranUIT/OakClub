//
//  NSDictionary+JSON.h
//  OakClub
//
//  Created by Salm on 2/21/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BVJSONString)
-(NSString *)JSONDescription;
@end

@interface NSArray (BVJSONString)
- (NSString *)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint;
@end