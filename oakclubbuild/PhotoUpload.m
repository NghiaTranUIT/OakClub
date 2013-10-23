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
{
    UIImage *photo;
    NSString *name;
    BOOL isAvatar;
}
@end

@implementation PhotoUpload

@synthesize delegate;

-(id)initWithPhoto:(UIImage *)_photo andName:(NSString *)photoName isAvatar:(BOOL)_isAvatar
{
    if (self = [super init])
    {
        photo = _photo;
        name = photoName;
        isAvatar = _isAvatar;
    }
    
    return self;
}

-(void)uploadPhotoWithCompletion:(void(^)(NSString *))completionHandler
{
    //NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"minus_sign"], 0.4);
    NSData *imgData = UIImagePNGRepresentation(photo);
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"images/png", @"mime_type", [imgData base64Encoding], @"uploadedfile", nil];
    if (isAvatar)
    {
        [params setObject:[NSNumber numberWithBool:isAvatar] forKey:@"is_avatar"];
    }
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_uploadPhoto parameters:params];
    
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
             completionHandler(link);
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
@end