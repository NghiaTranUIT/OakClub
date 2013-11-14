//
//  VCSnapshoot.m
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSnapshoot.h"
#import "VCProfile.h"
#import "NavConOakClub.h"
#import "NavBarOakClub.h"
#import "AppDelegate.h"
@interface VCSnapshoot (){
    UIView *headerView;
    UILabel *lblHeaderName;
    UILabel *lblHeaderFreeNum;
    AppDelegate *appDel;
}
//-(void)loadDataForPhotos;

@end

@implementation VCSnapshoot
@synthesize sv_photos,lbl_indexPhoto, lbl_mutualFriends, lbl_mutualLikes, buttonNO, buttonProfile, buttonYES, imgMutualFriend, imgMutualLike, buttonMAYBE  ;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentProfile = [[Profile alloc]init];
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    //    while ([self loadCurrentProfile:currentIndex] != YES) {
    //        [self loadCurrentProfile:currentIndex];
    //    }
    //    NavConOakClub *tempBarController= (NavConOakClub*)self.navigationController;
    //    NavBarOakClub *tempBar = (NavBarOakClub*) tempBarController.navigationBar;
    //    SEL sel =@selector(gotoSetting);
    //    [tempBar.btnRight performSelector:sel];
    //    UIBarButtonItem *_btn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting-Snapshoot.png"]
    //                                                          style:UIBarButtonItemStylePlain
    //                                                         target:self
    //                                                         action:@selector(gotoSetting)];
    //
    //    self.navigationItem.rightBarButtonItem=_btn;
    //    [self.view bringSubviewToFront:self.navigationItem.rightBarButtonItem];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    
    
}

-(void)disableAllControl:(BOOL)value{
    [buttonYES setEnabled:!value];
    [buttonProfile setEnabled:!value];
    [buttonNO setEnabled:!value];
    [buttonMAYBE setEnabled:!value];
}
- (void)showWarning{
    if ([self isViewLoaded] && self.view.window) {
        [self.spinner stopAnimating];
        [self  disableAllControl:YES];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"Beside 10 free daily snapshots, you can use \"coins\" to see more snapshots recommended by Oakclub. Invite your friends to join us to get 5 points per friend."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)showNotifications
{
    int totalNotifications = [appDel countTotalNotifications];
    
    [[self navBarOakClub] setNotifications:totalNotifications];
}

-(BOOL)loadCurrentProfile:(int)index{
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    [self disableAllControl:YES];
    if(currentIndex > MAX_FREE_SNAPSHOT)
    {
        
        [self showWarning];
        return NO;
    }
    self.sv_photos.contentSize =
    CGSizeMake(0, CGRectGetHeight(self.sv_photos.frame));
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSLog(@"index of Profile : %i",index);
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",index],@"index", nil];
    [request getPath:URL_getSnapShot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        currentProfile = [[Profile alloc]init];
        [currentProfile parseGetSnapshotToProfile:JSON];
        NSLog(@"Name of Profile : %@",currentProfile.s_Name);
        // titleView
        UIView *infoHeader= [[UIView alloc]initWithFrame:CGRectMake(0, -8, 240, 44)];
        infoHeader.backgroundColor = [UIColor clearColor];
        
        if(currentProfile.s_interestedStatus == nil) {     // Vanancy --- check if answer or not
            [self.spinner stopAnimating];
            [self disableAllControl:NO];
            // NAME text
            UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 44)];
            titleName.backgroundColor = [UIColor clearColor];
            titleName.textColor = [UIColor whiteColor];
            titleName.font = FONT_NOKIA(22.0);
            titleName.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleName.textAlignment = UITextAlignmentCenter;
            titleName.text = currentProfile.s_Name;
            //            titleName.adjustsFontSizeToFitWidth = YES;
            [infoHeader addSubview:titleName];
            // AGE text
            UILabel *titleAge = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width/3*2 - 20 , 0, infoHeader.frame.size.width/6, 44)];
            titleAge.backgroundColor = [UIColor clearColor];
            titleAge.textColor = [UIColor whiteColor];
            titleAge.font = FONT_NOKIA(22.0);
            titleAge.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleAge.textAlignment = UITextAlignmentLeft;
            titleAge.text = [NSString stringWithFormat:@",%@",currentProfile.s_age] ;
            [infoHeader addSubview:titleAge];
            // INDEX countdown of Profile Free
            UILabel *titleCount = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width - infoHeader.frame.size.width/6, 4, infoHeader.frame.size.width/6 + 5, 22)];
            titleCount.backgroundColor = [UIColor clearColor];
            titleCount.textColor = [UIColor whiteColor];
            titleCount.font = [UIFont boldSystemFontOfSize:16.0];
            titleCount.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleCount.textAlignment = UITextAlignmentCenter;
            titleCount.text = [NSString stringWithFormat:@"%i/10",currentIndex] ;
            [infoHeader addSubview:titleCount];
            
            //FREE text
            UILabel *titleFREE = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width - infoHeader.frame.size.width/6, 20, infoHeader.frame.size.width/6, 16)];
            titleFREE.backgroundColor = [UIColor clearColor];
            titleFREE.textColor = [UIColor whiteColor];
            titleFREE.font = [UIFont boldSystemFontOfSize:10.0];
            titleFREE.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleFREE.textAlignment = UITextAlignmentCenter;
            titleFREE.text = @"FREE";
            [infoHeader addSubview:titleFREE];
            
            //NEXT-PREVIOUS button
            //        UIButton *left= [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 10, 12)];
            //        [left addTarget:self action:@selector(backToPreviousProfile) forControlEvents:UIControlEventTouchUpInside];
            //        [left setImage:[UIImage imageNamed:@"header_btn_pre_user"] forState:UIControlStateNormal];
            //        [left setImage:[UIImage imageNamed:@"header_btn_pre_user_pressed"] forState:UIControlStateHighlighted];
            //        //            [infoHeader addSubview:left];
            //        UIButton *right= [[UIButton alloc] initWithFrame:CGRectMake(-20, 0, 10, 12)];
            //        [right addTarget:self action:@selector(goToNextProfile) forControlEvents:UIControlEventTouchUpInside];
            //        [right setImage:[UIImage imageNamed:@"header_btn_next_user"] forState:UIControlStateNormal];
            //        [right setImage:[UIImage imageNamed:@"header_btn_next_user_pressed"] forState:UIControlStateHighlighted];
            //        //            [infoHeader addSubview:right];
            //
            //        UIBarButtonItem *previousButton = [[UIBarButtonItem alloc]initWithCustomView:left];
            //        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:right];
            //        self.navigationItem.leftBarButtonItem = previousButton;
            //        self.navigationItem.rightBarButtonItem = nextButton;
            
            [[self navBarOakClub] addToHeader:infoHeader];
            lbl_indexPhoto.text = [[NSString alloc]initWithFormat:@"%i/%i",1,[currentProfile.arr_photos count] ];
            lbl_mutualFriends.text = [[NSString alloc]initWithFormat:@"%i",currentProfile.num_MutualFriends];
            lbl_mutualLikes.text = [[NSString alloc]initWithFormat:@"%i",currentProfile.num_Liked];
//            AFHTTPClient *requestMutual = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
//            [requestMutual getPath:URL_getProfileInfo parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
//             {
//                 NSError *e=nil;
//                 NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//                 NSMutableDictionary * data= [dict valueForKey:key_data];
//                 NSMutableDictionary *infoMutual =[data valueForKey:currentProfile.s_ID];
//                 int mutualFriendCount =[[infoMutual valueForKey:key_MutualFriends]  integerValue];
//                 if(mutualFriendCount >0){
//                     lbl_mutualFriends.text = [NSString stringWithFormat:@"%i",mutualFriendCount];
//                     [lbl_mutualFriends setHidden:NO];
//                     [imgMutualFriend setHidden:NO];
//                 }
//                 int mutualLikeCount = [[infoMutual valueForKey:key_MutualLikes]  integerValue];
//                 if(mutualLikeCount > 0){
//                     lbl_mutualLikes.text = [NSString stringWithFormat:@"%i",mutualLikeCount];
//                     [lbl_mutualLikes setHidden:NO];
//                     [imgMutualLike setHidden:NO];
//                 }
//                 
//             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//             {
//                 NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//             }];
            [self loadDataForPhotos];
            // Vanancy --- check if answer or not
        }
        else{
            currentIndex++;
            if(currentIndex <= MAX_FREE_SNAPSHOT){
                [self loadCurrentProfile:currentIndex];
            }
            else
            {
                [self showWarning];
            }
            
        }
        // Vanancy --- check if answer or not --END
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

-(void)loadDataForPhotos{
    NSUInteger numberPages = [currentProfile.arr_photos count];
    
    // a page is the width of the scroll view
    self.sv_photos.scrollsToTop = NO;
    self.sv_photos.delegate = self;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}
-(void)loadScrollViewWithPage:(NSUInteger)pagenum{
    if (pagenum >= [currentProfile.arr_photos count] || ![[currentProfile.arr_photos objectAtIndex:pagenum] isKindOfClass:[NSString class]])
        return;
//    for (UIView *subview in self.sv_photos.subviews) {
//        if([subview isKindOfClass:[UIImageView class]])
//            [subview removeFromSuperview];
//    }
    self.sv_photos.contentSize =
    CGSizeMake(CGRectGetWidth(self.sv_photos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.sv_photos.frame));
    
    //UIImage * image = [UIImage imageNamed:[currentProfile.arr_photos objectAtIndex:pagenum]];
    NSString *link = [currentProfile.arr_photos objectAtIndex:pagenum];
    //    NSLog(@"name : %@ --------- link image = %@ ",profile.s_Name, link);
    if(![currentProfile.arr_photos isKindOfClass:[UIImageView class]]) {
        if(![link isEqualToString:@""]){
            if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
            {       // check if this is a valid link
                request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
                [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                    UIImage *image = [UIImage imageWithData:JSON];
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                    CGRect frame = self.sv_photos.frame;
                    frame.origin.x = CGRectGetWidth(frame) * pagenum;
                    frame.origin.y = 0;
                    imageView.frame = frame;
                    [imageView setContentMode:UIViewContentModeScaleAspectFit];
                    //                    imageView.backgroundColor = [UIColor blackColor];
                    [self.sv_photos addSubview:imageView];
                    
                    [currentProfile.arr_photos replaceObjectAtIndex:pagenum withObject:imageView];
                    //                    [imgManager setObject:image forKey:link];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                }];
            }
            else{
                request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
                [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                    UIImage *image = [UIImage imageWithData:JSON];
                    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                    CGRect frame = self.sv_photos.frame;
                    frame.origin.x = CGRectGetWidth(frame) * pagenum;
                    frame.origin.y = 0;
                    imageView.frame = frame;
                    [imageView setContentMode:UIViewContentModeScaleAspectFit];
                    //                    imageView.backgroundColor = [UIColor blackColor];
                    [self.sv_photos addSubview:imageView];
                    
                    [currentProfile.arr_photos replaceObjectAtIndex:pagenum withObject:imageView];
                    //                    [imgManager setObject:image forKey:link];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                }];
            }
        }
        
    }else {
        UIImageView *imgView = [currentProfile.arr_photos objectAtIndex:pagenum];
        if(imgView != nil && [imgView isKindOfClass:[UIImageView class]]) {
            [self.sv_photos addSubview:imgView];
            
        }
    }
    
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.sv_photos.frame);
    NSUInteger page = floor((self.sv_photos.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //    self.pageControl.currentPage = page;
    lbl_indexPhoto.text = [[NSString alloc]initWithFormat:@"%i/%i",page +1,[currentProfile.arr_photos count] ];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}
- (void)viewDidUnload {
    [self setSv_photos:nil];
    [self setLbl_indexPhoto:nil];
    [self setLbl_mutualFriends:nil];
    [self setLbl_mutualLikes:nil];
    [self setSpinner:nil];
    [self setButtonYES:nil];
    [self setButtonNO:nil];
    [self setButtonProfile:nil];
    [self setImgMutualFriend:nil];
    [self setImgMutualLike:nil];
    [self setButtonMAYBE:nil];
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated{
    currentIndex =1;
    [self loadCurrentProfile:currentIndex];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showNotifications];
}

#pragma mark Button Event Handle

- (IBAction)btnYES:(id)sender {
    [self doAnswer:interestedStatusYES];
}

- (IBAction)btnShowProfile:(id)sender {
    [self gotoPROFILE];
}

- (IBAction)btnNOPE:(id)sender {
    [self doAnswer:interestedStatusNO];
}

- (IBAction)btnMAYBE:(id)sender {
    [self doAnswer:interestedStatusMAYBE];
}

-(void) gotoPROFILE{
    //    Profile *p = cellMyLink.profile;
    NSLog(@"current id = %@",currentProfile.s_ID);
    VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
    UIImageView *avatar = [currentProfile.arr_photos objectAtIndex:0];
    [viewProfile loadProfile:currentProfile andImage:avatar.image];
    viewProfile.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController pushViewController:viewProfile animated:NO];
}
-(void) doAnswer:(int) choose{
    [self setFavorite:[NSString stringWithFormat:@"%i",choose]];
    if(currentIndex < MAX_FREE_SNAPSHOT){
        //increase currentIndex
        currentIndex ++;
        //go next Profile/reload view with next Profile by next index.
        [self loadCurrentProfile:currentIndex];
    }else{
        //show warning getting COINS to continue.
        [self showWarning];
        
    }
}


-(void)setFavorite:(NSString*)answerChoice{
    request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSLog(@"current id = %@",currentProfile.s_snapshotID);
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_snapshotID,@"snapshot_id",answerChoice,@"set", nil];
    [request getPath:URL_setFavorite parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"post success !!!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

- (void) gotoSetting{
    VCSnapshotSetting *viewProfile = [[VCSnapshotSetting alloc] initWithNibName:@"VCSnapshotSetting" bundle:nil];
    //    UIImageView *avatar = [currentProfile.arr_photos objectAtIndex:0];
    //    [viewProfile loadProfile:currentProfile andImage:avatar.image];
    [self.navigationController pushViewController:viewProfile animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *alertIndex = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([alertIndex isEqualToString:@"OK"])
    {
        //Do something
        //        [appDel showHangOut];
    }
}
-(void)backToPreviousProfile{
    if(currentIndex > 1){
        //increase currentIndex
        currentIndex --;
        //go next Profile/reload view with next Profile by next index.
        [self loadCurrentProfile:currentIndex];
    }else{
        
        
    }
}

-(void)goToNextProfile{
    if(currentIndex < MAX_FREE_SNAPSHOT){
        //increase currentIndex
        currentIndex ++;
        //go next Profile/reload view with next Profile by next index.
        [self loadCurrentProfile:currentIndex];
    }else{
        //show warning getting COINS to continue.
        [self showWarning];
        
    }
}
@end
