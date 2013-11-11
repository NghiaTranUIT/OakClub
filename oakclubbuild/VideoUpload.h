//
//  VideoUpload.h
//  OakClub
//
//  Created by VanLuu on 11/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoUpload : NSObject{
    NSData* videoData;
}
-(id)initWithVideoData:(NSData *)data andName:(NSString *)videoName;
-(void)uploadVideoWithCompletion:(void(^)(void))completionHandler;
@end
