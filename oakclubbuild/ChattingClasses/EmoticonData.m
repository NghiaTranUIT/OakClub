//
//  EmoticonData.m
//  OakClub
//
//  Created by Salm on 2/24/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "EmoticonData.h"
#import "ImagePool.h"

#pragma mark DEFAULT EMOTICON DATA
@interface DefEmoticonData : NSObject <EmoticonData>
-(id)initWithKey:(NSString *)key andDataLink:(NSString *)link;
@property (readonly, nonatomic) NSString *key;
@property (readonly, nonatomic) NSString *dataLink;

-(void)loadImageAsycn:(void (^)(UIImage *, NSError *))callback;
-(UIImage *)tryLoadImageSycn;
@end

@implementation DefEmoticonData
{
    NSString *_key, *_link;
    UIImage *_image;
}

-(id)initWithKey:(NSString *)key andDataLink:(NSString *)link
{
    if (self = [super init])
    {
        _key = key;
        _link = link;
    }
    
    return self;
}

-(NSString *)key
{
    return _key;
}

-(NSString *)dataLink
{
    return _link;
}

-(UIImage *)image
{
    if (!_image)
    {
        [self getImageAsycn:^(UIImage *image, NSError *e) {
            _image = image;
        }];
    }
    
    return _image;
}

-(void)getImageAsycn:(void (^)(UIImage *, NSError *))callback
{
    if (_image && callback)
    {
        callback(_image, nil);
    }
    else
    {
        [self loadImageAsycn:^(UIImage *img, NSError *e) {
            callback(img, e);
        }];
    }
}

-(void)loadImageAsycn:(void (^)(UIImage *, NSError *))callback
{
    callback(_image, nil);
}

-(UIImage *)tryLoadImageSycn
{
    return nil;
}
@end

#pragma mark EMOTICON DATAS
@interface BundleEmoticon : DefEmoticonData
@end

@implementation BundleEmoticon

-(void)loadImageAsycn:(void (^)(UIImage *, NSError *))callback
{
    if (callback)
    {
        UIImage *image = [UIImage imageNamed:self.dataLink];
        callback(image, nil);
    }
}

@end

// ----------------------------------------
@interface DocumentEmoticon : DefEmoticonData
@end

@implementation DocumentEmoticon

-(void)loadImageAsycn:(void (^)(UIImage *, NSError *))callback
{
    if (callback)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *stickersFilePath = [NSString stringWithFormat:@"%@/%@", documentsPath, @"sticker"];
        NSString *stFilePath = [NSString stringWithFormat:@"%@/%@", stickersFilePath, self.dataLink];
        UIImage *image = [UIImage imageWithContentsOfFile:stFilePath];
        callback(image, nil);
    }
}

@end


// ----------------------------------------
@interface ServerEmoticion : DefEmoticonData
@end

@implementation ServerEmoticion

-(void)loadImageAsycn:(void (^)(UIImage *, NSError *))callback
{
    [ImagePool getImageAdHocAtURL:self.dataLink asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        callback(img, error);
    }];
}
@end


#pragma mark EMOTICON DATA FACTORIES
@implementation BundleEmoticonDataFactory
+(BundleEmoticonDataFactory *)instance
{
    static BundleEmoticonDataFactory *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[BundleEmoticonDataFactory alloc] init];
    });
    
    return sharedInst;
}

-(id<EmoticonData>)createEmoticonDataForKey:(NSString *)key andLink:(NSString *)link
{
    return [[BundleEmoticon alloc] initWithKey:key andDataLink:link];
}

@end


// ----------------------------------------
@implementation DocumentEmoticonDataFactory

+(DocumentEmoticonDataFactory *)instance
{
    static DocumentEmoticonDataFactory *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[DocumentEmoticonDataFactory alloc] init];
    });
    
    return sharedInst;
}

-(id<EmoticonData>)createEmoticonDataForKey:(NSString *)key andLink:(NSString *)link
{
    return [[DocumentEmoticon alloc] initWithKey:key andDataLink:link];
}

@end


// ----------------------------------------
@implementation ServerEmoticionDataFactory
{
    NSString *dataDomain;
}

-(id)initWithDomain:(NSString *)domain
{
    if (self = [super init])
    {
        dataDomain = domain;
    }
    
    return self;
}

-(id<EmoticonData>)createEmoticonDataForKey:(NSString *)key andLink:(NSString *)link
{
    NSString *fullDataLink = [NSString stringWithFormat:@"%@/%@", dataDomain, link];
    return [[ServerEmoticion alloc] initWithKey:key andDataLink:fullDataLink];
}

@end