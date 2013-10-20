//
//  PhotoViewController.h
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageScrollView.h"

@interface PhotoViewController : UIViewController<UIScrollViewDelegate>
{
    NSString* profile_id;
    UIScrollView *pagingScrollView;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
    
    NSUInteger kNumImages;
    NSArray* _imagesData;
    NSMutableDictionary* photos;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;

- (NSUInteger)imageCount;
- (NSString *)imageNameAtIndex:(NSUInteger)index;
- (CGSize)imageSizeAtIndex:(NSUInteger)index;
- (UIImage *)imageAtIndex:(NSUInteger)index;

@property NSString* profile_id;

@property (weak, nonatomic) IBOutlet UILabel        *labelCurrentImage;
@property (weak, nonatomic) IBOutlet UIButton       *buttonClose;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImageIndicator;

- (id)initWithProfileID:(NSString*)_id;

@end
