//
//  Gender.m
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Gender.h"
#import "Define.h"
@implementation Gender
-(id) copyWithZone: (NSZone *) zone{
    Gender *copyObj = [[Gender allocWithZone: zone] init];
    copyObj.ID = self.ID;
    copyObj.text = [self.text copyWithZone:zone];
    return copyObj;
}
-(Gender*)initWithID:(int)genderID{
    Gender* gender = [Gender alloc];
    gender.ID = 0;
    gender.text = @"";
    switch (genderID) {
        case 0:
            gender.ID = 0;
            gender.text = @"Female";
            break;
        case 1:
            gender.ID = 1;
            gender.text = @"Male";
            break;
        case 2:
            gender.ID = 2;
            gender.text = @"Both";
            break;
    }
    return gender;
}
-(Gender*)initWithNSString:(NSString*)genderText{
    Gender* gender = [Gender alloc];
    gender.text = genderText;
    if ([gender.text isEqualToString:value_Female]) {
        gender.ID = 0;
        gender.text = @"Female";
    }
    else{
        if ([gender.text isEqualToString:value_Male]) {
            gender.ID = 1;
            gender.text = @"Male";
        }
        else{
            gender.ID = 2;
            gender.text = @"Both";
        }
    }
    return gender;
}
@end
