//
//  PhotoUpload.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PhotoUpload.h"
#import "Define.h"
#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"

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

-(void)uploadPhoto
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload photo"
//                                                        message:@"Do you want to set this photo as avatar"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Yes"
//                                              otherButtonTitles:@"No", nil];
//    [alertView show];
    
    [self sendPhoto];
}

#define URL_uploadPhoto @"service/uploadPhotoUser"

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self sendPhoto];
    }
    else
    {
        
    }
}

-(void)sendPhoto
{
    NSData *imgData = UIImagePNGRepresentation(photo);
    NSLog(@"Encoding: %@", [imgData base64Encoding]);
    NSString *imgFileName = [NSString stringWithFormat:@"%@%@",name,@".png"];
    
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableURLRequest *myRequest = [client multipartFormRequestWithMethod:@"POST" path:URL_uploadPhoto
                                                                 parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                                     [formData appendPartWithFileData:imgData name:name fileName:imgFileName mimeType:@"images/png"];
                                                                 }];
    
    NSLog(@"UPLOAD PHOTO HEADER: %@", [myRequest allHTTPHeaderFields]);
    NSLog(@"request {%@} {%@}", [myRequest HTTPMethod], [myRequest description]);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        NSLog(@"UPLOAD PHOTO: Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Send image completed; return %@\n%@", [JSON base64Encoding], dict); //Lets us know the result including failures
     }failure:^(AFHTTPRequestOperation *op, NSError *err){
         
     }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}
@end