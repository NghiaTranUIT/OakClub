//
//  RelationShip.h
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RelationShip : NSObject<NSCopying>

@property (assign, nonatomic) int rel_status_id;
@property (strong, nonatomic) NSString *rel_text;

-(RelationShip*)initWithNSString:(NSString*)relText;
@end
