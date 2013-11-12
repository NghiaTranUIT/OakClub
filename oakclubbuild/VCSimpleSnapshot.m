//
//  VCSimpleSnapshot.m
//  OakClub
//
//  Created by VanLuu on 9/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshot.h"
#import "APLMoveMeView.h"
#import "AppDelegate.h"
#import "AFHTTPClient+OakClub.h"
#import "AnimatedGif.h"
#import "UIView+Localize.h"
#import "NSString+Utils.h"
#import "VCSimpleSnapshotLoading.h"
#import "VCSimpleSnapshotPopup.h"
#import "LocationUpdate.h"
#import "AppLifeCycleDelegate.h"

@interface VCSimpleSnapshot () <LocationUpdateDelegate, AppLifeCycleDelegate> {
    UIView *headerView;
    UILabel *lblHeaderName;
    UILabel *lblHeaderFreeNum;
    AppDelegate *appDel;
    NSMutableDictionary* photos;
    BOOL is_loadingProfileList;
    VCSimpleSnapshotLoading* loadingView;
    UIImageView* loadingAnim;
    BOOL reloadProfileList;
    LocationUpdate *locUpdate;
    
    BOOL isBlockedByGPS;
    BOOL isLoading;
}
@property (nonatomic, strong) IBOutlet APLMoveMeView *moveMeView;
@property (nonatomic, weak) IBOutlet UIView *profileView;
@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (nonatomic, weak) IBOutlet UIViewController *matchView;
@property (strong, nonatomic) IBOutlet VCSimpleSnapshotPopup *popupFirstTimeView;
@property (nonatomic, strong) VCProfile *viewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSArray *pageImages;
@end

@implementation VCSimpleSnapshot
CGFloat pageWidth;
CGFloat pageHeight;
@synthesize sv_photos,lbl_indexPhoto, lbl_mutualFriends, lbl_mutualLikes, buttonNO, buttonProfile, buttonYES, imgMutualFriend, imgMutualLike, buttonMAYBE ,lblName, lblAge ,lblPhotoCount, viewProfile,matchView, matchViewController, lblMatchAlert, imgMatcher, imgMyAvatar, imgMainProfile, imgNextProfile, imgLoading, popupFirstTimeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    NSString* keyLanguage =[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage];
//    NSString* path= [[NSBundle mainBundle] pathForResource:@"vi" ofType:@"lproj"];
//    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    if(IS_HEIGHT_GTE_568){
        self = [super initWithNibName:[NSString stringWithFormat:@"%@-568h",nibNameOrNil] bundle:nibBundleOrNil];
    }
    else{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
    if (self) {
        // Custom initialization
        currentProfile = [[Profile alloc]init];
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
        is_loadingProfileList = FALSE;
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snapshot_gps_loading.gif" ofType:nil]];
        loadingAnim = 	[AnimatedGif getAnimationForGifAtUrl: fileURL];
//        [loadingAnim setHidden:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // load profile List
    is_loadingProfileList = FALSE;
    [self refreshSnapshot];
    
    isBlockedByGPS = NO;
    locUpdate = [[LocationUpdate alloc] init];
    locUpdate.delegate = self;
    [appDel.appLCObservers addObject:self];
    [locUpdate update];
    
    [self loadHeaderLogo];
    [self formatAvatarToCircleView];
    [self.view addSubview:self.moveMeView];
    self.moveMeView.frame = CGRectMake(0, 0, 320, 548);
    // Do any additional setup after loading the view from its nib.
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    /*
    // Load the display strings.
    NSURL *stringsFileURL = [[NSBundle mainBundle] URLForResource:@"DisplayStrings" withExtension:@"txt"];
    NSError *error;
    NSString *string = [NSString stringWithContentsOfURL:stringsFileURL encoding:NSUTF16BigEndianStringEncoding error:&error];
    
    if (string == nil) {
        NSLog(@"Did not load strings file: %@", [error localizedDescription]);
    }
    else {
        NSArray *displayStrings = [string componentsSeparatedByString:@"\n"];
        self.moveMeView.displayStrings = displayStrings;
        [self.moveMeView setupNextDisplayString];
    }
     */
}


-(void) formatAvatarToCircleView{
    //matcher image view
    imgMatcher.layer.masksToBounds = YES;
    imgMatcher.layer.cornerRadius = imgMatcher.frame.size.width/2;
    imgMatcher.layer.borderWidth = 3.0;
    imgMatcher.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //my avatar view
    imgMyAvatar.layer.masksToBounds = YES;
    imgMyAvatar.layer.cornerRadius = imgMyAvatar.frame.size.width/2;
    imgMyAvatar.layer.borderWidth = 3.0;
    imgMyAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
}
-(void)loadHeaderLogo{
    UIImage* logo = [UIImage imageNamed:@"Snapshot_logo.png"];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(98, 10, 125, 26)];
    [logoView setImage:logo];
    [self.navigationController.navigationBar  addSubview:logoView];
//    [[self navBarOakClub] addToHeader:logoView];
}
-(void) refreshSnapshot{
    currentIndex = 0;
    profileList = [[NSMutableArray alloc] init];
    [self loadProfileList:^(void){
        [self.imgMyAvatar setImage:appDel.myProfile.img_Avatar];
        [self loadCurrentProfile];
        [self loadNextProfileByCurrentIndex];
    }];
}
-(void)disableAllControl:(BOOL)value{
    [buttonYES setEnabled:!value];
    [buttonProfile setEnabled:!value];
    [buttonNO setEnabled:!value];
    [buttonMAYBE setEnabled:!value];
}
- (void)showWarning{
//    if ([self isViewLoaded] && self.view.window) {
    [self stopLoadingAnim];
        loadingView = [[VCSimpleSnapshotLoading alloc]init];
        [loadingView.view setFrame:CGRectMake(0, 0, 320, 480)];
        [loadingView setTypeOfAlert:1 andAnim:nil];
        [self.navigationController pushViewController:loadingView animated:NO];
        /*[self stopLoadingAnim];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"There is no more profile to show ..."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
         */
//    }
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

#if ENABLE_DEMO
-(void)loadLikeMeList{
    appDel.likedMeList = [[NSArray alloc] init];
    
     // get list from server
     AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
     [request getPath:URL_getListWhoLikeMe parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
     NSError *e=nil;
     NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
     appDel.likedMeList= [dict valueForKey:key_data];
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
     NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
    
    //test list
//    appDel.likedMeList = [[NSArray alloc] initWithObjects:@"1lxwk74pgu",@"1lxx1xqqs0",@"1lxwtq9jd0",@"1lxx3nhvut",@"1lxx48tf37",@"1lxx4qtd56", nil];
}
#endif

+(void) setReloadProfileList:(BOOL)flag{
    
}
-(void)loadProfileList:(void(^)(void))handler{
    if(is_loadingProfileList)
        return;
    is_loadingProfileList = TRUE;
    if (!isLoading)
    {
        [self startLoadingAnim];
    }
    
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"35",@"limit", nil];
    [request getPath:URL_getSnapShot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
    {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        
        NSInteger * status= [[dict valueForKey:@"status"] integerValue];
        if (status == 0)
        {
            [self showWarning];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                message:[dict valueForKey:@"msg"]
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//            [alertView show];
            return;
        }
        for( id profileJSON in [dict objectForKey:key_data])
        {
            Profile* profile = [[Profile alloc]init];
            [profile parseGetSnapshotToProfile:profileJSON];
            [profileList addObject:profile];
            // Vanancy: don't load all photos of profile and don't use scrollview for showing
//            profile  = [self loadPhotosByProfile:profile];
//            [self loadDataPhotoScrollView];
//            AFHTTPRequestOperation *operation =
//            [Profile getAvatarSync:profile.s_Avatar
//                          callback:^(UIImage *image)
//             {
//                 [profile.arr_photos replaceObjectAtIndex:0 withObject:image];
//             }];
//            [operation start];
            // Vanancy - update mutual friends/likes count here
            /*if(profile.num_MutualFriends == -1)
            {
                NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:profile.s_ID,@"str_profile_id", nil];
                
                AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
                [request getPath:URL_getMutualInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                    
                    NSError *e=nil;
                    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
                    NSMutableDictionary * data= [dict valueForKey:key_data];
                    if(data != nil)
                    {
                        NSMutableDictionary * friendData= [data valueForKey:profile.s_ID];
                        
                        if(friendData != nil)
                        {
                            profile.num_MutualFriends = [[friendData valueForKey:@"mutualFriend"] intValue];
                            
                        }
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                }];
            }
             */
        }
        if(handler != nil)
            handler();
        is_loadingProfileList = FALSE;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

/*
-(Profile*)loadPhotosByProfile:(Profile*)profile{
    for (int proIndex=0; proIndex < [profile.arr_photos count]; proIndex++) {
        if(![profile.arr_photos isKindOfClass:[UIImageView class]]) {
            NSString *link = [profile.arr_photos objectAtIndex:proIndex];
            if([[profile.arr_photos objectAtIndex:proIndex] isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = [profile.arr_photos objectAtIndex:proIndex];
                CGRect frame = self.sv_photos.frame;
                frame.origin.x = CGRectGetWidth(frame) * proIndex;
                frame.origin.y = 0;
                imageView.frame = frame;
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [profile.arr_photos replaceObjectAtIndex:proIndex withObject:imageView];
                return profile;
            }
            if(![link isEqualToString:@""]){
                if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
                {       // check if this is a valid link
                    request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
                    [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                        UIImage *image = [UIImage imageWithData:JSON];
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                        CGRect frame = self.sv_photos.frame;
                        frame.origin.x = CGRectGetWidth(frame) * proIndex;
                        frame.origin.y = 0;
                        imageView.frame = frame;
                        [imageView setContentMode:UIViewContentModeScaleAspectFit];
                        //                    imageView.backgroundColor = [UIColor blackColor];
//                        [self.sv_photos addSubview:imageView];
                        
                        [profile.arr_photos replaceObjectAtIndex:proIndex withObject:imageView];
                        //                    [imgManager setObject:image forKey:link];
                        [self loadDataPhotoScrollView];
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
                        frame.origin.x = CGRectGetWidth(frame) * proIndex;
                        frame.origin.y = 0;
                        imageView.frame = frame;
                        [imageView setContentMode:UIViewContentModeScaleAspectFit];
                        //                    imageView.backgroundColor = [UIColor blackColor];
//                        [self.sv_photos addSubview:imageView];
                        
                        [profile.arr_photos replaceObjectAtIndex:proIndex withObject:imageView];
                        //                    [imgManager setObject:image forKey:link];
                        [self loadDataPhotoScrollView];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                    }];
                }
            }
        }
    }
    return profile;
    
}

-(void)loadDataPhotoScrollView{
    for (UIImageView * view in self.sv_photos.subviews) {
        //        if (view.tag == 15) {
        [view removeFromSuperview];
        //        }
    }
    self.sv_photos.scrollsToTop = NO;
    self.sv_photos.delegate = self;
    for(int i =0 ; i< [currentProfile.arr_photos count]; i++){
        if([currentProfile.arr_photos[i] isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = currentProfile.arr_photos[i];
            CGRect frame = self.sv_photos.frame;
            frame.origin.x = CGRectGetWidth(frame) * i;
            frame.origin.y = 0;
            imageView.frame = frame;
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [self.sv_photos addSubview:imageView];
        }
        
    }
}
 */

-(void)loadNextProfileByCurrentIndex{
    if(currentIndex >= [profileList count])
    {
        [self showWarning];
        return;
    }
    Profile * temp  =  [[Profile alloc]init];
    temp = [profileList objectAtIndex:currentIndex];
    [self.imgNextProfile setImage:temp.img_Avatar];
//    [self.imgNextProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    NSLog(@"Name of Profile : %@",currentProfile.s_Name);
}
-(void)loadCurrentProfile{
    if(currentIndex >= [profileList count])
    {
        [self showWarning];
        return;
    }
    currentProfile = [[Profile alloc]init];
    currentProfile = [profileList objectAtIndex:currentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:currentProfile.s_ID forKey:@"currentSnapShotID"];
    NSLog(@"Name of Profile : %@",currentProfile.s_Name);
    NSString *txtAge= [NSString stringWithFormat:@"%@",currentProfile.s_age];
    [lblName setText:[self formatTextWithName:currentProfile.s_Name andAge:txtAge]];
    
    [lbl_mutualFriends setText:[NSString stringWithFormat:@"%i",currentProfile.num_MutualFriends]];
//    [lbl_mutualLikes setText:[NSString stringWithFormat:@"%i",currentProfile.num_]];
//    AFHTTPClient *requestMutual = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
//    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id", nil];
    if(currentProfile.arr_photos != nil){
        [lblPhotoCount setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_photos count]]];
        if(([currentProfile.arr_photos count] > 0) && [currentProfile.arr_photos[0] isKindOfClass:[UIImage class]]){
            [self.imgMainProfile setImage:[currentProfile.arr_photos objectAtIndex:0]];
        }
        else{
            AFHTTPRequestOperation *operation =
            [Profile getAvatarSync:currentProfile.s_Avatar
                          callback:^(UIImage *image)
             {
                 [self.imgMainProfile setImage:image];
                 [currentProfile.arr_photos replaceObjectAtIndex:0 withObject:image];
             }];
            [operation start];
        }
    
    }

    [self stopLoadingAnim];
//    [requestMutual getPath:URL_getProfileInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
//     {
//         [self stopLoadingAnim];
//         NSError *e=nil;
//         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//         NSMutableDictionary * data= [dict valueForKey:key_data];
//         NSMutableDictionary *infoMutual =[data valueForKey:currentProfile.s_ID];
//         int mutualFriendCount =[[infoMutual valueForKey:key_MutualFriends]  integerValue];
//         if(mutualFriendCount >0){
//             lbl_mutualFriends.text = [NSString stringWithFormat:@"%i",mutualFriendCount];
//             [lbl_mutualFriends setHidden:NO];
//             [imgMutualFriend setHidden:NO];
//         }
//         int mutualLikeCount = [[infoMutual valueForKey:key_MutualLikes]  integerValue];
//         if(mutualLikeCount > 0){
//             lbl_mutualLikes.text = [NSString stringWithFormat:@"%i",mutualLikeCount];
//             [lbl_mutualLikes setHidden:NO];
//             [imgMutualLike setHidden:NO];
//         }
////         [self loadDataForPhotos];
//   
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//     }];
    currentIndex++;
//    [self loadNextProfileByIndex:currentIndex];
}

/*
-(BOOL)loadCurrentProfile:(int)index{
    [self startLoadingAnim];
    if(currentIndex > MAX_FREE_SNAPSHOT)
    {
        [self showWarning];
        return NO;
    }
//    for (UIView *subview in self.sv_photos.subviews) {
//        if([subview isKindOfClass:[UIImageView class]])
//            [subview removeFromSuperview];
//    }
    self.sv_photos.contentSize =
    CGSizeMake(0, CGRectGetHeight(self.sv_photos.frame));
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSLog(@"index of Profile : %i",index);
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",index],@"index", nil];
    [request getPath:URL_getSnapShot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSInteger * status= [[dict valueForKey:@"status"] integerValue];
        if (status == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[dict valueForKey:@"msg"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        currentProfile = [[Profile alloc]init];
        [currentProfile parseGetSnapshotToProfile:JSON];
        [[NSUserDefaults standardUserDefaults] setObject:currentProfile.s_snapshotID forKey:@"currentSnapShotID"];
        NSLog(@"Name of Profile : %@",currentProfile.s_Name);
        
        // titleView
        UIView *infoHeader= [[UIView alloc]initWithFrame:CGRectMake(0, -8, 240, 44)];
        infoHeader.backgroundColor = [UIColor clearColor];
        
        if(currentProfile.s_interestedStatus != nil) {     // Vanancy --- check if answer or not
            [self stopLoadingAnim];
            // AGE text
            UILabel *titleAge = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width/3*2 - 20 , 0, infoHeader.frame.size.width/6, 44)];
            titleAge.backgroundColor = [UIColor clearColor];
            titleAge.textColor = [UIColor whiteColor];
            titleAge.font = FONT_NOKIA(22.0);
            titleAge.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleAge.textAlignment = UITextAlignmentLeft;
            NSString *txtAge= [NSString stringWithFormat:@"%@",currentProfile.s_age];
            titleAge.text = txtAge ;
            //            [infoHeader addSubview:titleAge];
            // NAME text
            UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 44)];
            titleName.backgroundColor = [UIColor clearColor];
            titleName.textColor = [UIColor whiteColor];
            titleName.font = FONT_NOKIA(22.0);
            titleName.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleName.textAlignment = UITextAlignmentCenter;
            titleName.text = [self formatTextWithName:currentProfile.s_Name andAge:txtAge];
            //            titleName.adjustsFontSizeToFitWidth = YES;
            [infoHeader addSubview:titleName];
           
//            [lblAge setText:txtAge];
            [lblName setText:[self formatTextWithName:currentProfile.s_Name andAge:txtAge]];
            // NAME and AGE on view
            // INDEX countdown of Profile Free
            UILabel *titleCount = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width - infoHeader.frame.size.width/6, 4, infoHeader.frame.size.width/6 + 5, 22)];
            titleCount.backgroundColor = [UIColor clearColor];
            titleCount.textColor = [UIColor whiteColor];
            titleCount.font = [UIFont boldSystemFontOfSize:16.0];
            titleCount.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleCount.textAlignment = UITextAlignmentCenter;
            titleCount.text = [NSString stringWithFormat:@"%i/10",currentIndex] ;
            [infoHeader addSubview:titleCount];
            [lblPhotoCount setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_photos count]]];
            //FREE text
            UILabel *titleFREE = [[UILabel alloc] initWithFrame:CGRectMake(infoHeader.frame.size.width - infoHeader.frame.size.width/6, 20, infoHeader.frame.size.width/6, 16)];
            titleFREE.backgroundColor = [UIColor clearColor];
            titleFREE.textColor = [UIColor whiteColor];
            titleFREE.font = [UIFont boldSystemFontOfSize:10.0];
            titleFREE.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            titleFREE.textAlignment = UITextAlignmentCenter;
            titleFREE.text = @"FREE";
            [infoHeader addSubview:titleFREE];
            
            [[self navBarOakClub] addToHeader:infoHeader];
            lbl_indexPhoto.text = [[NSString alloc]initWithFormat:@"%i/%i",1,[currentProfile.arr_photos count] ];
            
            AFHTTPClient *requestMutual = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
             NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id", nil];
            [requestMutual getPath:URL_getProfileInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
             {
                 NSError *e=nil;
                 NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
                 NSMutableDictionary * data= [dict valueForKey:key_data];
                 NSMutableDictionary *infoMutual =[data valueForKey:currentProfile.s_ID];
                 int mutualFriendCount =[[infoMutual valueForKey:key_MutualFriends]  integerValue];
                 if(mutualFriendCount >0){
                     lbl_mutualFriends.text = [NSString stringWithFormat:@"%i",mutualFriendCount];
                     [lbl_mutualFriends setHidden:NO];
                     [imgMutualFriend setHidden:NO];
                 }
                 int mutualLikeCount = [[infoMutual valueForKey:key_MutualLikes]  integerValue];
                 if(mutualLikeCount > 0){
                     lbl_mutualLikes.text = [NSString stringWithFormat:@"%i",mutualLikeCount];
                     [lbl_mutualLikes setHidden:NO];
                     [imgMutualLike setHidden:NO];
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
             }];
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
*/

/*
-(void)loadDataForPhotos{
//    NSUInteger numberPages = [currentProfile.arr_photos count];
//    
//    // a page is the width of the scroll view
//    for (UIImageView * view in self.sv_photos.subviews) {
////        if (view.tag == 15) {
//            [view removeFromSuperview];
////        }
//    }
//    self.sv_photos.scrollsToTop = NO;
//    self.sv_photos.delegate = self;
//    
//    [self loadScrollViewWithPage:0];
//    [self loadScrollViewWithPage:1];
}

-(void)loadScrollViewWithPage:(NSUInteger)pagenum{
    if (pagenum >= [currentProfile.arr_photos count])
        return;

    self.sv_photos.contentSize =
    CGSizeMake(CGRectGetWidth(self.sv_photos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.sv_photos.frame));
    
    //UIImage * image = [UIImage imageNamed:[currentProfile.arr_photos objectAtIndex:pagenum]];
    
    //    NSLog(@"name : %@ --------- link image = %@ ",profile.s_Name, link);
    if(![currentProfile.arr_photos isKindOfClass:[UIImageView class]]) {
        NSString *link = [currentProfile.arr_photos objectAtIndex:pagenum];
        if([[currentProfile.arr_photos objectAtIndex:pagenum] isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = [currentProfile.arr_photos objectAtIndex:pagenum];
            CGRect frame = self.sv_photos.frame;
            frame.origin.x = CGRectGetWidth(frame) * pagenum;
            frame.origin.y = 0;
            imageView.frame = frame;
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            //                    imageView.backgroundColor = [UIColor blackColor];
            [self.sv_photos addSubview:imageView];
            
            [currentProfile.arr_photos replaceObjectAtIndex:pagenum withObject:imageView];
            return;
        }
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
        
//    }else {
//        UIImageView *imgView = [currentProfile.arr_photos objectAtIndex:pagenum];
//        if(imgView != nil && [imgView isKindOfClass:[UIImageView class]]) {
//            [self.sv_photos addSubview:imgView];
//            
//        }
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging");
}
// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
//    CGFloat pageWidth = CGRectGetWidth(self.sv_photos.frame);
//    NSUInteger page = floor((self.sv_photos.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    //    self.pageControl.currentPage = page;
//    lbl_indexPhoto.text = [[NSString alloc]initWithFormat:@"%i/%i",page +1,[currentProfile.arr_photos count] ];
//    
//    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
//    [self loadScrollViewWithPage:page];
//    [self loadScrollViewWithPage:page + 1];
    
}
 */
- (void) viewWillAppear:(BOOL)animated{
//    [self.view addSubview:loadingAnim];
    [self.moveMeView localizeAllViews];
    [self.controlView localizeAllViews];
//    [[self navBarOakClub] setHeaderName:[NSString localizeString:@"Snapshot"]];
    
    //load data
    [self loadLikeMeList];
    //load profile list if needed
    
//    currentIndex = 0;
//    currentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"snapshotIndex"] integerValue];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"snapshotIndex"] == nil)
//       currentIndex = 1;
//    else
//        currentIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"snapshotIndex"];
//    if(currentIndex < 1)
//        currentIndex = 1;
//    profileList = [[NSMutableArray alloc] init];
//    [self loadProfileList];
//    [self loadCurrentProfile:currentIndex];
    //init photoscrollview
//    CGSize pagesScrollViewSize = self.photoScrollView.frame.size;
//    self.photoScrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
//    
//    pageWidth = self.photoScrollView.frame.size.width;
//    pageHeight = self.photoScrollView.frame.size.height;
//    [self.photoScrollView scrollRectToVisible:CGRectMake(pageWidth,0,pageWidth,pageHeight) animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showNotifications];
}

- (void)viewDidUnload
{
    [self setLblName:nil];
    [self setLblName:nil];
    [self setLblAge:nil];
    [self setLblPhotoCount:nil];
    [super viewDidUnload];
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
    NSLog(@"current id = %@",currentProfile.s_ID);
    viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
    [viewProfile loadProfile:currentProfile andImage:currentProfile.img_Avatar];
    /*
    if([[currentProfile.arr_photos objectAtIndex:0] isKindOfClass:[UIImage class]]){
        [viewProfile loadProfile:currentProfile andImage:[currentProfile.arr_photos objectAtIndex:0]];
    }
    else{
        UIImageView * avatar =[currentProfile.arr_photos objectAtIndex:0];
        [viewProfile loadProfile:currentProfile andImage:avatar.image];
    }*/
    
//    [viewProfile loadProfile:currentProfile];
    [self.view addSubview:viewProfile.view];
    viewProfile.view.frame = CGRectMake(0, 480, 320, 480);
    [viewProfile.svPhotos setHidden:YES];
    [UIView animateWithDuration:0.4
                     animations:^{
                         viewProfile.view.frame = CGRectMake(0, 0, 320, 480);
                     }completion:^(BOOL finished) {
                          [viewProfile.svPhotos setHidden:NO];
                     }];
//    [imgMainProfile removeFromSuperview];
//    UIImageView *avatar =[currentProfile.arr_photos objectAtIndex:0];
//    [imgMainProfile setImage:[currentProfile.arr_photos objectAtIndex:0]];
    [self.view addSubview:imgMainProfile];
    [imgMainProfile setFrame:CGRectMake(50, 30, 228, 228)];
//    [self.sv_photos removeFromSuperview];
//    [self.view addSubview:self.sv_photos];
//    self.sv_photos.frame = CGRectMake(50, 30, 228 , 228);
    [UIView animateWithDuration: 0.4
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.navigationController setNavigationBarHidden:YES animated:YES];
                         imgMainProfile.frame = CGRectMake((320-275)/2, 0, 275, 275);
//                         self.sv_photos.frame = CGRectMake(0, 0, 320, 275);
//                         self.sv_photos.contentSize =
//                         CGSizeMake(CGRectGetWidth(self.sv_photos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.sv_photos.frame));
//                         [self loadDataPhotoScrollView];
                     }
                     completion:^(BOOL finished) {
//                         [self.moveMeView removeFromSuperview];
                         [imgMainProfile setHidden:YES];
//                         [self.sv_photos setUserInteractionEnabled:YES];
//                         [self.sv_photos removeFromSuperview];
//                         [viewProfile.scrollview addSubview:self.sv_photos];
                     }
     ];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.view bringSubviewToFront:self.controlView];
                         if(IS_OS_7_OR_LATER)
                             self.controlView.frame = CGRectMake(0, 20, 320, 46);// its final location
                         else
                             self.controlView.frame = CGRectMake(0, 0, 320, 46);// its final location
                     }];
    
}

-(void)backToSnapshotView{
//    [self.sv_photos setUserInteractionEnabled:NO];
//    [self.sv_photos scrollRectToVisible:CGRectMake(0, 0, 228, 228) animated:NO];
    [imgMainProfile setHidden:NO];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [viewProfile.view removeFromSuperview];
                         viewProfile.view.frame = CGRectMake(0, 480, 320, 480);// its final location
                     }];
    
    [UIView animateWithDuration: 0.4
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
//                         self.sv_photos.frame = CGRectMake(46, 30, 228, 228);
                         [self.imgMainProfile setFrame:CGRectMake(46, 28, 255, 255)];
//                         [self loadDataPhotoScrollView];
                     }
                     completion:^(BOOL finished) {
//                         [self.sv_photos removeFromSuperview];
//                         [self.moveMeView addSubViewToCardView:self.sv_photos];
//                         self.sv_photos.frame = CGRectMake(4, 5, 228 , 228);
                         [self.moveMeView addSubViewToCardView:imgMainProfile];
                         [self.imgMainProfile setFrame:CGRectMake(5, 3, 255, 255)];
                         
                     }
     ];
    [self.view addSubview:self.moveMeView];
    [self.view sendSubviewToBack:self.moveMeView];
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.controlView.frame = CGRectMake(0, -46, 320, 50);// its final location
                     } completion:^(BOOL finished){
                         
                         [self.view bringSubviewToFront:self.moveMeView];
                         self.moveMeView.frame = CGRectMake(0, 0, 320, 548);
                     }];
}

-(void)showMatchView{
    [self.view addSubview:matchViewController.view];
    [matchViewController.view setFrame:CGRectMake(0, 0, matchViewController.view.frame.size.width, matchViewController.view.frame.size.height)];
    [lblMatchAlert setText:[NSString stringWithFormat:@"You and %@ have liked each other!",currentProfile.s_Name]];
    if([currentProfile.arr_photos[0] isKindOfClass:[UIImageView class]]){
        UIImageView * photoView =currentProfile.arr_photos[0];
        [imgMatcher setImage:photoView.image];
    }
    else
    {
        [imgMatcher setImage:imgMainProfile.image];
    }
}
- (IBAction)dismissMatchView:(id)sender {
    [matchViewController.view removeFromSuperview];
    [lblMatchAlert setText:@""];
}
- (IBAction)onClickSendMessageToMatcher:(id)sender {
    UIImage* avatar = currentProfile.arr_photos[0];
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    SMChatViewController *chatController =
    [[SMChatViewController alloc] initWithUser:[NSString stringWithFormat:@"%@@oakclub.com", currentProfile.s_ID]
                                   withProfile:currentProfile
                                    withAvatar:avatar
                                  withMessages:array];
    [self.navigationController pushViewController:chatController animated:NO];
    [matchViewController.view removeFromSuperview];
	[lblMatchAlert setText:@""];
}
-(IBAction)onNOPEClick:(id)sender{
    [self doAnswer:interestedStatusNO];
    [self backToSnapshotView];
}

-(IBAction)onYESClick:(id)sender{
    [self doAnswer:interestedStatusYES];
    [self backToSnapshotView];
}

-(IBAction)onDoneClick:(id)sender{
    [self backToSnapshotView];
}
-(void) doAnswer:(int) choose{
    [self.moveMeView animatePlacardViewByAnswer:choose andDuration:0.4f];
    [self setFavorite:[NSString stringWithFormat:@"%i",choose]];
}


-(void)setFavorite:(NSString*)answerChoice{
    int isFirstTime = [[[NSUserDefaults standardUserDefaults] objectForKey:key_isFirstSnapshot] integerValue];
    if(isFirstTime < 2){
        [self showFirstSnapshotPopup:answerChoice];
        [self.moveMeView setAnswer:-1];
        isFirstTime++;
        [[NSUserDefaults standardUserDefaults] setInteger:isFirstTime forKey:key_isFirstSnapshot];
        return;
    }
    
    if(currentIndex > [profileList count] - 10){
        [self loadProfileList:^(void){
            [self loadCurrentProfile];
            [self loadNextProfileByCurrentIndex];
        }];
    }
    request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSLog(@"current id = %@",currentProfile.s_Name);
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_snapshotID,@"snapshot_id",answerChoice,@"set", nil];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSnapShotID"];
    if ([answerChoice isEqualToString:@"1"]) {
        if([appDel.likedMeList indexOfObject:value]!= NSNotFound){
            [self showMatchView];
        }
    }
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

/*
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
 */

-(NSString*)formatTextWithName:(NSString*)name andAge:(NSString*)age{
    NSString* result;
    if([name length] > 10){
        name = [name stringByReplacingCharactersInRange:NSMakeRange([name length]-3, 3) withString:@"..."];
    }
    result = [NSString stringWithFormat:@"%@ , %@",name,age];
    return result;
}


- (IBAction)onTouchEnd:(id)sender {
    int answer = [self.moveMeView getAnswer];
    NSLog(@"do answer with i = %i",answer);
    if(answer < 0 )
        return;
    [self doAnswer:answer];
    [self.moveMeView setAnswer:-1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark LOADING - animation
-(void)startLoadingAnim{
//    [self.spinner startAnimating];
//    [self disableAllControl:YES];
    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [loadingView setTypeOfAlert:0 andAnim:loadingAnim];
    isLoading = YES;
    [self.navigationController pushViewController:loadingView animated:NO];
}

-(void)startDisabledGPS{
    //    [self.spinner startAnimating];
    //    [self disableAllControl:YES];
    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [loadingView setTypeOfAlert:2 andAnim:nil];
    [self.navigationController pushViewController:loadingView animated:NO];
    isBlockedByGPS = TRUE;
}

-(void)stopDisabledGPS
{
    [self disableAllControl:NO];
    //    [loadingAnim setHidden:YES];
    [self.navigationController popViewControllerAnimated:NO];
    isBlockedByGPS = FALSE;
}

-(void)stopLoadingAnim{
    if (isLoading)
    {
        [self.spinner stopAnimating];
        [self disableAllControl:NO];
        isLoading = NO;
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark First time Popup
-(void)showFirstSnapshotPopup:(NSString*)answerChoice{
    int answer= [answerChoice integerValue];
    if(answer > -1){
        [popupFirstTimeView enableViewbyType:answer andFriendName:currentProfile.s_Name];
        [popupFirstTimeView.view setFrame:CGRectMake(0, 0, popupFirstTimeView.view.frame.size.width, popupFirstTimeView.view.frame.size.height)];
        [self.view addSubview:popupFirstTimeView.view];
    }
}

#pragma mark Location delegate
-(void)location:(LocationUpdate *)location updateFailWithError:(NSError *)e
{
    NSLog(@"Location failed");
//    if (isLoading)
//    {
//        [self stopLoadingAnim];
//    }
//    
//    [self startDisabledGPS];
}

-(void)location:(LocationUpdate *)location updateSuccessWithID:(NSString *)locationID andName:(NSString *)name
{
//    [self refreshSnapshot];
//    appDel.reloadSnapshot = FALSE;
}

#pragma mark App life cycle delegate
-(void)applicationDidBecomeActive:(UIApplication *)application
{
    if (isBlockedByGPS)
    {
        [self stopDisabledGPS];
    }
//    if (!isLoading)
//    {
//        [self startLoadingAnim];
//    }
    
    [locUpdate update];
}

@end
