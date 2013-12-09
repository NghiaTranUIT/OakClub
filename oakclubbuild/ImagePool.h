//
//  ImagePool.h
//  OakClub
//
//  Created by Salm on 12/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePool : NSObject
@property (readonly, strong, nonatomic) NSDictionary *images;

//-(void)getImagesAtURL:(NSString *)imgURL asycn:(void(^)(UIImage *img, NSError *error))completion;
-(void)getImageAtURL:(NSString *)imgURL withSize:(CGSize)size asycn:(void (^)(UIImage *img, NSError *error))completion;
-(UIImage *)getImageSycnAtURL:(NSString *)imgURL withSize:(CGSize)size;

-(void)setImage:(UIImage *)img forURL:(NSString *)imgURL andSize:(CGSize)size;
@end