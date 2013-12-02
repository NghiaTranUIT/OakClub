//
//  VideoUpload.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VideoUploader.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoUploader() <UIAlertViewDelegate>
@end

@implementation VideoUploader

+(void)uploadVideoWithData:(NSData *)videoData useCompletion:(void(^)(NSString *))completionHandler
{
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableURLRequest *myRequest = [client multipartFormRequestWithMethod:@"POST" path:URL_uploadVideo
                                                                 parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                                     [formData appendPartWithFileData:videoData name:@"video" fileName:@"video.mov" mimeType:@"video/quicktime"];
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

+(void)compressVideoAtURL:(NSURL *)url withQuality:(NSString *)quality useCompletion:(void (^)(NSData*)) completion
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:quality];
    //AVAssetExportPresetLowQuality;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    NSString *videoName = @"demo.m4a";
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    exportSession.outputURL = exportUrl;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusCompleted)
        {
            NSData *videoData = [NSData dataWithContentsOfURL:exportUrl];
            completion(videoData);
        }
    }];
}
@end