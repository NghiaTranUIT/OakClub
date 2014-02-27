//
//  EmoticonData.h
//  OakClub
//
//  Created by Salm on 2/12/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EmoticonData <NSObject>
@property (readonly, nonatomic) NSString *key;
@property (readonly, nonatomic) NSString *dataLink;
@property (readonly, nonatomic) UIImage *image;

-(void)getImageAsycn:(void(^)(UIImage *image, NSError *e))callback;
@end

@protocol EmoticonDataFactory <NSObject>
-(id<EmoticonData>)createEmoticonDataForKey:(NSString *)key andLink:(NSString *)link;
@end

@interface BundleEmoticonDataFactory : NSObject <EmoticonDataFactory>
+(BundleEmoticonDataFactory *)instance;
@end

@interface DocumentEmoticonDataFactory : NSObject <EmoticonDataFactory>
+(DocumentEmoticonDataFactory *)instance;
@end

@interface ServerEmoticionDataFactory : NSObject <EmoticonDataFactory>
-(id)initWithDomain:(NSString *)dataDomain;
@end