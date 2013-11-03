//
//  PhotoViewController.m
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//


#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "Profile.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize labelCurrentImage, buttonClose, profile_id,imageBackground, loadingImageIndicator;



- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)onTap_ButtonClose:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithProfileID:(NSString*)_id
{
    self = [super initWithNibName:@"PhotoViewController" bundle:nil];
    if (self) {
        self.profile_id = _id;
    }
    return self;
}

-(void)setPageIndex:(NSUInteger)index
{
    if(index > 0 && index <= kNumImages)
    [labelCurrentImage setText:[NSString stringWithFormat:@"%d/%d", index, kNumImages]];
}

- (void)viewDidLoad
{
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    [super viewDidLoad];
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:profile_id, key_profileID, nil];

    [loadingImageIndicator startAnimating];
    
    [request getPath:URL_getListPhotos parameters:params
             success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSMutableArray* listPhotos = [Profile parseListPhotos:JSON];
         
         if(listPhotos != nil)
         {
             _imagesData = [[NSArray alloc]initWithArray:listPhotos];
             photos = [[NSMutableDictionary alloc] init];
             kNumImages = 0;
             
             if([_imagesData count] == 0)
             {
                 [loadingImageIndicator stopAnimating];
                 loadingImageIndicator.hidden = YES;
             }
             else
             {
                 for(int i = 0; i < [_imagesData count]; i++)
                 {
                     NSString* link = [_imagesData objectAtIndex:i];
                     
                     if( ![link isEqualToString:@""] )
                     {
                         AFHTTPRequestOperation *operation =
                         [Profile getAvatarSync:link
                                       callback:^(UIImage *image)
                          {
                              [photos setObject:image forKey:link];
                              
                              if( i == 0)
                              {
                                  [self initView];
                                  [loadingImageIndicator stopAnimating];
                              }
                          }];
                         [operation start];
                         
                         kNumImages++;
                     }
                 }

             }
             
         }
                 
         [self setPageIndex:1];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self setLabelCurrentImage:nil];
    [self setButtonClose:nil];
    [self setLabelCurrentImage:nil];
    [self setImageBackground:nil];

    pagingScrollView = nil;
    recycledPages = nil;
    visiblePages = nil;
    [self setLoadingImageIndicator:nil];
    [super viewDidUnload];
    
    
}

#pragma mark -
#pragma mark View loading and unloading

- (void)initView
{
    // Step 1: make the outer paging scroll view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    pagingScrollView.pagingEnabled = YES;
//    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    pagingScrollView.delegate = self;
    [pagingScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:pagingScrollView];
    
    // Step 2: prepare to tile content
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
    [self tilePages];
    
    [self.view bringSubviewToFront:buttonClose];
    [self.view bringSubviewToFront:imageBackground];
    [self.view bringSubviewToFront:labelCurrentImage];
}

#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages
{
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollView alloc] init];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    // Use tiled images
    //    [page displayTiledImageNamed:[self imageNameAtIndex:index]
    //                            size:[self imageSizeAtIndex:index]];
    
    // To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
    // above by the following line:
    [page displayImage:[self imageAtIndex:index]];
}


#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    NSUInteger pageIndex = floorf(offset / pageWidth) + 1;
    [self setPageIndex:pageIndex];
    
    NSLog(@"scrollViewDidScroll at page: %d", pageIndex);
    [self tilePages];
}

#pragma mark -
#pragma mark View controller rotation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}

#pragma mark -
#pragma mark  Frame calculations
#define PADDING  10

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self imageCount], bounds.size.height);
}


#pragma mark -
#pragma mark Image wrangling

- (NSArray *)imageData {
    //static NSArray *__imageData = nil; // only load the imageData array once
    //    if (__imageData == nil) {
    //        // read the filenames/sizes out of a plist in the app bundle
    //        NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageData" ofType:@"plist"];
    //        NSData *plistData = [NSData dataWithContentsOfFile:path];
    //        NSString *error; NSPropertyListFormat format;
    //        __imageData = [[NSPropertyListSerialization propertyListFromData:plistData
    //                                                        mutabilityOption:NSPropertyListImmutable
    //                                                                  format:&format
    //                                                        errorDescription:&error]
    //                       retain];
    //        if (!__imageData) {
    //            NSLog(@"Failed to read image names. Error: %@", error);
    //            [error release];
    //        }
    //    }
    

    
    return _imagesData;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    NSLog(@"imageAtIndex: %d", index);
    
    // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
    
    NSString *imageName = [self imageNameAtIndex:index];
    //NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    //return [UIImage imageWithContentsOfFile:path];

    
    UIImage* image = [photos objectForKey:imageName];

        

    
    return image;
}

- (NSString *)imageNameAtIndex:(NSUInteger)index {
    NSLog(@"imageNameAtIndex: %d/%d", index, [self imageCount]);
    
    NSString *name = nil;
    if (index < [self imageCount]) {
        //NSDictionary *data = [[self imageData] objectAtIndex:index];
        //name = [data valueForKey:@"name"];
        
        name = [_imagesData objectAtIndex:index];
    }
    return name;
}

- (CGSize)imageSizeAtIndex:(NSUInteger)index {
    NSLog(@"imageSizeAtIndex: %d", index);
    CGSize size = CGSizeZero;
    if (index < [self imageCount]) {
        NSDictionary *data = [[self imageData] objectAtIndex:index];
        size.width = [[data valueForKey:@"width"] floatValue];
        size.height = [[data valueForKey:@"height"] floatValue];
    }
    return size;
}

- (NSUInteger)imageCount {
//    static NSUInteger __count = NSNotFound;  // only count the images once
//    if (__count == NSNotFound) {
//       __count = [[self imageData] count];
//    }
//    return __count;
    return [[self imageData] count];
}


@end
