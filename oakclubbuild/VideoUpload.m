//
//  VideoUpload.m
//  OakClub
//
//  Created by VanLuu on 11/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VideoUpload.h"
#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"
#import "Define.h"

@implementation VideoUpload
-(id)initWithVideoData:(NSData *)data andName:(NSString *)videoName
{
    if (self = [super init])
    {
        videoData = data;
    }
    
    return self;
}

-(void)uploadVideoWithCompletion:(void(^)(void))completionHandler
{
    //NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"minus_sign"], 0.4);
//    NSData *imgData = UIImagePNGRepresentation(videoData);
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableURLRequest *afRequest = [client multipartFormRequestWithMethod:@"POST" path:@"service/uploadVideoUser" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:videoData name:@"file" fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                      }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
     {
         
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
         if (completionHandler)
         {
             completionHandler();
         }
     }];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {NSLog(@"Success");}
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {NSLog(@"error: %@",  operation.responseString);}];
    [operation start];
    
    /*
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"images/png", @"mime_type", [imgData base64Encoding], @"uploadedfile", nil];

    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_uploadPhoto parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Send image completed; return %@\n%@", [JSON base64Encoding], dict); //Lets us know the result including failures
         NSDictionary *data = [dict objectForKey:key_data];
         NSString *link = [data objectForKey:@"file"];
         NSString *imgID = [data objectForKey:@"id"];
         
         if (completionHandler)
         {
             completionHandler(link, imgID);
         }
     }failure:^(AFHTTPRequestOperation *op, NSError *err)
     {
         NSLog(@"Upload photo error: %@", err);
         if (completionHandler)
         {
             completionHandler(nil, nil);
         }
     }];
    
    [operation start];
     */
}
@end
