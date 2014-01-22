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
    NSOperationQueue *operationQueue;
}

#define NUMBER_OF_IMAGE_REMOVED 3
@synthesize maxImageCache;

-(id)init
{
    if (self = [super init])
    {
        _images = [[NSMutableDictionary alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        _maxRequestTimeoutToMakeAlert = 1;
        _requestTimeoutToMakeAlertCount = 100;
        maxImageCache = NSIntegerMax;
    }
    
    return self;
}

-(NSDictionary *)images
{
    return _images;
}

-(void)getImageAtURL:(NSString *)imgID withSize:(CGSize)size asycn:(void (^)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize))completion
{
    NSString *url = [self makeURL:imgID withSize:size];
    //    NSLog(@"REQUEST POOL url %@", url);
    
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
            //            NSLog(@"IMAGE POOL success immediate %@", img);
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
        
        //        NSLog(@"PHOTO REQUEST POOL photoRequestURL %@", request.URL.absoluteString);
        
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
                 [self checkMaxCache];
             }
             
             //             NSLog(@"IMAGE POOL success %@", image);
             
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
        
        [operationQueue addOperation:operation];
    }
}

-(void)getImageAtURL:(NSString *)imgID asycn:(void (^)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize))completion
{
    if (!completion)    // force nil completion
        return;
    
    NSString *urlLarge = [self makeURL:imgID withSize:PHOTO_SIZE_LARGE];
    id largeImage = [self.images objectForKey:urlLarge];
    NSString *urlSmall = [self makeURL:imgID withSize:PHOTO_SIZE_SMALL];
    id smallImage = [self.images objectForKey:urlSmall];
    
    if ([largeImage isKindOfClass:[UIImage class]])   // if already have large image
    {
        completion(largeImage, nil, false, urlLarge);
    }
    else if ([largeImage isKindOfClass:[NSMutableArray class]])  // if large image is loading
    {
        if ([smallImage isKindOfClass:[UIImage class]]) // if already have small image
        {
            completion(smallImage, nil, false, urlSmall);
        }
        else    // add completion to large handlers
        {
            [largeImage addObject:completion];
        }
    }
    else // if(!image) -- have never download large image
    {
        if ([smallImage isKindOfClass:[UIImage class]]) // if already have small image
        {
            completion(smallImage, nil, false, urlSmall);
        }
        else if ([smallImage isKindOfClass:[NSMutableArray class]]) // if small image is loading
        {
            [smallImage addObject:completion];
        }
        else // if (!smallImage)
        {
            // start download large image
            [self getImageAtURL:imgID withSize:PHOTO_SIZE_LARGE asycn:completion];
        }
    }
}

-(NSString *)makeURL:(NSString *)url withSize:(CGSize)size
{
    NSString *urlWithSize = [NSString stringWithFormat: @"%@?width=%d&height=%d", url, (int)size.width, (int)size.height];
    return urlWithSize;
}


-(void)setImage:(UIImage *)img forURL:(NSString *)imgID andSize:(CGSize)size
{
    NSString *url = [self makeURL:imgID withSize:size];
    if (img)
    {
        [_images setObject:img forKey:url];
        [self checkMaxCache];
    }
}

-(int)checkMaxCache
{
    if (_images.count > maxImageCache)
    {
        int nRemoved = MIN(NUMBER_OF_IMAGE_REMOVED, _images.count);
        
        NSMutableArray *removeKeys = [[NSMutableArray alloc] initWithCapacity:nRemoved];
        NSArray *imgKeys = [_images allKeys];
        for (int i = 0; i < nRemoved; ++i)
        {
            [removeKeys addObject:imgKeys[i]];
        }
        
        for (NSString *imgKey in  imgKeys) {
            [_images removeObjectForKey:imgKey];
        }
        
        return nRemoved;
    }
    
    return 0;
}
@end