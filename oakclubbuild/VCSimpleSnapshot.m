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
#import "VCProfile.h"

@interface VCSimpleSnapshot () <AppLifeCycleDelegate,APLMoveMeViewDelegate> {
    UIView *headerView;
    UILabel *lblHeaderName;
    UILabel *lblHeaderFreeNum;
    AppDelegate *appDel;
    NSMutableDictionary* photos;
    BOOL is_loadingProfileList;
    BOOL reloadProfileList;
    LocationUpdate *locUpdate;
    
    BOOL isBlockedByGPS;
    
    Profile* matchedProfile;
    NSOperationQueue *setLikedQueue;
    ImagePool *snapshotImagePool;
}
@property (nonatomic, strong) IBOutlet APLMoveMeView *moveMeView;
@property (nonatomic, weak) IBOutlet UIView *profileView;
@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatarFrame;
@property (nonatomic, weak) IBOutlet UIViewController *matchView;
@property (strong, nonatomic) IBOutlet VCSimpleSnapshotPopup *popupFirstTimeView;
@property (nonatomic, strong) VCProfile *viewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (weak, nonatomic) IBOutlet UIButton *btnX;
@property (weak, nonatomic) IBOutlet UIButton *btnHeart;
@property (weak, nonatomic) IBOutlet UIView *backgroundAvatarView;
@property (nonatomic, strong) NSArray *pageImages;

@end

@implementation VCSimpleSnapshot
CGFloat pageWidth;
CGFloat pageHeight;
@synthesize sv_photos,lbl_indexPhoto, lbl_mutualFriends, lbl_mutualLikes, buttonNO, buttonProfile, buttonYES, imgMutualFriend, imgMutualLike, buttonMAYBE ,lblName, lblAge ,lblPhotoCount, viewProfile,matchView, matchViewController, lblMatchAlert, imgMatcher, imgMyAvatar, imgMainProfile, imgNextProfile, imgLoading, popupFirstTimeView,imgAvatarFrame,isLoading, btnSayHi, btnKeepSwiping;

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
        matchedProfile =[[Profile alloc]init];
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
        is_loadingProfileList = FALSE;
//        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snapshot_gps_loading.gif" ofType:nil]];
//        loadingAnim = 	[AnimatedGif getAnimationForGifAtUrl: fileURL];
        locUpdate = [[LocationUpdate alloc] init];
        snapshotImagePool = [[ImagePool alloc] init];
//        [loadingAnim setHidden:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // load profile List
    is_loadingProfileList = FALSE;
    [self refreshSnapshotFocus:NO];
    
    isBlockedByGPS = NO;
    [appDel.appLCObservers addObject:self];
    
    [self loadHeaderLogo];
    [self formatAvatarToCircleView];
    [self.view addSubview:self.moveMeView];
    self.moveMeView.movemedelegate = self;
    self.moveMeView.frame = CGRectMake(0, 0, 320, 548);
    
    setLikedQueue = [[NSOperationQueue alloc] init];
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
    
    [appDel.imagePool getImageAtURL:appDel.myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        [imgMyAvatar setImage:img];
    }];
}


-(void) formatAvatarToCircleView{
    //matcher image view
    imgMatcher.layer.masksToBounds = YES;
    imgMatcher.layer.cornerRadius = imgMatcher.frame.size.width/2;
    imgMatcher.layer.borderWidth = 1.5;
    imgMatcher.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //my avatar view
    imgMyAvatar.layer.masksToBounds = YES;
    imgMyAvatar.layer.cornerRadius = imgMyAvatar.frame.size.width/2;
    imgMyAvatar.layer.borderWidth = 1.5;
    imgMyAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
}
-(void)loadHeaderLogo{
    UIImage* logo = [UIImage imageNamed:@"Snapshot_logo.png"];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(98, 10, 125, 26)];
    [logoView setImage:logo];
    logoView.tag = 101;
    [self.navigationController.navigationBar  addSubview:logoView];
//    [[self navBarOakClub] addToHeader:logoView];
}
-(void) refreshSnapshotFocus:(BOOL)focus{
    currentIndex = 0; //Vanancy cheat
    profileList = [[NSMutableArray alloc] init];
    [self loadProfileListUseHandler:^(void){
        [self loadCurrentProfile];
        [self loadNextProfileByCurrentIndex];
    } withFocus:focus];
}
-(void)disableAllControl:(BOOL)value{
    [buttonYES setEnabled:!value];
    [buttonProfile setEnabled:!value];
    [buttonNO setEnabled:!value];
    [buttonMAYBE setEnabled:!value];
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
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"1000",@"limit", nil];
    [client getPath:URL_getListWhoLikeMe parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         appDel.likedMeList = [dict valueForKey:key_data];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"URL_getListWhoLikeMe - Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
}
#endif

+(void) setReloadProfileList:(BOOL)flag{
    
}
-(void)loadProfileListUseHandler:(void(^)(void))handler withFocus:(BOOL)focus{
    if(is_loadingProfileList)
        return;
    [self startLoadingAnimFocus:focus and:^void(){
        [setLikedQueue waitUntilAllOperationsAreFinished];
    }];
    currentIndex = 0; //Vanancy cheat
    profileList = [[NSMutableArray alloc] init];
    
    
    
    // copy for retain cycle
    VCSimpleSnapshot *self_alias = self;
    AppDelegate *_appDel = appDel;
    
    [locUpdate updateWithCompletion:^(double longitude, double latitude, NSError *e) {
        if (!e)
        {
            [locUpdate setUserLocationAtLongitude:longitude andLatitude:latitude useCallback:^(NSString *locationID, NSString *locationName, NSError *err)
             {
                 if (!err)
                 {
                     _appDel.myProfile.s_location.longitude = longitude;
                     _appDel.myProfile.s_location.latitude = latitude;
                     _appDel.myProfile.s_location.ID = locationID;
                     _appDel.myProfile.s_location.name = locationName;
                 }
                 
                 [self_alias loadSnapshotProfilesWithHandler:handler andFocus:focus];
            }];
        }
        else
        {
            [self startDisabledGPS:focus];
        }
    }];
}

-(void)loadSnapshotProfilesWithHandler:(void(^)(void))handler andFocus:(BOOL)focus
{
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"35",@"limit",
                            appDel.snapshotSettingsObj.snapshotParams, @"search_preference", nil];
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"GET" path:URL_getSnapShot parameters:params];
    
    NSString *paramsDesc = [[[NSString stringWithFormat:@"%@", params] stringByReplacingOccurrencesOfString:@"=" withString:@":"] stringByReplacingOccurrencesOfString:@";" withString:@","];
    NSLog(@"Get snapshot params: %@", paramsDesc);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    is_loadingProfileList = TRUE;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Get snapshot-DONE");
        is_loadingProfileList = FALSE;
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        
        int status= [[dict valueForKey:@"status"] integerValue];
        NSArray *profiles = [dict valueForKey:key_data];
        if (status == 0 || [profiles count] < 1)
        {
            [self showWarning:focus];
        }
        else
        {
            snapshotImagePool = [[ImagePool alloc] init];
            for(id profileJSON in profiles)
            {
                Profile* profile = [[Profile alloc]init];
#if VIEWPROFILE_FULLDATA
                [profile parseGetSnapshotToProfileFullData:profileJSON];
#else
                [profile parseGetSnapshotToProfile:profileJSON];
#endif
                //cache profile avatar
                [snapshotImagePool getImageAtURL:profile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
                    
                }];
                [profileList addObject:profile];
            }
            if(handler != nil)
                handler();
            
            [self stopLoadingAnim];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get snapshot Error Code: %i - %@",[error code], error);
        is_loadingProfileList = FALSE;
        [self showWarning:focus];
    }];
    [operation start];
}

-(void)loadNextProfileByCurrentIndex{
    [self.imgNextProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    if(currentIndex >= [profileList count])
    {
        return;
    }
    Profile * temp  =  [[Profile alloc]init];
    temp = [profileList objectAtIndex:currentIndex];
    
    [snapshotImagePool getImageAtURL:temp.s_Avatar withSize:PHOTO_SIZE_LARGE
                               asycn:^(UIImage *image, NSError *err, bool isFirstLoad)
     {
         if(image)
             [self.imgNextProfile setImage:image];
     }];
    
    NSLog(@"Name of Next Profile : %@",temp.s_Name);
}
-(void)loadCurrentProfile{
    NSLog(@"Current focus : %@", self.navigationController.viewControllers);
    [self.imgMainProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    if(currentIndex >= [profileList count])
    {
        //[self showWarning];
        return;
    }
    currentProfile = [[Profile alloc]init];
    currentProfile = [profileList objectAtIndex:currentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:currentProfile.s_ID forKey:@"currentSnapShotID"];
    NSLog(@"Name of Profile : %@",currentProfile.s_Name);
    
    NSString *txtAge= [NSString stringWithFormat:@"%@",currentProfile.s_age];
    [lblName setText:[self formatTextWithName:currentProfile.s_Name andAge:txtAge]];
    [lbl_mutualFriends setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_MutualFriends count]]];
    lbl_mutualLikes.text = [[NSString alloc]initWithFormat:@"%i",[currentProfile.arr_MutualInterests count]];
    
    [lblPhotoCount setText:@"0"];
    [lblPhotoCount setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_photos count]]];
    [self.imgMainProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    
    [snapshotImagePool getImageAtURL:currentProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *image, NSError *error, bool isFirstLoad) {
        if(image){
            [self.imgMainProfile setImage:image];
        }
        [self stopLoadingAnim];
    }];
    currentIndex++;
}

- (void) viewWillAppear:(BOOL)animated{
    [self.moveMeView localizeAllViews];
    [self.controlView localizeAllViews];
    [[self navBarOakClub] disableAllControl: NO];
    
    //load data
    [self loadLikeMeList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[self navBarOakClub] setHidden:NO];

//    self.navigationController.navigationBarHidden = NO;
    [self showNotifications];
    
    if(!appDel.reloadSnapshot){
        if([profileList count]==0){
            [self showWarning:YES];
        }
            
    }
    
}

- (void)viewDidUnload
{
    [self setLblName:nil];
    [self setLblAge:nil];
    [self setLblPhotoCount:nil];
    snapshotImagePool = nil;
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
    int isFirstTime = [[[NSUserDefaults standardUserDefaults] objectForKey:key_isFirstSnapshot] integerValue];
    if(isFirstTime < 4){
        [self.btnHeart setHidden:YES];
        [self.btnX setHidden:YES];
    }
    else{
        [self.btnHeart setHidden:NO];
        [self.btnX setHidden:NO];
    }
    NSLog(@"current id = %@",currentProfile.s_ID);
    viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
    
    [snapshotImagePool getImageAtURL:currentProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        [viewProfile loadProfile:currentProfile andImage:img];
        [self.view addSubview:viewProfile.view];
    }];

    if(IS_OS_7_OR_LATER){
        viewProfile.view.frame = CGRectMake(0, [[UIScreen mainScreen]applicationFrame].size.height, 320, [[UIScreen mainScreen]applicationFrame].size.height);
    }
    else{
        viewProfile.view.frame = CGRectMake(0, [[UIScreen mainScreen]applicationFrame].size.height, 320, [[UIScreen mainScreen]applicationFrame].size.height);
    }
    
    [viewProfile.view setUserInteractionEnabled:NO];
    [viewProfile.svPhotos setHidden:YES];
    [UIView animateWithDuration:0.4
                     animations:^{
                         if(IS_OS_7_OR_LATER){
                             viewProfile.view.frame = CGRectMake(0, 20, 320, [[UIScreen mainScreen]applicationFrame].size.height);
                         }
                         else{
                             viewProfile.view.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen]applicationFrame].size.height);
                         }
                     }completion:^(BOOL finished) {
                         [viewProfile.svPhotos setHidden:NO];
                         [viewProfile.view setUserInteractionEnabled:YES];
                     }];
    [self.view addSubview:imgMainProfile];
    [self.moveMeView setUserInteractionEnabled:NO];
    [imgMainProfile setFrame:CGRectMake(50, 30, 228, 228)];
    [UIView animateWithDuration: 0.4
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear)
                     animations:^{
                         [imgAvatarFrame setAlpha:0.0f];
                         [self.navigationController setNavigationBarHidden:YES animated:YES];
                         imgMainProfile.frame = CGRectMake(0, -20, 320, 320);
                     }
                     completion:^(BOOL finished) {
                         [imgMainProfile setHidden:YES];
                         [self.moveMeView setUserInteractionEnabled:YES];
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

-(void)backToSnapshotViewWithAnswer:(int)answer{
    if(viewProfile.svPhotos.frame.size.height >= self.viewProfile.view.frame.size.height){
        [imgMainProfile setFrame:viewProfile.svPhotos.frame];
    }
    [imgMainProfile setHidden:NO];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [viewProfile.view removeFromSuperview];
                         viewProfile.view.frame = CGRectMake(0, [[UIScreen mainScreen]applicationFrame].size.height, 320, [[UIScreen mainScreen]applicationFrame].size.height);// its final location
                     }];
    
    [UIView animateWithDuration: 0.4
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         [self.imgMainProfile setFrame:CGRectMake(32, 24, 255, 255)];
                     }
                     completion:^(BOOL finished) {
                         [self.moveMeView addSubViewToCardView:imgMainProfile andAtFront:NO andTag:0];
                         [imgAvatarFrame setAlpha:1.0f];
                         [self.imgMainProfile setFrame:CGRectMake(5, 3, 255, 255)];
                     }
     ];
    [self.view addSubview:self.moveMeView];
    [self.view sendSubviewToBack:self.moveMeView];
    [UIView animateWithDuration:0.4
                     animations:^{
                         if(IS_OS_7_OR_LATER)
                             self.controlView.frame = CGRectMake(0, -40, 320, 50);// its final location
                         else
                             self.controlView.frame = CGRectMake(0, -46, 320, 50);// its final location
                     } completion:^(BOOL finished){
                         
                         [self.view bringSubviewToFront:self.moveMeView];
                         self.moveMeView.frame = CGRectMake(0, 0, 320, 548);
                         if(answer != -1)
                             [self doAnswer:answer];
                     }];
}

-(void)showMatchView{
    [[self navBarOakClub] disableAllControl: YES];
    appDel.rootVC.recognizesPanningOnFrontView = NO;
    matchedProfile = currentProfile;
    //    btnSayHi.titleLabel.text = [@"Say Hi!" localize];
//    btnKeepSwiping.titleLabel.text = [@"Keep Swiping!" localize];
    [matchViewController.view setFrame:CGRectMake(0, 0, matchViewController.view.frame.size.width, matchViewController.view.frame.size.height)];
    [lblMatchAlert setText:[NSString stringWithFormat:[@"You and %@ have liked each other!" localize],currentProfile.firstName]];
    [snapshotImagePool getImageAtURL:currentProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        [imgMatcher setImage:img];

    }];
    [matchViewController.view localizeAllViews];
    [self.view addSubview:matchViewController.view];
//    [[self view] localizeAllViews];
}

-(void)addNewChatUser:(Profile*)newChat isMatchViewed:(BOOL)viewed{
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    newChat.s_status_time =[dateFormatter stringFromDate:currentDate];
    NSString* s_jid = [NSString stringWithFormat:@"%@%@", newChat.s_ID, DOMAIN_AT];
    XMPPJID* xmpp_jid = [XMPPJID jidWithString:s_jid];
    if (viewed)
    {
        newChat.status = MatchViewed;
    }
    else
    {
        newChat.status = MatchUnViewed;
    }
    newChat.is_match = true;
    [appDel.xmppRoster addUser:xmpp_jid withNickname:newChat.s_Name];
    [appDel.myProfile.dic_Roster setValue:newChat forKey:newChat.s_ID];
    [appDel.friendChatList setObject:newChat forKey:s_jid];
}
- (IBAction)dismissMatchView:(id)sender {
    [self addNewChatUser:matchedProfile isMatchViewed:NO];
    matchedProfile = nil;
    [matchViewController.view removeFromSuperview];
    [lblMatchAlert setText:@""];
    [[self navBarOakClub] disableAllControl: NO];
    appDel.rootVC.recognizesPanningOnFrontView = YES;
    
    ++appDel.myProfile.new_mutual_attractions;
    [self showNotifications];
}
- (IBAction)onClickSendMessageToMatcher:(id)sender {
    [self addNewChatUser:matchedProfile isMatchViewed:YES];
    
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    [snapshotImagePool getImageAtURL:matchedProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        SMChatViewController *chatController =
        [[SMChatViewController alloc] initWithUser:[NSString stringWithFormat:@"%@@oakclub.com", matchedProfile.s_ID]
                                       withProfile:matchedProfile
                                        withAvatar:img
                                      withMessages:array];
        [self.navigationController pushViewController:chatController animated:NO];
        [matchViewController.view removeFromSuperview];
        [lblMatchAlert setText:@""];
        matchedProfile = nil;    }];
    [[self navBarOakClub] disableAllControl: NO];
    appDel.rootVC.recognizesPanningOnFrontView = YES;
}
-(IBAction)onNOPEClick:(id)sender{
//    [self doAnswer:interestedStatusNO];
    [self backToSnapshotViewWithAnswer:interestedStatusNO];
}

-(IBAction)onYESClick:(id)sender{
//    [self doAnswer:interestedStatusYES];
    [self backToSnapshotViewWithAnswer:interestedStatusYES];
}

-(IBAction)onDoneClick:(id)sender{
    [self backToSnapshotViewWithAnswer:-1];
}
-(void) doAnswer:(int) choose{
    [self disableAllControl:YES];
    UIImageView *stamp ;
    switch (choose) {
        case interestedStatusNO:
             stamp= [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Snapshot_no_stamp"]];
            break;
        case interestedStatusYES:
             stamp= [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Snapshot_like_stamp"]];
            break;
    }
   
    [stamp setAlpha:0.5f];
    [stamp setFrame:CGRectMake(66, 46, stamp.frame.size.width, stamp.frame.size.height)];
    stamp.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0);
    
    [self.moveMeView addSubViewToCardView:stamp andAtFront:YES andTag:101];
    [UIView animateWithDuration:0.2
                     animations:^{
                        [stamp setAlpha:1.0f];
                         stamp.transform = CGAffineTransformIdentity;
                     }completion:^(BOOL finished) {
//                         if([self.moveMeView getAnswer] == -1)
//                             [self.moveMeView animatePlacardViewByAnswer:-1 andDuration:0.5f];
//                         else
                             [self.moveMeView animatePlacardViewByAnswer:choose andDuration:0.5f];
                     }];
    [self setLikedSnapshot:[NSString stringWithFormat:@"%i",choose]];
}

-(void)setLikedSnapshot:(NSString*)answerChoice{
    int isFirstTime = [[[NSUserDefaults standardUserDefaults] objectForKey:key_isFirstSnapshot] integerValue];
    if(isFirstTime==0 || (isFirstTime < 4 &&
        ( (isFirstTime == interestedStatusNO && [answerChoice integerValue] == interestedStatusYES)
           || (isFirstTime == interestedStatusYES && [answerChoice integerValue]== interestedStatusNO)
        )
       ))
    {
        [[self navBarOakClub] disableAllControl: YES];
        appDel.rootVC.recognizesPanningOnFrontView = NO;
        [self showFirstSnapshotPopup:answerChoice];
        [self.moveMeView setAnswer:-1];
        isFirstTime+=[answerChoice integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:isFirstTime forKey:key_isFirstSnapshot];
        return;
    }
    [self.moveMeView setAnswer:[answerChoice integerValue]];
    request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    NSLog(@"current id = %@",currentProfile.s_Name);
    NSDictionary *params;
    if([answerChoice integerValue] == interestedStatusYES)
        params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,key_profileID,@"1",@"is_like", nil];
    else
        params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,key_profileID,@"0" ,@"is_like", nil];

    // Vanancy - add request into QUEUE
    NSMutableDictionary* queueDict = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:key_snapshotQueue]] ;
    NSMutableArray *queue = [[NSMutableArray alloc]initWithArray:[queueDict objectForKey:appDel.myProfile.s_ID]] ;
    if (queue) {
        [queue addObject:params];
    }
    [queueDict setObject:queue forKey:appDel.myProfile.s_ID];
    [[NSUserDefaults standardUserDefaults] setObject:queueDict forKey:key_snapshotQueue];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSnapShotID"];
    if ([answerChoice isEqualToString:@"1"]) {
//        [self showMatchView];// DEBUG
//        return; //DEBUG
        for (int i=0; i < [appDel.likedMeList count]; i++) {
            NSString *s_profileID = [[appDel.likedMeList objectAtIndex:i] valueForKey:key_profileID];
            if([s_profileID isEqualToString:value]){
                [self showMatchView];
                break;
            }
        }
    }
    
    //update flow setLike in Snapshot
    [request setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"POST" path:URL_setLikedSnapshot parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [queue removeObject:params];
        [queueDict setObject:queue forKey:appDel.myProfile.s_ID];
        [[NSUserDefaults standardUserDefaults] setObject:queueDict forKey:key_snapshotQueue];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"post success !!!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       NSLog(@"URL_setLikedSnapshot - Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
    
//    [operation start];
    [setLikedQueue addOperation:operation];

    /*
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setLikedSnapshot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"post success !!!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_setLikedSnapshot - Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
     */
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

-(NSString*)formatTextWithName:(NSString*)name andAge:(NSString*)age{
    NSString* result;
    if([name length] > 10){
        name = [name substringToIndex:10];
        name = [name stringByReplacingCharactersInRange:NSMakeRange([name length]-3, 3) withString:@"..."];
    }
    result = [NSString stringWithFormat:@"%@, %@",name,age];
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
-(void)startLoadingAnimFocus:(BOOL)focus and:(void(^)(void))handler{
    isLoading = YES;
//    [self stopWarning];
//    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [appDel showSnapshotLoadingThenFocus:focus and:^void {
        if (handler) {
            handler();
        }
    }];
    VCSimpleSnapshotLoading* vc = [appDel.activeVC.viewControllers objectAtIndex:0];
    [vc setTypeOfAlert:0];
    
//    [self.navigationController pushViewController:loadingView animated:NO];
}

-(void)startDisabledGPS:(BOOL)focus{
//    loadingView = [[VCSimpleSnapshotLoading alloc]init];
//    [loadingView setTypeOfAlert:2 andAnim:loadingAnim];
//    [self.navigationController pushViewController:loadingView animated:NO];
    [appDel showSnapshotLoadingThenFocus:focus and:^void(){
        
    }];
    VCSimpleSnapshotLoading* vc = [appDel.activeVC.viewControllers objectAtIndex:0];
    [vc setTypeOfAlert:2 /*andAnim:loadingAnim*/];
    isBlockedByGPS = TRUE;
}

- (void)showWarning:(BOOL)focus{
    if(isBlockedByGPS){
        [self startDisabledGPS:YES];
    }
    else{
        [appDel showSnapshotLoadingThenFocus:focus and:^void(){}];
        VCSimpleSnapshotLoading* vc = [appDel.activeVC.viewControllers objectAtIndex:0];
        [vc setTypeOfAlert:1 /*andAnim:loadingAnim*/];
    }
}

-(void)stopWarning
{
    
    if ([self.navigationController.topViewController isKindOfClass:[VCSimpleSnapshotLoading class]])
    {
        VCSimpleSnapshotLoading *currentLoading = (VCSimpleSnapshotLoading *) self.navigationController.topViewController;
        if (currentLoading && currentLoading.typeOfAlert == 1)
        {
            [appDel showSimpleSnapshotThenFocus:NO];
//            [self.navigationController popViewControllerAnimated:NO];
            
        }
    }
}

-(void)stopDisabledGPS
{
    [self disableAllControl:NO];
    [appDel showSimpleSnapshotThenFocus:NO];
//    [self.navigationController popViewControllerAnimated:NO];
    isBlockedByGPS = FALSE;
}

-(void)stopLoadingAnim{
    if (isLoading)
    {
//        [self.spinner stopAnimating];
        [self disableAllControl:NO];
        isLoading = NO;
        [appDel showSimpleSnapshotThenFocus:NO];
//        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark First time Popup
-(void)showFirstSnapshotPopup:(NSString*)answerChoice{
    int answer= [answerChoice integerValue];
    if(answer > -1){
        [popupFirstTimeView enableViewbyType:answer andFriendName:currentProfile.s_Name];
        [popupFirstTimeView.view setFrame:CGRectMake(0, 0, popupFirstTimeView.view.frame.size.width, popupFirstTimeView.view.frame.size.height)];
        [popupFirstTimeView.view localizeAllViews];
        [self.view addSubview:popupFirstTimeView.view];
    }
}

#pragma mark App life cycle delegate
-(void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
    UINavigationController* activeVC = [appDel activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    PKRevealControllerState* state =  appDel.rootVC.state;
    if(![vc isKindOfClass:[VCChat class]]){
        [self refreshSnapshotFocus:NO];
    }*/
    PKRevealControllerState state =  appDel.rootVC.state;
    if(state == PKRevealControllerFocusesFrontViewController){
        [self refreshSnapshotFocus:NO];
    }
}

-(BOOL)isContinueLoad
{
    return !(currentIndex >= [profileList count]);
}

#pragma mark MoveMeView - Delegate
-(void)animationDidStop:(CAAnimation *)anim andAnswerType:(int)answerType{
    NSLog(@"animationDidStop ------");
    [self disableAllControl:NO];
    [self.moveMeView removeSubviewFromCardViewWithTag:101];
    if(answerType != -1 && self.isContinueLoad){
        [self loadCurrentProfile];
        [self loadNextProfileByCurrentIndex];
    }
    else if (!self.isContinueLoad)
    {
        [self refreshSnapshotFocus:NO];
    }
}

#pragma mark onTouch handle
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
	if ([touch view] == self.backgroundAvatarView) {
        NSLog(@"touchesBegan ------ backgroundAvatarView");
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	if ([touch view] == self.backgroundAvatarView) {
        NSLog(@"touchesEnded ------ backgroundAvatarView");
    }
}

-(void)onBackFromPopup
{
    [[self navBarOakClub] disableAllControl: NO];
    appDel.rootVC.recognizesPanningOnFrontView = YES;
}
@end
