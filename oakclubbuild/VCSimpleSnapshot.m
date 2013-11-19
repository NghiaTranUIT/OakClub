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

@interface VCSimpleSnapshot () <LocationUpdateDelegate, AppLifeCycleDelegate,APLMoveMeViewDelegate> {
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
@property (weak, nonatomic) IBOutlet UIButton *btnX;
@property (weak, nonatomic) IBOutlet UIButton *btnHeart;
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
    self.moveMeView.movemedelegate = self;
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
     NSLog(@"URL_getListWhoLikeMe - Error Code: %i - %@",[error code], [error localizedDescription]);
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
    currentIndex = 0;
    profileList = [[NSMutableArray alloc] init];
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"35",@"limit", nil];
    [request getPath:URL_getSnapShot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
    {
        is_loadingProfileList = FALSE;
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        
        int status= [[dict valueForKey:@"status"] integerValue];
        NSArray *profiles = [dict valueForKey:key_data];
        if (status == 0 || [profiles count] < 2)
        {
            [self showWarning];
        }
        else
        {
            for( id profileJSON in profiles)
            {
                Profile* profile = [[Profile alloc]init];
                [profile parseGetSnapshotToProfile:profileJSON];
                [profileList addObject:profile];
            }
            if(handler != nil)
                handler();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get snapshot Error Code: %i - %@",[error code], [error localizedDescription]);
        is_loadingProfileList = NO;
        [self showWarning];
    }];
}

-(void)loadNextProfileByCurrentIndex{
    if(currentIndex >= [profileList count])
    {
//        [self showWarning];
        return;
    }
    Profile * temp  =  [[Profile alloc]init];
    temp = [profileList objectAtIndex:currentIndex];
    if(temp.img_Avatar != nil && [temp.img_Avatar isKindOfClass:[UIImage class]]){
        [self.imgNextProfile setImage:temp.img_Avatar];
    }
    else{
        [self.imgNextProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    }
    NSLog(@"Name of Profile : %@",currentProfile.s_Name);
}
-(void)loadCurrentProfile{
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
    [self.imgMainProfile setImage:[UIImage imageNamed:@"Default Avatar"]];
    [lblPhotoCount setText:@"0"];
    if(currentProfile.img_Avatar!= nil){
        [self.imgMainProfile setImage:currentProfile.img_Avatar];
    }
    else{
        if(currentProfile.arr_photos != nil){
            if(([currentProfile.arr_photos count] > 0) && [currentProfile.arr_photos[0] isKindOfClass:[UIImage class]]){
                [self.imgMainProfile setImage:[currentProfile.arr_photos objectAtIndex:0]];
                [lblPhotoCount setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_photos count]]];
            }
            else{
                AFHTTPRequestOperation *operation =
                [Profile getAvatarSync:currentProfile.s_Avatar
                              callback:^(UIImage *image)
                 {
                     [self.imgMainProfile setImage:image];
                     if([currentProfile.arr_photos count]<1){
                         [currentProfile.arr_photos addObject:image];
                     }
                     else{
                         [currentProfile.arr_photos replaceObjectAtIndex:0 withObject:image];
                     }
                     [lblPhotoCount setText:[NSString stringWithFormat:@"%i",[currentProfile.arr_photos count]]];
                 }];
                [operation start];
            }
        }
    }
   

    [self stopLoadingAnim];
    currentIndex++;
}

- (void) viewWillAppear:(BOOL)animated{
//    [self.view addSubview:loadingAnim];
    [self.moveMeView localizeAllViews];
    [self.controlView localizeAllViews];
//    [[self navBarOakClub] setHeaderName:[NSString localizeString:@"Snapshot"]];
    
    //load data
    [self loadLikeMeList];
    //load profile list if needed
    if( appDel.reloadSnapshot){
        [self refreshSnapshot];
        appDel.reloadSnapshot = FALSE;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showNotifications];
}

- (void)viewDidUnload
{
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
    
    [viewProfile loadProfile:currentProfile andImage:currentProfile.img_Avatar];

    [self.view addSubview:viewProfile.view];
    if(IS_OS_7_OR_LATER){
        viewProfile.view.frame = CGRectMake(0, [[UIScreen mainScreen]applicationFrame].size.height, 320, [[UIScreen mainScreen]applicationFrame].size.height);
    }
    else{
        viewProfile.view.frame = CGRectMake(0, [[UIScreen mainScreen]applicationFrame].size.height, 320, [[UIScreen mainScreen]applicationFrame].size.height);
    }
    
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
                     }];
    [self.view addSubview:imgMainProfile];
    [imgMainProfile setFrame:CGRectMake(50, 30, 228, 228)];
    [UIView animateWithDuration: 0.4
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.navigationController setNavigationBarHidden:YES animated:YES];
                         imgMainProfile.frame = CGRectMake((320-275)/2, 0, 275, 275);
                     }
                     completion:^(BOOL finished) {
                         [imgMainProfile setHidden:YES];
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
    [self.view addSubview:matchViewController.view];
    [matchViewController.view setFrame:CGRectMake(0, 0, matchViewController.view.frame.size.width, matchViewController.view.frame.size.height)];
    if ([value_appLanguage_VI isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage]])
    {
        [lblMatchAlert setText:[NSString stringWithFormat:@"Còn ngại gì nữa, bạn với %@ đều thích nhau rồi!",currentProfile.s_Name]];
    }
    else
    {
        [lblMatchAlert setText:[NSString stringWithFormat:@"You and %@ have liked each other!",currentProfile.s_Name]];
    }
    
    
    
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
//    stamp.transform = CGAffineTransformMakeRotation(30.0f);
    [self.moveMeView addSubViewToCardView:stamp andAtFront:YES andTag:101];
    [UIView animateWithDuration:0.2
                     animations:^{
                        [stamp setAlpha:1.0f];
                         stamp.transform = CGAffineTransformIdentity;
                     }completion:^(BOOL finished) {
                         [self.moveMeView animatePlacardViewByAnswer:choose andDuration:0.5f];
                     }];
    [self setFavorite:[NSString stringWithFormat:@"%i",choose]];
}

-(void)setFavorite:(NSString*)answerChoice{
    int isFirstTime = [[[NSUserDefaults standardUserDefaults] objectForKey:key_isFirstSnapshot] integerValue];
    if(isFirstTime==0 || (isFirstTime < 4 &&
        ( (isFirstTime == interestedStatusNO && [answerChoice integerValue] == interestedStatusYES)
           || (isFirstTime == interestedStatusYES && [answerChoice integerValue]== interestedStatusNO)
        )
       ))
    {
        [self showFirstSnapshotPopup:answerChoice];
        [self.moveMeView setAnswer:-1];
        isFirstTime+=[answerChoice integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:isFirstTime forKey:key_isFirstSnapshot];
        return;
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
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setFavorite parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"post success !!!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_setFavorite - Error Code: %i - %@",[error code], [error localizedDescription]);
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
        name = [name substringToIndex:10];
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
    [self stopWarning];
    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [loadingView setTypeOfAlert:0 andAnim:loadingAnim];
    isLoading = YES;
    [self.navigationController pushViewController:loadingView animated:NO];
}

-(void)startDisabledGPS{
    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [loadingView setTypeOfAlert:2 andAnim:nil];
    [self.navigationController pushViewController:loadingView animated:NO];
    isBlockedByGPS = TRUE;
}

- (void)showWarning{
    [self stopLoadingAnim];
    loadingView = [[VCSimpleSnapshotLoading alloc]init];
    [loadingView.view setFrame:CGRectMake(0, 0, 320, 480)];
    [loadingView setTypeOfAlert:1 andAnim:nil];
    [self.navigationController pushViewController:loadingView animated:NO];
}

-(void)stopWarning
{
    if ([self.navigationController.topViewController isKindOfClass:[VCSimpleSnapshotLoading class]])
    {
        VCSimpleSnapshotLoading *currentLoading = (VCSimpleSnapshotLoading *) self.navigationController.topViewController;
        if (currentLoading && currentLoading.typeOfAlert == 1)
        {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
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

-(BOOL)isContinueLoad
{
    return !(currentIndex > [profileList count] - 2);
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
        [self showWarning];
    }
}
@end
