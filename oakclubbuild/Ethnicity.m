//
//  Ethnicity.m
//  OakClub
//
//  Created by VanLuu on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Ethnicity.h"

@implementation Ethnicity
-(id) copyWithZone: (NSZone *) zone{
    Ethnicity *copyObj = [[Ethnicity allocWithZone: zone] init];
    copyObj.ID = self.ID;
    copyObj.text = [self.text copyWithZone:zone];
    return copyObj;
}
-(Ethnicity*)initWithID:(int)ethnicityID andName:(NSString*)nameText{
    Ethnicity* ethnicity = [Ethnicity alloc];
    ethnicity.ID = ethnicityID;
    ethnicity.text = nameText;
    return ethnicity;
}

@end
