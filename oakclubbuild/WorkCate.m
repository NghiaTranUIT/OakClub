//
//  WorkCate.m
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "WorkCate.h"

@implementation WorkCate
-(id) copyWithZone: (NSZone *) zone{
    WorkCate *copyObj = [[WorkCate allocWithZone: zone] init];
    copyObj.cate_id = self.cate_id;
    copyObj.cate_name = [self.cate_name copyWithZone:zone];
    return copyObj;
}
@end
