//
//  ImagePool.h
//  OakClub
//
//  Created by Salm on 12/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePool : NSObject

@property (assign, nonatomic) int maxRequestTimeoutToMakeAlert;
@property (readonly, strong, nonatomic) NSDictionary *images;
@property int maxImageCache;

-(void)getImageAtURL:(NSString *)imgID withSize:(CGSize)size asycn:(void (^)(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize))completion;

-(void)setImage:(UIImage *)img forURL:(NSString *)imgURL andSize:(CGSize)size;
@end