//
//  ImageInfo.m
//  OakClub
//
//  Created by VanLuu on 11/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ImageInfo.h"

@implementation ImageInfo
-(id) copyWithZone: (NSZone *) zone{
    ImageInfo *copyObj = [[ImageInfo allocWithZone: zone] init];
    copyObj.s_ID = [self.s_ID copyWithZone:zone];
    copyObj.name = [self.name copyWithZone:zone];
    copyObj.avatar = [self.avatar copyWithZone:zone];
    return copyObj;
}

-(ImageInfo*)initWithID:(NSString*)infoID andName:(NSString*)sName andAvatar:(NSString*)sAvatar{
    ImageInfo* imageInfo = [ImageInfo alloc];
    imageInfo.s_ID = infoID;
    imageInfo.name = sName;
    imageInfo.avatar = sAvatar;
    return imageInfo;
}
@end
