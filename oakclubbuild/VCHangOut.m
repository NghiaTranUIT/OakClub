//
//  VCHangOut.m
//  oakclubbuild
//
//  Created by hoangle on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCHangOut.h"
#import "AppDelegate.h"
#import "ODRefreshControl.h"
@interface VCHangOut (){
     __strong NSMutableDictionary *_requestsImage;
    __strong NSMutableDictionary *_featureImageList;
}
@property (strong, nonatomic)NSMutableArray *_featureProfileList;
@property (nonatomic, retain) OverlayViewController *overlayViewController;

- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
@end




@interface VCHangOut (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name;
- (NSMutableArray *)_featureProfileList;
- (void)createThumbScrollViewIfNecessary;
- (void)createSlideUpViewIfNecessary;
@end




@interface VCHangOut (AutoscrollingMethods)
- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb;
- (void)autoscrollTimerFired:(NSTimer *)timer;
- (void)legalizeAutoscrollDistance;
- (float)autoscrollDistanceForProximityToEdge:(float)proximity;
@end




@implementation VCHangOut

@synthesize tb_NearBy, scrollview_addMeHere,btn_addMeHere, leftBG, _featureProfileList, tb_Avatars;
@synthesize loadingHangout;
int skip=0;
int limitRecordPerPage=10;
AppDelegate* appDelegate;
ViewCellMyLink *oldAvatarCell;
int indexAvatarSelected;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate= [self appDelegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    // Do any additional setup after loading the view from its nib.
     request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    _requestsImage = [[NSMutableDictionary alloc] init];
    [self initDataNearByTableView];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tb_NearBy];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    _featureImageList = [[NSMutableDictionary alloc] init];
    [self  loadFeatureProfileList];
    
    self.overlayViewController =[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil];
    
    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.overlayViewController.delegate = self;
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        // camera is not on this device, don't show the camera button
//        NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:self.myToolbar.items.count];
//        [toolbarItems addObjectsFromArray:self.myToolbar.items];
//        [toolbarItems removeObjectAtIndex:2];
//        [self.myToolbar setItems:toolbarItems animated:NO];
//    }

}
#pragma mark -refresh controller
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 0.0;
    [self initDataNearByTableView];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}
#pragma mark OverlayViewControllerDelegate

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [self.imgPhoto setImage:picture];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
//    [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
}
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if (self.imgPhoto.isAnimating)
        [self.imgPhoto stopAnimating];
	
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.overlayViewController.imagePickerController animated:YES];
    }
}
- (IBAction)photoLibraryAction:(id)sender
{
	[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated{
    
//    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];

//    [self  loadFeatureProfileList];
    
    //[tb_NearBy setEditing:YES animated:YES];

}

- (void)viewDidUnload {
    [self setTb_NearBy:nil];
    [self setScrollview_addMeHere:nil];
    [self setBtn_addMeHere:nil];
    [self setLeftBG:nil];
    [self setLoadingHangout:nil];
    [self setImgPhoto:nil];
    [self setAddmehereView:nil];
    [self setTb_Avatars:nil];
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];

    int totalNotifications = [appDelegate countTotalNotifications];
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    NavBarOakClub* navbar = (NavBarOakClub*)navcon.navigationBar;
    [navbar setNotifications:totalNotifications];
}


- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (IBAction)finishAddMeHere:(id)sender {
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:[appDelegate.myProfile.arr_photos objectAtIndex:indexAvatarSelected],@"image_link",nil];
    
    [request getPath:URL_setBidFeature parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        int status= (int)[dict valueForKey:key_status];
        if(status)
            NSLog(@"set Bid Feature Success!");
        else
            NSLog(@"set Bid Feature Faild!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_setBidFeature - Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

- (IBAction)btn_addMeHere:(id)sender {
    [self.view addSubview:self.addmehereView.view];
    [self.view bringSubviewToFront:self.addmehereView.view];
    [tb_Avatars reloadData];

}
#pragma mark UIGridView init methods
- (void) initDataNearByTableView
{
    [tb_NearBy setShowsVerticalScrollIndicator:NO];
    tb_NearBy.headerName = @"Near By";
    tb_NearBy.backgroundColor   = [UIColor clearColor];
    tb_NearBy.arrayProfile = [[NSMutableArray alloc] init];
    skip = 0;
    [self reloadDataSourceForNearByTableView];
}

-(BOOL)reloadDataSourceForNearByTableView{
    //================ load NearBy==================
//    loadingHangout.hidden = NO;
//    [loadingHangout startAnimating];
    ProfileSetting* settings = appDelegate.accountSetting;
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            settings.purpose_of_search,                            @"purposeOfSearch",
                            settings.gender_of_search,                             @"genderOfSearch",
                            [NSString stringWithFormat:@"%d", settings.age_from] , @"ageFrom",
                            [NSString stringWithFormat:@"%d", settings.age_to],    @"ageTo",
                            [NSString stringWithFormat:@"%d", settings.range],     @"range",
                            (settings.interested_new_people?@"1":@"0"),     @"newPeople",
                            (settings.interested_friends?@"1":@"0"),        @"friends",
                            (settings.interested_friend_of_friends?@"1":@"0"), @"fOfF",
                            [NSString stringWithFormat:@"%d",skip], @"skip",
                            [NSString stringWithFormat:@"%d", limitRecordPerPage], @"limit",
                            ([[NSUserDefaults standardUserDefaults] boolForKey:key_isUseGPS]?@"1":@"0"), @"locationType",
                            [NSString stringWithFormat:@"%f", settings.location.longitude], @"lng",
                            [NSString stringWithFormat:@"%f", settings.location.latitude], @"lat",
                            @"1", @"refresh",
                            nil
                            ];
    
    [request getPath:URL_searchByLocation parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *newProfiles = [Profile parseProfileToArrayByJSON:JSON];
        for (Profile* profile in newProfiles) {
            NSString *link = profile.s_Avatar;
            if(![link isEqualToString:@""])
            {
                AFHTTPClient *request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
                [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
                 {
                     UIImage *avatar = [UIImage imageWithData:JSON];
                     [_requestsImage setObject:avatar forKey:link];
                     [tb_NearBy.arrayProfile addObject:profile];
                     [tb_NearBy reloadData];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                 }];
                
            }
            
        }
        if([newProfiles count]>0){
            //            [tb_NearBy.arrayProfile addObjectsFromArray:newProfiles];
            //            [tb_NearBy reloadData];
            skip+=[newProfiles count];
            [loadingHangout stopAnimating];
            loadingHangout.hidden = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_searchByLocation Error Code: %i - %@",[error code], [error localizedDescription]);
        
        //        [loadingHangout stopAnimating];
//        loadingHangout.hidden = YES;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        // Make new request and add UIActivityIndicator
        [self reloadDataSourceForNearByTableView];
    }
}
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
	return NearByCellWidth;
}

- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
	return NearByCellHeight;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
    if(grid==tb_NearBy)
        return NUMBER_COLUMN_HANGOUT;
    else
        return NUMBER_OF_COLUMN;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
	return [tb_NearBy.arrayProfile count];
}

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex AndProfile:(Profile *)_profile
{
	Cell *cell = (Cell *)[grid dequeueReusableCell];
	
	if (cell == nil) {
		cell = [[Cell alloc] init];
        
        UIImage *myImage = [UIImage imageNamed:@"Default Avatar.png"];
        //    cell.thumbnail = [[UIImageView alloc] initWithImage:myImage];
        [cell.thumbnail setImage:myImage];
        
        //    cell.label.text = [NSString stringWithFormat:@"(%d,%d)", rowIndex, columnIndex];

	}

    cell.label.text = _profile.s_Name;
    cell.photoNumber.text = [NSString stringWithFormat:@"%d", _profile.num_Photos ];
    UIImage *status;
    if([_profile.s_ProfileStatus isEqualToString:value_online]){
        [cell.status setHidden:NO];
//        status = [UIImage imageNamed:@"button green.png"];
    }
    else{
        [cell.status setHidden:YES];
//        status = [UIImage imageNamed:@"button gray.png"];
    }
    

    NSString *link = _profile.s_Avatar;
    
    UIImage *image = [_requestsImage objectForKey:_profile.s_Avatar];
    
//    if(!image)
//    {
//        if(![link isEqualToString:@""])
//        {
//            if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
//            {       // check if this is a valid link
//                AFHTTPClient *request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
//                [request getPath:_profile.s_Avatar parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
//                {
//                    UIImage *avatar = [UIImage imageWithData:JSON];
//                    [cell.thumbnail setImage:avatar];
//                    [_requestsImage setObject:avatar forKey:_profile.s_Avatar];
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                {
//                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//                }];
//            }
//            else{
//                AFHTTPClient *request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
//                [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
//                    UIImage *avatar = [UIImage imageWithData:JSON];
//                    [cell.thumbnail setImage:avatar];
//                    [_requestsImage setObject:avatar forKey:_profile.s_Avatar];
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//                }];
//            }
//        }
//    }else {
//        
        if(image != nil && [image isKindOfClass:[UIImage class]] && cell.imageView.image  != image) {
            [cell.thumbnail setImage:image];
        }
//    }
/*
    if(_profile.num_MutualFriends == -1)
    {
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:_profile.s_ID,@"str_profile_id", nil];
        
        AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
        [request getPath:URL_getMutualInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            
            NSError *e=nil;
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
            NSMutableDictionary * data= [dict valueForKey:key_data];
            if(data != nil)
            {
                NSMutableDictionary * friendData= [data valueForKey:_profile.s_ID];
                
                if(friendData != nil)
                {
                    _profile.num_MutualFriends = [[friendData valueForKey:@"mutualFriend"] intValue];
                    
                    [cell setMutualFriends:_profile.num_MutualFriends];
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
        }];
    }
    else
    {
        [cell setMutualFriends:_profile.num_MutualFriends];
    }
*/
    CGRect rect = cell.frame;
//    if(rowIndex*NUMBER_COLUMN_HANGOUT + columnIndex == [tb_NearBy.arrayProfile count]-1){
//        [self reloadDataSourceForNearByTableView];
//    }
	return cell;
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
{

    Profile *p = [tb_NearBy.arrayProfile objectAtIndex:rowIndex*NUMBER_COLUMN_HANGOUT+colIndex];
    UIImage *image = [_requestsImage objectForKey:p.s_Avatar];
    [self gotoProfile:p andImage:image];
//    VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
//    [viewProfile loadProfile:p andImage:image];
//    [self.navigationController pushViewController:viewProfile animated:YES];
	NSLog(@"%d, %d clicked", rowIndex, colIndex);
}




#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // Single tap shows or hides drawer of thumbnails.
//    [self toggleThumbView];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
//    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
//    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
//    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
//    [imageScrollView zoomToRect:zoomRect animated:YES];
}




#pragma mark ThumbImageViewDelegate methods

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
    Profile *p = [_featureProfileList objectAtIndex:tiv.ID];//] objectAtIndex:rowIndex*NUMBER_COLUMN_HANGOUT+colIndex];
//    ThumbImageView *temp = [_featureImageList objectForKey:p.s_Name];
    UIImage *image = [_featureImageList objectForKey:p.s_Avatar];
    [self gotoProfile:p andImage:image];
//    [self pickImageNamed:[tiv imageName]];
//    [self toggleThumbView];
    
}

- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv {
    [thumbScrollView bringSubviewToFront:tiv];
}

- (void)thumbImageViewMoved:(ThumbImageView *)draggingThumb {
    
    // check if we've moved close enough to an edge to autoscroll, or far enough away to stop autoscrolling
    [self maybeAutoscrollForThumb:draggingThumb];
    
    /* The rest of this method handles the reordering of thumbnails in the thumbScrollView. See  */
    /* ThumbImageView.h and ThumbImageView.m for more information about how this works.          */
    
    // we'll reorder only if the thumb is overlapping the scroll view
    if (CGRectIntersectsRect([draggingThumb frame], [thumbScrollView bounds])) {
        
        BOOL draggingRight = [draggingThumb frame].origin.x > [draggingThumb home].origin.x ? YES : NO;
        
        /* we're going to shift over all the thumbs who live between the home of the moving thumb */
        /* and the current touch location. A thumb counts as living in this area if the midpoint  */
        /* of its home is contained in the area.                                                  */
        NSMutableArray *thumbsToShift = [[NSMutableArray alloc] init];
        
        // get the touch location in the coordinate system of the scroll view
        CGPoint touchLocation = [draggingThumb convertPoint:[draggingThumb touchLocation] toView:thumbScrollView];
        
        // calculate minimum and maximum boundaries of the affected area
        float minX = draggingRight ? CGRectGetMaxX([draggingThumb home]) : touchLocation.x;
        float maxX = draggingRight ? touchLocation.x : CGRectGetMinX([draggingThumb home]);
        
        // iterate through thumbnails and see which ones need to move over
        for (ThumbImageView *thumb in [thumbScrollView subviews]) {
            
            // skip the thumb being dragged
            if (thumb == draggingThumb) continue;
            
            // skip non-thumb subviews of the scroll view (such as the scroll indicators)
            if (! [thumb isMemberOfClass:[ThumbImageView class]]) continue;
            
            float thumbMidpoint = CGRectGetMidX([thumb home]);
            if (thumbMidpoint >= minX && thumbMidpoint <= maxX) {
                [thumbsToShift addObject:thumb];
            }
        }
        
        // shift over the other thumbs to make room for the dragging thumb. (if we're dragging right, they shift to the left)
        float otherThumbShift = ([draggingThumb home].size.width + THUMB_H_PADDING) * (draggingRight ? -1 : 1);
        
        // as we shift over the other thumbs, we'll calculate how much the dragging thumb's home is going to move
        float draggingThumbShift = 0.0;
        
        // send each of the shifting thumbs to its new home
        for (ThumbImageView *otherThumb in thumbsToShift) {
            CGRect home = [otherThumb home];
            home.origin.x += otherThumbShift;
            [otherThumb setHome:home];
            [otherThumb goHome];
            draggingThumbShift += ([otherThumb frame].size.width + THUMB_H_PADDING) * (draggingRight ? 1 : -1);
        }
        
        
        // change the home of the dragging thumb, but don't send it there because it's still being dragged
        CGRect home = [draggingThumb home];
        home.origin.x += draggingThumbShift;
        [draggingThumb setHome:home];
    }
}

- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv {
    // if the user lets go of the thumb image view, stop autoscrolling
    [autoscrollTimer invalidate];
    autoscrollTimer = nil;
}

- (void)pickImageNamed:(NSString *)name{
    
}


- (void) gotoProfile:(Profile *)profile andImage:(UIImage *)img{
//    Profile *p = [tb_NearBy.arrayProfile objectAtIndex:rowIndex*NUMBER_COLUMN_HANGOUT+colIndex];
//    UIImage *image = [_requestsImage objectForKey:p.s_Avatar];
    VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
    [viewProfile loadProfile:profile andImage:img];
    [self.navigationController pushViewController:viewProfile animated:YES];
}

#pragma mark Autoscrolling methods

- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb {
    
    autoscrollDistance = 0;
    
    // only autoscroll if the thumb is overlapping the thumbScrollView
    if (CGRectIntersectsRect([thumb frame], [thumbScrollView bounds])) {
        
        CGPoint touchLocation = [thumb convertPoint:[thumb touchLocation] toView:thumbScrollView];
        float distanceFromLeftEdge  = touchLocation.x - CGRectGetMinX([thumbScrollView bounds]);
        float distanceFromRightEdge = CGRectGetMaxX([thumbScrollView bounds]) - touchLocation.x;
        
        if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1; // if scrolling left, distance is negative
        } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
        }
    }
    
    // if no autoscrolling, stop and clear timer
    if (autoscrollDistance == 0) {
        [autoscrollTimer invalidate];
        autoscrollTimer = nil;
    }
    
    // otherwise create and start timer (if we don't already have a timer going)
    else if (autoscrollTimer == nil) {
        autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0)
                                                           target:self
                                                         selector:@selector(autoscrollTimerFired:)
                                                         userInfo:thumb
                                                          repeats:YES];
    }
}

- (float)autoscrollDistanceForProximityToEdge:(float)proximity {
    // the scroll distance grows as the proximity to the edge decreases, so that moving the thumb
    // further over results in faster scrolling.
    return ceilf((AUTOSCROLL_THRESHOLD - proximity) / 5.0);
}

- (void)legalizeAutoscrollDistance {
    // makes sure the autoscroll distance won't result in scrolling past the content of the scroll view
    float minimumLegalDistance = [thumbScrollView contentOffset].x * -1;
    float maximumLegalDistance = [thumbScrollView contentSize].width - ([thumbScrollView frame].size.width + [thumbScrollView contentOffset].x);
    autoscrollDistance = MAX(autoscrollDistance, minimumLegalDistance);
    autoscrollDistance = MIN(autoscrollDistance, maximumLegalDistance);
}

- (void)autoscrollTimerFired:(NSTimer*)timer {
    [self legalizeAutoscrollDistance];
    
    // autoscroll by changing content offset
    CGPoint contentOffset = [thumbScrollView contentOffset];
    contentOffset.x += autoscrollDistance;
    [thumbScrollView setContentOffset:contentOffset];
    
    // adjust thumb position so it appears to stay still
    ThumbImageView *thumb = (ThumbImageView *)[timer userInfo];
    [thumb moveByOffset:CGPointMake(autoscrollDistance, 0)];
}




#pragma mark View handling methods

- (void)toggleThumbView {
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [slideUpView frame];
    //    if (thumbViewShowing) {
    //        frame.origin.y += frame.size.height;
    //    } else {
    frame.origin.y = 0;
    //    }
    
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.3];
    [slideUpView setFrame:frame];
    //    [UIView commitAnimations];
    
//    thumbViewShowing = !thumbViewShowing;
}

- (void)loadFeatureProfileList {
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getListFeature parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        Profile *parser = [[Profile alloc]init];
        _featureProfileList =[parser parseForGetFeatureList:JSON];
//        imageNames = [profileList copy];
        [self toggleThumbView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
//    return _featureProfileList;
}

- (void)createSlideUpViewIfNecessary {
    
    if (!slideUpView) {
        [self createThumbScrollViewIfNecessary];
                
        CGRect bounds = [[self view] bounds];
        float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    
        // create container view that will hold scroll view and label
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, thumbHeight);
        slideUpView = [[UIView alloc] initWithFrame:frame];
        [slideUpView setBackgroundColor:[UIColor clearColor]];
        [[self view] addSubview:slideUpView];
        
        // add subviews to container view
        [slideUpView addSubview:thumbScrollView];
        
        [self.view bringSubviewToFront:self.btn_addMeHere];
        [self.view bringSubviewToFront:self.leftBG];
    }
}
- (void)createThumbScrollViewIfNecessary {
    
    if (!thumbScrollView) {
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width - START_X;
        thumbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(START_X, 0, scrollViewWidth, scrollViewHeight)];
        [thumbScrollView setCanCancelContentTouches:NO];
        [thumbScrollView setClipsToBounds:NO];
        [thumbScrollView setShowsHorizontalScrollIndicator:NO];
        
        // now place all the thumb views as subviews of the scroll view
        // and in the course of doing so calculate the content width
        __block float xPosition = THUMB_H_PADDING;
        AFHTTPClient *request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
        for (int i =0; i<  [_featureProfileList count]; i++) {
            Profile *_profile =[_featureProfileList objectAtIndex:i];
            [request getPath:_profile.s_Avatar parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                UIImage *thumbImage = [UIImage imageWithData:JSON];
                if (thumbImage) {
                    
                    ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage];
                    [thumbView setDelegate:self];
                    [thumbView setImageName:_profile.s_Avatar];
                    [thumbView setID:i];
                    thumbView.layer.cornerRadius = 1.0;
                    thumbView.layer.masksToBounds = YES;
                    thumbView.layer.borderColor = [UIColor whiteColor].CGColor;
                    thumbView.layer.borderWidth = 1.0;
                    CGRect frame = [thumbView frame];
                    frame.origin.y = THUMB_V_PADDING;
                    frame.origin.x = xPosition;
                    frame.size.height = THUMB_HEIGHT - THUMB_V_PADDING;
                    frame.size.width = THUMB_HEIGHT- THUMB_V_PADDING;
                    [thumbView setFrame:frame];
                    [thumbView setHome:frame];
                    [thumbScrollView addSubview:thumbView];
                    [_featureImageList setObject:thumbImage forKey:_profile.s_Avatar];
                    xPosition += (frame.size.width + THUMB_H_PADDING);
                }
                
                [thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
                thumbScrollView.backgroundColor = [UIColor clearColor];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
            }];
        }
    }
}

- (IBAction)closeAddMeHerePopover:(id)sender {
    [self.addmehereView.view  removeFromSuperview];
}

#pragma mark MyPhotoListGridView
- (NSInteger) numberOfSections {
    return 1;
}

- (CGFloat) heightForHeaderAtSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat) gridView:(UIGridViewMultipleSection *)grid widthForColumnAtIndexPath:(NSIndexPath *)columnIndex
{
	return 70;
}

- (CGFloat) gridView:(UIGridViewMultipleSection *)grid heightForRowAtIndexPath:(NSIndexPath *)rowIndex
{
	return 70;
}

- (NSString *) gridView:(UIGridViewMultipleSection *)grid titleForHeaderInSection:(NSInteger)section {
    return nil;
}
- (NSInteger) numberOfCellsOfGridView:(UIGridViewMultipleSection *)grid atSection:(NSInteger)section
{
    return [appDelegate.myProfile.arr_photos count];
}

- (UIGridViewCellMultipleSection *) gridView:(UIGridViewMultipleSection *)grid
cellForRowAt:(int)rowIndex
AndColumnAt:(int)columnIndex
inSection:(NSInteger)section
{
    
	ViewCellMyLink *cell = (ViewCellMyLink *)[grid dequeueReusableCell];
	
	if (cell == nil) {
		cell = [[ViewCellMyLink alloc] init];
	}
    int index = rowIndex * NUMBER_OF_COLUMN + columnIndex;
    if(index == 0){
        [cell.checkedView setHidden:NO];
        oldAvatarCell = cell;
        indexAvatarSelected = 0;
    }
    else{
        [cell.checkedView setHidden:YES];
    }
    
    
    NSString* link = [appDelegate.myProfile.arr_photos objectAtIndex:index];
    
    if( ![link isEqualToString:@""] )
    {
        AFHTTPRequestOperation *operation = [Profile getAvatarSync:link
        callback:^(UIImage *image)
         {
             [cell.imageView setImage:image];
             [_requestsImage setObject:image forKey:link];
         }];
        [operation start];
    }
    
    
    
	return  cell;
}

- (void) gridView:(UIGridViewMultipleSection *)grid
didSelectRowAt:(int)rowIndex
AndColumnAt:(int)colIndex
atSectionIndex:(int)section
selectedCell:(UIGridViewCellMultipleSection *)cell
{
    ViewCellMyLink *cellMyLink = (ViewCellMyLink *) cell;
    [oldAvatarCell.checkedView setHidden:YES];
    [cellMyLink.checkedView setHidden:!cellMyLink.checkedView.isHidden];
    oldAvatarCell = cellMyLink;
    indexAvatarSelected = rowIndex * NUMBER_OF_COLUMN + colIndex;
}
@end
