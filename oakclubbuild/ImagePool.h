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

-(void)getImagesAtURL:(NSString *)imgURL asycn:(void(^)(UIImage *img, NSError *error))completion;
-(void)getImagesAtURL:(NSString *)imgURL withSize:(CGSize)size asycn:(void (^)(UIImage *img, NSError *error))completion;
@end