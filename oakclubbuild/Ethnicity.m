//
//  Ethnicity.m
//  OakClub
//
//  Created by VanLuu on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Ethnicity.h"
#import "AppDelegate.h"

@implementation Ethnicity
-(id) copyWithZone: (NSZone *) zone{
    Ethnicity *copyObj = [[Ethnicity allocWithZone: zone] init];
    copyObj.ID = self.ID;
    copyObj.name = [self.name copyWithZone:zone];
    return copyObj;
}
-(Ethnicity*)initWithID:(int)ethnicityID andName:(NSString*)nameText{
    Ethnicity* ethnicity = [Ethnicity alloc];
    ethnicity.ID = ethnicityID;
    ethnicity.name = nameText;
    return ethnicity;
}
-(Ethnicity*) initWithID:(int)ethnicityID{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    Ethnicity* ethnicity = [Ethnicity alloc];
    ethnicity.ID = ethnicityID;
    for (NSDictionary *object in appDel.ethnicityList){
        if([[object valueForKey:@"id"] integerValue] == ethnicityID){
            ethnicity.name = [object valueForKey:@"name"] ;
            return ethnicity;
        }
        
    }
    return nil;
}
@end
