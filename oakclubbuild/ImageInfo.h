//
//  ImageInfo.h
//  OakClub
//
//  Created by VanLuu on 11/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageInfo : NSObject
@property (strong, nonatomic) NSString *s_ID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatar;

-(ImageInfo*)initWithID:(NSString*)infoID andName:(NSString*)sName andAvatar:(NSString*)sAvatar;
@end
