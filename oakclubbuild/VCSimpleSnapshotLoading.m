//
//  VCSimpleSnapshotLoading.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshotLoading.h"
#import "AnimatedGif.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"
@interface VCSimpleSnapshotLoading (){
    int typeOfAlert; // 0-Finding, 1-DoneSearching , 2-Noresult
    UIImageView* loadingAnim;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UIButton *btnContentAlert;
@property (weak, nonatomic) IBOutlet UIImageView *imgNOPEDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgiDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgLIKEDisable;
@property (weak, nonatomic) IBOutlet UILabel *lblContentAlert;

@end

@implementation VCSimpleSnapshotLoading
@synthesize lblContentAlert, imgiDisable, imgLIKEDisable, imgLoading,imgNOPEDisable,btnContentAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snapshot_gps_loading.gif" ofType:nil]];
        loadingAnim = 	[AnimatedGif getAnimationForGifAtUrl: fileURL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES];
//    [self.navigationController setNavigationBarHidden:YES];
    [self customBackButtonBarItem];
    [self  loadViewbyType];
}
-(void)customBackButtonBarItem{
    UIButton* buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(10, 8, 40, 30);
    [buttonBack addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_menu.png"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(menuPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack addTarget:self action:@selector(onTouchDownControllButton:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
    UIView* rightItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    UIButton* buttonChat = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonChat.frame = CGRectMake(IS_OS_7_OR_LATER?41:31, 8, 45, 30);
    [buttonChat addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [buttonChat setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_chat_up.png"] forState:UIControlStateNormal];
    [buttonChat addTarget:self action:@selector(rightItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonChat addTarget:self action:@selector(onTouchDownControllButton:) forControlEvents:UIControlEventTouchDown];
    [rightItemView addSubview:buttonChat];
    
   
    AppDelegate* appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appdel countTotalNotifications] > 0){
        UILabel* lblNumNotification = [[UILabel alloc]initWithFrame:CGRectMake(IS_OS_7_OR_LATER?23:13, 2, 30, 21)];
        [lblNumNotification setFont:FONT_HELVETICANEUE_LIGHT(14)];
        [lblNumNotification setTextColor:[UIColor whiteColor]];
        [lblNumNotification setBackgroundColor:[UIColor clearColor]];
        [lblNumNotification setTextAlignment:NSTextAlignmentCenter];
        UIImageView* imgViewNotification = [[UIImageView alloc]initWithFrame:CGRectMake(IS_OS_7_OR_LATER?23:13, 3, 31, 20)];
        [imgViewNotification setImage:[UIImage imageNamed:@"Navbar_notification.png"]];
        [rightItemView addSubview:imgViewNotification];
        lblNumNotification.text = [NSString stringWithFormat:@"+%d", [appdel countTotalNotifications]];
        [rightItemView addSubview:lblNumNotification];
    }
    
    
    UIBarButtonItem *buttonChatItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
    
    self.navigationItem.rightBarButtonItem = buttonChatItem;
    
//    [self setNotifications:20];
}
-(void)viewWillAppear:(BOOL)animated{
//    [self  loadViewbyType];
    
    AppDelegate* appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appdel.reloadSnapshot){
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    [self.view localizeAllViews];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Load view by typeOfAlert
-(void) setTypeOfAlert:(int)type andAnim:(UIImageView*)imgAnim{
    typeOfAlert = type;
    for (UIView * subview in [self.view subviews]){
        if([subview isKindOfClass:[UIImageView class]]){
            [subview removeFromSuperview];
        }
    }
    if(imgAnim != nil){
        [imgAnim setFrame:CGRectMake(48, 35, imgAnim.frame.size.width, imgAnim.frame.size.height)];
        [self.view  addSubview:imgAnim];
    }
    [self loadViewbyType];
    
}
-(void)loadViewbyType
{
    switch (typeOfAlert) {
        case 0:
        {
            [self.view addSubview:imgNOPEDisable];
            [self.view addSubview:imgLIKEDisable];
            [self.view addSubview:imgiDisable];
            [btnContentAlert setHidden:YES];
            [lblContentAlert setText:[@"Finding nearby people ..." localize]];
            break;
        }
        case 1:
        {
            [btnContentAlert setHidden:NO];
            [lblContentAlert setText:[@"You've seen all the recommendations near you." localize]];
            [imgLoading setImage:[UIImage imageNamed:@"SnapshotLoading_map_loaded.png"]];
            [self.view addSubview:imgLoading];
            break;
        }
        case 2:
        {
            [self.view addSubview:imgNOPEDisable];
            [self.view addSubview:imgLIKEDisable];
            [self.view addSubview:imgiDisable];
            [imgLoading setImage:[UIImage imageNamed:@"SnapshotLoading_graymap_loaded.png"]];
            [self.view addSubview:imgLoading];
            [btnContentAlert setHidden:YES];
            [lblContentAlert setText:[@"Location setting is disabled" localize]];
        }
        default:
            break;
    }
}
- (IBAction)onTouchTellYourFriends:(id)sender {
    NSString* body = @"Join www.OakClub.com .. and meet many cool singles nearby. Safe, trustworthy and private";
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:body,[UIImage imageNamed:@"SnapshotSetting_oakclub_logo.png"],nil] applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[/*UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, */UIActivityTypePostToWeibo, UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark handle onTouch in button
- (void)menuPressed:(id)sender {
    NSLog(@"openMenu");
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    appDel.rootVC.recognizesPanningOnFrontView = YES;
    [appDel showLeftView];
}
-(void)onTouchDownControllButton:(id)sender{
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    appDel.rootVC.recognizesPanningOnFrontView = NO;
}

- (void)rightItemPressed:(id)sender {
    NSLog(@"rightItemPressed");
    
        AppDelegate *appDel = [UIApplication sharedApplication].delegate;
        appDel.rootVC.recognizesPanningOnFrontView = YES;
        [appDel.rootVC showViewController:appDel.chat];
}

#pragma mark notification
-(void)setNotifications:(int)count
{
    UILabel* lblNumNotification = [[UILabel alloc]initWithFrame:CGRectMake(248, 1, 30, 21)];
    UIImageView* imgViewNotification = [[UIImageView alloc]initWithFrame:CGRectMake(248, 3, 31, 20)];
    [imgViewNotification setImage:[UIImage imageNamed:@"Navbar_notification.png"]];
//    self.labelNotifications = (UILabel *) [self.customView viewWithTag:5];
//    self.imageNotifications = (UIImageView *) [self.customView viewWithTag:6];
    
    if(count > 0)
    {
//        lblNumNotification.hidden = NO;
//        imageNotifications.hidden = NO;
        lblNumNotification.text = [NSString stringWithFormat:@"+%d", count];
        [self.navigationController.navigationBar addSubview:lblNumNotification];
        [self.navigationController.navigationBar addSubview:imgViewNotification];
        
        
    }
}
@end
