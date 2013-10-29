//
//  PhotoUpload.h
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotoUploadDelegate
-(void)photoUploadedWithLink:(NSString*)photoLink;
@end

@interface PhotoUpload : NSObject
-(id)initWithPhoto:(UIImage *)_photo andName:(NSString *)photoName isAvatar:(BOOL)_isAvatar;
-(void)uploadPhotoWithCompletion:(void(^)(NSString *, NSString *))completionHandler;

@property id<PhotoUploadDelegate> delegate;
@end
