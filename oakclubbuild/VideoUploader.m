//
//  VideoUpload.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VideoUploader.h"
#import "AppDelegate.h"

@interface VideoUploader() <UIAlertViewDelegate>
{
    NSData *video;
}
@end

@implementation VideoUploader

@synthesize delegate;

-(id)initWithVideoData:(NSData *)videoData
{
    if (self = [super init])
    {
        video = videoData;
    }
    
    return self;
}

-(void)uploadVideoWithCompletion:(void(^)(NSString *))completionHandler
{
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableURLRequest *myRequest = [client multipartFormRequestWithMethod:@"POST" path:URL_uploadVideo
                                                                 parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                                     [formData appendPartWithFileData:video name:@"video" fileName:@"video.mov" mimeType:@"video/quicktime"];
                                                                 }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent video %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
	}];
    
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSError *e;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Send video completed; return %@\n%@%@", [JSON base64Encoding], dict, [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding]); //Lets us know the result including failures
        NSString *link = [dict objectForKey:key_data];
        
        if (completionHandler)
        {
            completionHandler(link);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Upload photo error: %@", error);
        if (completionHandler)
        {
            completionHandler(nil);
        }
    }];
    
    [operation start];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //[self sendPhoto];
    }
    else
    {
        
    }
}
@end