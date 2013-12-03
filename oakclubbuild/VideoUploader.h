//
//  VideoUploader.h
//  OakClub
//
//  Created by Salm on 11/15/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoUploader : NSObject
+(void)uploadVideoWithData:(NSData *)videoData useCompletion:(void(^)(NSString *))completionHandler;
+(void)compressVideoAtURL:(NSURL *)url withQuality:(NSString *)quality useCompletion:(void (^)(NSData*)) completion;
@end
