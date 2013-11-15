//
//  VideoUploader.h
//  OakClub
//
//  Created by Salm on 11/15/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoUploaderDelegate
-(void)videoUploadedWithLink:(NSString*)photoLink;
@end

@interface VideoUploader : NSObject
-(id)initWithVideoData:(NSData *)videoData;
-(void)uploadVideoWithCompletion:(void(^)(NSString *))completionHandler;

@property id<VideoUploaderDelegate> delegate;
@end
