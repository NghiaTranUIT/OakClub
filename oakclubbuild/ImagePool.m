//
//  ImagePool.m
//  OakClub
//
//  Created by Salm on 12/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ImagePool.h"
#import "AppDelegate.h"

@interface ImagePool ()

@property (assign, nonatomic) int requestTimeoutToMakeAlertCount;

@end

@implementation ImagePool
{
    NSMutableDictionary *_images;
}

-(id)init
{
    if (self = [super init])
    {
        _images = [[NSMutableDictionary alloc] init];
        _maxRequestTimeoutToMakeAlert = 100;
        _requestTimeoutToMakeAlertCount = 0;
    }
    
    return self;
}

-(NSDictionary *)images
{
    return _images;
}

-(void)getImageAtURL:(NSString *)imgID withSize:(CGSize)size asycn:(void (^)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize))completion
{
    NSString *url = [NSString stringWithFormat: @"%@?width=%d&height=%d", imgID, (int)size.width, (int)size.height];
    NSLog(@"REQUEST POOL url %@", url);
    
    id img = [_images objectForKey:url];
    
    if (img)
    {
        if ([img isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray *imgRequesters = (NSMutableArray *) img;
            [imgRequesters addObject:completion];
        }
        else if ([img isKindOfClass:[UIImage class]])
        {
            NSLog(@"IMAGE POOL success immediate %@", img);
            completion(img, nil, NO, url);
        }
    }
    else
    {
        NSMutableArray *imgRequesters = [[NSMutableArray alloc] init];
        [imgRequesters addObject:completion];
        
        [_images setObject:imgRequesters forKey:url];
        
        NSString *photoRequestURL;
        NSDictionary *params;
        if ([imgID hasPrefix:@"http"])
        {
            photoRequestURL = imgID;
            if (![imgID hasSuffix:@".jpg"])
            {
                params = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:(int) size.width], @"width",
                          [NSNumber numberWithInteger:(int) size.height], @"height",
                          nil];
            }
        }
        else
        {
            photoRequestURL = URL_PHOTO;
            params = [NSDictionary dictionaryWithObjectsAndKeys:imgID, @"file",
                      [NSNumber numberWithInteger:(int) size.width], @"width",
                      [NSNumber numberWithInteger:(int) size.height], @"height",
                      [NSNumber numberWithInt:1], @"mode", nil];
        }
        
        AFHTTPClient *httpClient;
        httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:photoRequestURL
                                                          parameters:params];
        [request setTimeoutInterval:13];
        
        NSLog(@"PHOTO REQUEST POOL photoRequestURL %@", request.URL.absoluteString);
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             UIImage *image = [UIImage imageWithData:responseObject];
             NSMutableArray *reqs = (NSMutableArray *) [_images objectForKey:url];
             [_images removeObjectForKey:url];
             
             if(image)
             {
                 [_images setObject:image forKey:url];
             }
             
             NSLog(@"IMAGE POOL success %@", image);
             
             for (int i = 0; i < reqs.count; ++i)
             {
                 void (^handler)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) = [reqs objectAtIndex:i];
                 handler(image, nil, YES, url);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"IMAGE POOL error %@", error);
             
             //process to detect many timeout
             if (error.code == kCFURLErrorTimedOut) {
                 self.requestTimeoutToMakeAlertCount++;
                 
                 if (self.requestTimeoutToMakeAlertCount >= self.maxRequestTimeoutToMakeAlert) {
                     self.requestTimeoutToMakeAlertCount = 0; //reset
                     
                     //alert timeout too many
                     NSLog(@"IMAGE POOL too many timeout");
                     AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
                     [appDel showErrorSlowConnection:@"IMAGE POOL too many timeout"];
                 }
             }

             NSMutableArray *reqs = (NSMutableArray *) [_images objectForKey:url];
             [_images removeObjectForKey:url];
             
             for (int i = 0; i < reqs.count; ++i)
             {
                 void (^handler)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) = [reqs objectAtIndex:i];
                 handler(nil, error, YES, url);
             }
         }];
        
        [operation start];
    }
}

-(void)setImage:(UIImage *)img forURL:(NSString *)imgID andSize:(CGSize)size
{
    NSString *url = [NSString stringWithFormat: @"%@?width=%d&height=%d", imgID, (int)size.width, (int)size.height];
    if (img)
    {
        [_images setValue:img forKey:url];
    }
}

@end