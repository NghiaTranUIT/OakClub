//
//  WorkCate.m
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "WorkCate.h"
#import "AppDelegate.h"

@implementation WorkCate
-(id) copyWithZone: (NSZone *) zone{
    WorkCate *copyObj = [[WorkCate allocWithZone: zone] init];
    copyObj.cate_id = self.cate_id;
//    copyObj.cate_name = [self.cate_name copyWithZone:zone];
    return copyObj;
}
-(WorkCate*) initWithID:(int)workID{
    WorkCate* workcate = [WorkCate alloc];
    workcate.cate_id = workID;
    return workcate;
}

-(NSString *)cate_name
{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    for (NSDictionary *object in appDel.workList){
        if([[object valueForKey:@"cate_id"] integerValue] == self.cate_id){
            return [object valueForKey:@"cate_name"] ;
        }
    }
    
    return @"";
}
@end
