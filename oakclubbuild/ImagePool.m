//
//  ImagePool.m
//  OakClub
//
//  Created by Salm on 12/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ImagePool.h"
#import "AppDelegate.h"

@implementation ImagePool
{
    NSMutableDictionary *_images;
}

-(id)init
{
    if (self = [super init])
    {
        _images = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(NSDictionary *)images
{
    return _images;
}

-(void)getImagesAtURL:(NSString *)imgURL asycn:(void (^)(UIImage *img, NSError *error))completion
{
    id img = [_images objectForKey:imgURL];
    if (img)
    {
        if ([img isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray *imgRequesters = (NSMutableArray *) img;
            [imgRequesters addObject:completion];
        }
        else if ([img isKindOfClass:[UIImage class]])
        {
            completion(img, nil);
        }
    }
    else
    {
        NSMutableArray *imgRequesters = [[NSMutableArray alloc] init];
        [imgRequesters addObject:completion];
        [_images setObject:imgRequesters forKey:imgURL];
        
        AFHTTPClient *httpClient;
        NSString *url = imgURL;
        
        if(!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]))
        {       // check if this is a valid link
            httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
        }
        else{
            httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
        }
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:url
                                                          parameters:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             UIImage *image = [UIImage imageWithData:responseObject];
             NSMutableArray *reqs = (NSMutableArray *) [_images objectForKey:imgURL];
             [_images setObject:image forKey:imgURL];
             
             for (int i = 0; i < reqs.count; ++i)
             {
                 void (^handler)(UIImage *img, NSError *error) = [reqs objectAtIndex:i];
                 handler(image, nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSMutableArray *reqs = (NSMutableArray *) [_images objectForKey:imgURL];
             [_images removeObjectForKey:imgURL];
             
             for (int i = 0; i < reqs.count; ++i)
             {
                 void (^handler)(UIImage *img, NSError *error) = [reqs objectAtIndex:i];
                 handler(nil, error);
             }
         }];
        
        [operation start];
    }
}
@end