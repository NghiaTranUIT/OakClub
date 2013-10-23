//
//  PhotoUpload.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PhotoUpload.h"
#import "AppDelegate.h"

@interface PhotoUpload() <UIAlertViewDelegate>

@end

@implementation PhotoUpload
UIImage *photo;
NSString *name;

@synthesize delegate;

-(id)initWithPhoto:(UIImage *)_photo andName:(NSString *)photoName
{
    if (self = [super init])
    {
        photo = _photo;
        name = photoName;
    }
    
    return self;
}

-(void)uploadPhotoWithCompletion:(void(^)(NSString *))completionHandler
{
    //NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"minus_sign"], 0.4);
    NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"minus_sign"]);
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSString *encode = [NSString stringWithString:[imgData base64Encoding]];
    NSLog(@"Encode: %@ and withUTF8", encode);
//    NSLog(@"Upload photo params: %@", params);
//    [client postPath:URL_uploadPhoto parameters:params success:^(AFHTTPRequestOperation *op, id JSON)
//     {
//         NSString *res = [[NSString alloc] initWithData:JSON encoding:NSStringEncodingConversionAllowLossy];
//         NSError *e;
//         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//         NSLog(@"Send image completed; return %@\n%@\t%@", [JSON base64Encoding], dict, res); //Lets us know the result including failures
//         NSDictionary *data = [dict objectForKey:key_data];
//         NSString *link = [data objectForKey:@"file"];
//         
////         if (completionHandler)
////         {
////             completionHandler([NSString stringWithFormat:@"%@%@", DOMAIN_DATA, link]);
////         }
//     }failure:^(AFHTTPRequestOperation *op, NSError *err)
//     {
//         NSLog(@"Upload photo error: %@", err);
//     }];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"images/png", @"mime_type", encode, @"uploadedfile", nil];
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_uploadPhoto parameters:params];
    
    NSLog(@"UPLOAD PHOTO HEADER: %@", [myRequest allHTTPHeaderFields]);
    NSLog(@"request {%@} {%@}", [myRequest HTTPMethod], [myRequest description]);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Send image completed; return %@\n%@", [JSON base64Encoding], dict); //Lets us know the result including failures
         NSDictionary *data = [dict objectForKey:key_data];
         NSString *link = [data objectForKey:@"file"];
         
         
         if (completionHandler)
         {
             completionHandler([NSString stringWithFormat:@"%@%@", DOMAIN_DATA, link]);
         }
     }failure:^(AFHTTPRequestOperation *op, NSError *err)
     {
         NSLog(@"Upload photo error: %@", err);
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

//#define MULTIPART
-(void)sendPhotoWithCompletion:(void(^)(NSString *))completionHandler
{
    name = @"uploadedfile";
    NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"bg"]);
    NSLog(@"Encoding: %@", [imgData base64Encoding]);
    
    
#ifdef MULTIPART
//    AFHTTPClient *client= [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://staging-upload.oakclub.com/"]];
//    AppDelegate *appDel = (id)[UIApplication sharedApplication].delegate;
//    Profile *myProfile = appDel.myProfile;
//    NSString *baseName = [[NSNumber numberWithLong:random()] description];
//    NSString *imgFileName = [NSString stringWithFormat:@"%@_%@.png", name, baseName];
//    
//    NSMutableURLRequest *myRequest = [client multipartFormRequestWithMethod:@"POST" path:@"upload.php"
//                                                                 parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//                                                                     [formData appendPartWithFileData:imgData name:@"file" fileName:imgFileName mimeType:@"images/png"];
//                                                                 }];
//    
//    NSLog(@"UPLOAD PHOTO HEADER: %@", [myRequest allHTTPHeaderFields]);
//    NSLog(@"request {%@} {%@}", [myRequest HTTPMethod], [myRequest description]);
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"UPLOAD PHOTO: Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
//     {
//         NSString *fileURL = [NSString stringWithFormat:@"%@%@", @"http://staging-upload.oakclub.com/file_upload/", imgFileName];
//         
//         if (completionHandler)
//         {
//             completionHandler(fileURL);
//         }
//     }failure:^(AFHTTPRequestOperation *op, NSError *err){
//         
//     }];
#else
    
//    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_uploadPhoto parameters:params];
//    
//    NSLog(@"UPLOAD PHOTO HEADER: %@", [myRequest allHTTPHeaderFields]);
//    NSLog(@"request {%@} {%@}", [myRequest HTTPMethod], [myRequest description]);
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
//     {
//         NSError *e;
//         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//         NSLog(@"Send image completed; return %@\n%@", [JSON base64Encoding], dict); //Lets us know the result including failures
//         NSDictionary *data = [dict objectForKey:key_data];
//         NSString *link = [data objectForKey:@"file"];
//         
//         
//         if (completionHandler)
//         {
//             completionHandler([NSString stringWithFormat:@"%@%@", DOMAIN_DATA, link]);
//         }
//     }failure:^(AFHTTPRequestOperation *op, NSError *err)
//     {
//         NSLog(@"Upload photo error: %@", err);
//     }];
#endif
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //[queue addOperation:operation];
}
@end