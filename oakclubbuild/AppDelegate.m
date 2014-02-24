//
//  AppDelegate.m
//  oakclubbuild
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"

#import "HistoryMessage.h"
#import "FacebookSDK/FBWebDialogs.h"
#import "PhotoUpload.h"
#import "NSString+Utils.h"
#import "UIView+Localize.h"

#import "AppLifeCycleDelegate.h"
#import "VCSimpleSnapshot.h"
#import "VCSimpleSnapshotLoading.h"
#import "MatchMaker.h"
#import "VIPRoom.h"
#import "UserVerificationPage.h"
#import "OakClubIAPHelper.h"
#import "NEVersionCompare.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"


NSString *const SCSessionStateChangedNotification =
@"com.facebook.Scrumptious:SCSessionStateChangedNotification";
@interface AppDelegate() <UIAlertViewDelegate>

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end
@implementation AppDelegate
{
//    NSString* s_DeviceToken;
    NSTimer *pingTimer;
}
NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";
// for Chatting
@synthesize messageDelegates;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize window;
@synthesize navigationController;
@synthesize settingsViewController;
// end Chatting
@synthesize myFBProfile = _myFBProfile;
@synthesize myProfile = _myProfile;
//@synthesize hangoutView = _hangout;
@synthesize loginView = _loginView;
@synthesize flashIntro = _flashIntro;
@synthesize confirmVC = _confirmVC;
@synthesize chat = _chat;
#if ENABLE_DEMO
@synthesize simpleSnapShot = _simpleSnapShot;
@synthesize snapShotSettings = _snapShotSettings;
@synthesize matchMaker = _matchMaker;
@synthesize vipRoom = _vipRoom;
@synthesize userVerificationPage = _userVerificationPage;
@synthesize snapshotLoading = _snapshotLoading;
// multi language
@synthesize languageBundle = _languageBundle;
#endif
@synthesize rootVC = _rootVC;
@synthesize myProfileVC = _myProfileVC;
//@synthesize getPoints = _getPoints;

@synthesize friendChatList;
@synthesize accountSetting;
@synthesize activeVC;

@synthesize session = _session;

@synthesize imagePool;
@synthesize snapshotSettingsObj;

@synthesize pushNotificationInfo;
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
//==============================================================//
#pragma mark UIApplicationDelegate
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
//    [httpClient getPath:URL_getListChat parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
//        NSError *err;
//        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&err];
//        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", @"getRosterListIDSync");
//        NSLog(@"Dan list chat: %@", jsonString);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"get list chat Error: %@", error);
//    }];
    
//    return false;
    
    self.imagePool = [[ImagePool alloc] init];
    self.snapshotSettingsObj = [[SettingObject alloc] init];
    self.notificationCenter = [[NSNotificationCenter alloc] init];
    self.messageDelegates = [[NSMutableArray alloc] init];
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    //Vanancy - add flag for reload data in Snapshot
    self.reloadSnapshot = FALSE;
    
    [self tryGetLanguageFromDevice];
    
    //load first screen of Application.
    self.flashIntro = [[FlashIntro alloc] init];
    [self.flashIntro.view setFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    self.window.rootViewController = self.flashIntro;
    [self.window makeKeyAndVisible];
    
    self.loginView = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    
	// Check if the app was launched in response to the user tapping on a
	// push notification. If so, we add the new message to the data model.
	if (launchOptions != nil)
	{
        self.pushNotificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	}
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0293" ofType:@"MOV"];
//    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    path = [[NSBundle mainBundle] pathForResource:@"IMG_0293" ofType:@"mov"];
//    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    [OakClubIAPHelper sharedInstance];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGoolgeTrackingId];
    
    return YES;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSLog(@"add video success");
    }
}

-(void)gotoLogin
{
    if(!self.loginView.isBeingPresented) {
        //        self.loginView = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
        //        [self.rootVC presentModalViewController:self.loginView animated:YES];
        self.window.rootViewController = self.loginView;
    }
}

-(void)gotoVCAtCompleteLogin
{
    BOOL isFirstLogin = ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstLogin"] boolValue];
    if (isFirstLogin)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isFirstLogin"];
        
        TutorialViewController *tut = [[TutorialViewController alloc] init];
        self.window.rootViewController = tut;
        [self.window makeKeyAndVisible];
        
        [self updateLanguageToServer];
    }
    else
    {
        menuViewController *leftController = [[menuViewController alloc] init];
        [leftController setUIInfo:self.myProfile];
        [self.rootVC setRightViewController:self.chat];
        [self.rootVC setLeftViewController:leftController];
        self.window.rootViewController = self.rootVC;
        if (self.pushNotificationInfo)
        {
            NSDictionary *data = self.pushNotificationInfo[key_data];
            NSString *chatUserName = data[key_name];
            NSString *chatUserID = data[key_profileID];
            NSString *chatUserXMPPID = [NSString stringWithFormat:@"%@%@", chatUserID, DOMAIN_AT];
            
            Profile *chatPushNotificationProfile = [self.myProfile.dic_Roster objectForKey:chatUserID];
            if (!chatPushNotificationProfile)
            {
                Profile *chatPushNotificationProfile = [[Profile alloc] init];
                chatPushNotificationProfile.s_Name = chatUserName;
                chatPushNotificationProfile.s_ID = chatUserID;
            }
            
            self.rootVC.recognizesPanningOnFrontView = YES;
            [self.rootVC showViewController:self.chat];
            
            NSString *notifChatID = chatPushNotificationProfile.s_ID;
            NSMutableArray *chatMessagesArray = [self.myProfile.a_messages objectForKey:notifChatID];
            if (!chatMessagesArray)
            {
                chatMessagesArray = [[NSMutableArray alloc] init];
                [self.myProfile.a_messages setObject:chatMessagesArray forKey:notifChatID];
            }
            
            SMChatViewController *chatController =
            [[SMChatViewController alloc] initWithUser:chatUserXMPPID
                                           withProfile:chatPushNotificationProfile
                                          withMessages:chatMessagesArray];
            
            [self.rootVC setFrontViewController:self.chat focusAfterChange:YES completion:^(BOOL finished) {
                
            }];
            [self.chat pushViewController:chatController animated:NO];
        }
        
        [self checkVerification];
    }
}

- (BOOL)checkVerification {
    BOOL isForceVerify = self.myProfile.isForceVerify;
    
    BOOL isSkipButtonPressed = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isSkipButtonPressed"] boolValue];
    BOOL isMan = (self.myProfile.s_gender.ID == MALE);
    BOOL isVerify = !self.myProfile.isVerified && isMan && !isSkipButtonPressed;
    
//    isVerify = true;
    //    isForceVerify = true;
    
    if (isForceVerify || isVerify) {
        UserVerificationPage *userVerificationPage = [[UserVerificationPage alloc] init];
        userVerificationPage.isForceVerify = isForceVerify;
        userVerificationPage.isPopOver = YES;
        self.window.rootViewController = userVerificationPage;
        [self.window makeKeyAndVisible];
        return YES;
    }
    
    return NO;
}

-(void)loadAllViewControllers{
    self.chat = [self createNavigationByClass:@"VCChat" AndHeaderName:@"Chat History" andRightButton:nil andIsStoryBoard:NO];

    self.simpleSnapShot = [self createNavigationByClass:@"VCSimpleSnapshot" AndHeaderName:nil andRightButton:@"VCChat" andIsStoryBoard:NO];
    //     self.snapShotSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"SnapshotSettings"];
    self.snapShotSettings = [self createNavigationByClass:@"VCSimpleSnapshotSetting" AndHeaderName:@"Settings" andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.matchMaker = [self createNavigationByClass:@"MatchMaker" AndHeaderName:@"Matchmaker" andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.vipRoom = [self createNavigationByClass:@"VIPRoom" AndHeaderName:@"VIP Room" andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.userVerificationPage = [self createNavigationByClass:@"UserVerificationPage" AndHeaderName:@"Verification" andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.snapshotLoading = [self createNavigationByClass:@"VCSimpleSnapshotLoading" AndHeaderName:nil andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.myProfileVC = [self createNavigationByClass:@"VCMyProfile" AndHeaderName:@"Edit Profile" andRightButton:@"VCChat" andIsStoryBoard:NO];
//    self.getPoints = [self createNavigationByClass:@"VCGetPoints" AndHeaderName:@"Get Coins" andRightButton:nil andIsStoryBoard:NO];
    self.confirmVC = [self createNavigationByClass:@"UpdateProfileViewController" AndHeaderName:@"Update Profile" andRightButton:nil andIsStoryBoard:NO];
    // PKRevealController
    
#if ENABLE_DEMO
    activeVC = _simpleSnapShot;
    self.rootVC = [PKRevealController revealControllerWithFrontViewController:self.simpleSnapShot
                                                          rightViewController:self.chat
                                                                      options:nil];
#else
    activeVC = _snapShoot;
    self.rootVC = [PKRevealController revealControllerWithFrontViewController:self.snapShoot
                                                           leftViewController:nil
                                                                      options:nil];
#endif
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// We have received a new device token. This method is usually called right
	// away after you've registered for push notifications, but there are no
	// guarantees. It could take up to a few seconds and you should take this
	// into consideration when you design your app. In our case, the user could
	// send a "join" request to the server before we have received the device
	// token. In that case, we silently send an "update" request to the server
	// API once we receive the token.
    
	//NSString* oldToken;//[dataModel deviceToken];
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	self.s_DeviceToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", self.s_DeviceToken);
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	// If we get here, the app could not obtain a device token. In that case,
	// the user can still send messages to the server but the app will not
	// receive any push notifications when other users send messages to the
	// same chat room.
    
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (application.applicationState == UIApplicationStateInactive)
    {
        [self addMessageFromRemoteNotification:userInfo updateUI:YES];
    }
    
	NSLog(@"Received notification: %@", userInfo);
}

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
    self.pushNotificationInfo = userInfo;
    
    NSDictionary *data = userInfo[key_data];
    NSString *chatUserName = data[key_name];
    NSString *chatUserID = data[key_profileID];
    NSString *chatUserXMPPID = [NSString stringWithFormat:@"%@%@", chatUserID, DOMAIN_AT];
    
    // check invalid chat friend
    if (!chatUserID || [@"" isEqualToString:chatUserID] || [self.myProfile.s_ID isEqualToString:chatUserID])
    {
        return;
    }
    
    Profile *chatPushNotificationProfile = [self.myProfile.dic_Roster objectForKey:chatUserID];
    bool needToReloadChatFriend = false;    // flag for get friend profile info later
    if (!chatPushNotificationProfile)  // already new friend
    {
        chatPushNotificationProfile = [[Profile alloc] init];
        chatPushNotificationProfile.s_ID = chatUserID;
        chatPushNotificationProfile.s_Name = chatUserName;
        
        // add friend to chat
        XMPPJID* jid = [XMPPJID jidWithString:chatUserXMPPID];
        
        [friendChatList setObject:chatPushNotificationProfile forKey:chatUserXMPPID];
        [xmppRoster addUser:jid withNickname:chatPushNotificationProfile.s_Name];
        
        needToReloadChatFriend = true;
    }
    
    // check invalid friend data ???
    if (updateUI)
    {
        UIViewController *focusedVC = [self.rootVC focusedController];
        if (focusedVC == self.chat)
        {
            UIViewController *topVC = [self.chat topViewController];
            if ([topVC isKindOfClass:[SMChatViewController class]])
            {
                [self.chat popViewControllerAnimated:NO];
            }
        }
        else
        {
            //show chat
            self.rootVC.recognizesPanningOnFrontView = YES;
            [self.rootVC showViewController:self.chat];
        }
        
        [self.rootVC setFrontViewController:self.chat];
        
        NSMutableArray *chatMessagesArray = [self.myProfile.a_messages objectForKey:chatUserID];
        if (!chatMessagesArray)
        {
            chatMessagesArray = [[NSMutableArray alloc] init];
            [self.myProfile.a_messages setObject:chatMessagesArray forKey:chatUserID];
        }
        
        SMChatViewController *chatController =
        [[SMChatViewController alloc] initWithUser:chatUserXMPPID
                                       withProfile:chatPushNotificationProfile
                                      withMessages:chatMessagesArray];
        [self.chat pushViewController:chatController animated:NO];
        
        NSLog(@"OPEN SMCHAT -- FOCUS: %d", self.rootVC.state);
    }
    
    if (needToReloadChatFriend) // reload chat friend last for make sure chat window has observed notification
    {
        [chatPushNotificationProfile getProfileInfo:^{
            NSString *notificationName = [NSString stringWithFormat:Notification_ChatFriendChanged_Format, chatUserXMPPID];
            [self.notificationCenter postNotificationName:notificationName object:chatPushNotificationProfile];
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //Vanancy - check for sure internet connection always work in app
    
    [self checkInternetConnection];
    
    [FBSession.activeSession handleDidBecomeActive];
    
    BOOL isPaymentProcessing = (activeVC == self.vipRoom);
    BOOL isPostProcessing = (activeVC == self.userVerificationPage) || [self.window.rootViewController isKindOfClass:[UserVerificationPage class]];
    if (!isPaymentProcessing && !isPostProcessing) {
        [self.notificationCenter postNotificationName:Notification_ApplicationDidBecomeActive object:nil];
    }
    
    // CHEAT:
//    if (!self.myProfile)
//        return;
//    NSDictionary *remoteNotifs = @{@"data" : @{@"profile_id" : @"1m01j76t9p", @"name" : @"An Nguyen"}};
//    if (remoteNotifs)
//    {
//        NSLog(@"Launched from push notification: %@", remoteNotifs);
//        
//        //
//        NSDictionary *data = remoteNotifs[key_data];
//        chatPushNotificationProfile = [[Profile alloc] init];
//        chatPushNotificationProfile.s_Name = data[key_name];
//        chatPushNotificationProfile.s_ID = data[key_profileID];
//        
//        [self application:application didReceiveRemoteNotification:remoteNotifs];
//    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url
                                      sourceApplication:(NSString *)sourceApplication
                                             annotation:(id)annotation {
     return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(UINavigationController*)activeViewController
{
    return activeVC;
}

-(void)showChat {
    activeVC = _chat;
#if ENABLE_DEMO
    [self.rootVC showViewController:self.chat];
#else
    [self.rootVC setFrontViewController:self.chat focusAfterChange:YES completion:^(BOOL finished) {
    }];
#endif
    
        
}
#if ENABLE_DEMO
-(void)showSnapshotSettings {
    activeVC = _snapShotSettings;
    AppDelegate *appDel = self;
    [self.rootVC setFrontViewController:self.snapShotSettings focusAfterChange:YES completion:^(BOOL finished) {
        [appDel.rootVC setRightViewController:appDel.chat];
    }];
}
-(void)showMatchmaker {
    activeVC = _matchMaker;
    AppDelegate *appDel = self;
    [self.rootVC setFrontViewController:self.matchMaker focusAfterChange:YES completion:^(BOOL finished) {
        [appDel.rootVC setRightViewController:appDel.chat];
    }];
}

-(void)showVIPRoom {
    activeVC = _vipRoom;
    
    AppDelegate *appDel = self;
    [self.rootVC setFrontViewController:self.vipRoom focusAfterChange:YES completion:^(BOOL finished) {
        [appDel.rootVC setRightViewController:appDel.chat];
    }];
}

-(void)showUserVerificationPage {
    activeVC = _userVerificationPage;
    
    AppDelegate *appDel = self;
    [self.rootVC setFrontViewController:self.userVerificationPage focusAfterChange:YES completion:^(BOOL finished) {
        [appDel.rootVC setRightViewController:appDel.chat];
    }];
}

-(void)showSimpleSnapshotThenFocus:(BOOL)focus{
    
    AppDelegate *selfCopy = self;   // copy for retain cycle
    VCSimpleSnapshot *VCSSnapshot = self.simpleSnapShot.viewControllers[0];
    
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if( ![vc isKindOfClass:[VCSimpleSnapshotLoading class]] && !focus)
    {
        if(selfCopy.reloadSnapshot){
            [VCSSnapshot refreshSnapshotFocus:focus];
//            selfCopy.reloadSnapshot = FALSE;
        }
        return;
    }
    activeVC = _simpleSnapShot;
    PKRevealControllerState state =  self.rootVC.state;
//    UIViewController* vchat = [self.chat.viewControllers objectAtIndex:0]; //DEBUG
    if(state == PKRevealControllerFocusesRightViewController && [[self.chat viewControllers] count] > 1){
        return;
    }
    
    NSLog(@"VCSSnapshot.is_loadingProfileList: %d focus: %d", VCSSnapshot.is_loadingProfileList, focus);
    
    if (VCSSnapshot.is_loadingProfileList) {
        [self showSnapshotLoadingThenFocus:focus and:^void {
        }];
    } else if (selfCopy.reloadSnapshot) {
        [self showSnapshotLoadingThenFocus:focus and:^void {
            
        }];
        [VCSSnapshot refreshSnapshotFocus:focus];
        selfCopy.reloadSnapshot = FALSE;
        
    } else {
        [self.rootVC setFrontViewController:self.simpleSnapShot focusAfterChange:focus completion:^(BOOL finished) {
            //load profile list if needed
            if(selfCopy.reloadSnapshot){
                [VCSSnapshot refreshSnapshotFocus:focus];
                selfCopy.reloadSnapshot = FALSE;
            }
            if(!focus && selfCopy.rootVC.state != PKRevealControllerFocusesFrontViewController){
                NSLog(@"setUserInteractionEnabled:NO showSimpleSnapshotThenFocus");
                [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:NO];
            }
            else{
                [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:YES];
            }
        }];
    }
    
}
-(void)showSimpleSnapshot{
    AppDelegate *selfCopy = self;   // copy for retain cycle
    activeVC = _simpleSnapShot;
    [self.rootVC setFrontViewController:self.simpleSnapShot focusAfterChange:NO completion:^(BOOL finished) {
        NSLog(@"setUserInteractionEnabled:NO showSimpleSnapshot");
            [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:NO];
    }];
}

-(void)showSnapshotLoadingThenFocus:(BOOL)focus and:(void(^)(void))handler{
    AppDelegate *selfCopy = self;   // copy for retain cycle
    //    [self.rootVC setRootController:self.myLink animated:YES];
    //    [self.rootVC setContentViewController:self.myLink snapToContentViewController:YES animated:YES];
    activeVC = _snapshotLoading;
    [self.rootVC setFrontViewController:self.snapshotLoading focusAfterChange:focus completion:^(BOOL finished) {
        [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:YES];
        if(handler)
            handler();
    }];
}
#endif

-(void)showMyProfile {
    activeVC = _myProfileVC;
    [[self.myProfileVC.viewControllers objectAtIndex:0] setDefaultEditProfile:self.myProfile];
    [self.rootVC setFrontViewController:self.myProfileVC focusAfterChange:YES completion:^(BOOL finished) {
    }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
-(void)showInvite{
     NSMutableArray *suggestedFriends = [[NSMutableArray alloc] init];
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        for (NSDictionary<FBGraphUser>* friend in friends) {
            if([[friend objectForKey:@"installed"] integerValue]==0)
                [suggestedFriends addObject:friend.id];
        }
 
    }];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [suggestedFriends componentsJoinedByString:@","], @"to",
                                   nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Learn how to make your iOS apps social."
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSString *requestID = [urlParams valueForKey:@"request"];
                                                              NSLog(@"Request ID: %@", requestID);
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}];
}
-(void)showLeftView {
    [self.rootVC showViewController:self.rootVC.leftViewController];
}

-(void)logOut {
    [self.loginView stopSpinner];
    [self stopPingTimer];
    [self gotoLogin];
    [FBSession.activeSession closeAndClearTokenInformation];
    [self teardownStream];
    [self  disconnect];
	[[self  xmppvCardTempModule] removeDelegate:self];
}

-(void)showConfirm
{
    UpdateProfileViewController *updateProfileVC = [self.confirmVC.viewControllers objectAtIndex:0];
    [updateProfileVC updateProfile];
    self.window.rootViewController = self.confirmVC;
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Logged in!");
        }
            break;
        case FBSessionStateClosed:
            [self logOut];
            
            NSLog(@"Logged out!");
            
            break;
        case FBSessionStateClosedLoginFailed:
            //[self showLoginView];
            [self logOut];
            
            NSLog(@"Login failed! %@",error.fberrorUserMessage );

            break;
        default:
            
            NSLog(@"Not login yet!");
            break;
    }
    // show WARNING when confirm login with FB is FAILD
    /*[[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }  */  
}

-(void)parseProfileWithData:(NSDictionary *)data
{
    self.myProfile = [[Profile alloc] init];
    
    @try {
        [self.myProfile parseProfileWithData:data withFullName:YES];
    }
    @catch (NSException *exception) {
        [self showErrorData];
    }
    @finally {
    }
    
    [self.myProfile getRosterListIDSync:^{
    }];
    [self.imagePool getImageAtURL:self.myProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        
    }];
    [self.imagePool getImageAtURL:self.myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        
    }];
    [self setFieldValue:[NSString stringWithFormat:DOMAIN_AT_FMT,self.myProfile.s_usenameXMPP] forKey:kXMPPmyJID];
    [self setFieldValue:self.myProfile.s_passwordXMPP forKey:kXMPPmyPassword];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup the XMPP stream
    [self setupStream];
    [self connect];
    
    [self loadAllViewControllers];
    
    // async load data
    MatchMaker *matchMakerVC = (MatchMaker *) self.matchMaker.viewControllers[0];
    [matchMakerVC loadFriendsData];
}
    
- (void)openSessionWithhandler:(void(^)(FBSessionState))resultHandler
{
    NSArray *permission = [[NSArray alloc] initWithObjects:@"email, user_about_me, user_birthday, user_interests, user_location, user_relationship_details",nil];
    [FBSession openActiveSessionWithReadPermissions:permission
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
         if(resultHandler != nil){
             resultHandler(state);
         }
     }];
    
}
-(void) openSessionWithWebDialogWithhandler:(void(^)(FBSessionState))resultHandler
{
    FBSession *sessionApp = self.session;
    if (!sessionApp.isOpen)
    {
        [FBSession setActiveSession:sessionApp];
        sessionApp = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObject:@"email, user_about_me, user_birthday, user_interests, user_location, user_relationship_details"]];
        
        [sessionApp openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session,
                                                                                              FBSessionState status,
                                                                                              NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [FBSession setActiveSession:sessionApp];
            [self sessionStateChanged:session state:status error:error];
            if(resultHandler != nil){
                resultHandler(status);
            }
        }];
    }
    else
    {
        [FBSession setActiveSession:sessionApp];
        if(resultHandler != nil)
            resultHandler(sessionApp.state);
    }

}

#pragma mark FACEBOOK

-(void)loadFBUserInfo:(void(^)(id))resultHandler{
    //self.myProfile = [[Profile alloc] init];
    NSDictionary* params = [NSDictionary dictionaryWithObject:@"id,name,gender,relationship_status,about,location,interested_in,birthday,email,picture" forKey:@"fields"];
    [FBRequestConnection startWithGraphPath:@"me" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error || !result)
        {
            UIAlertView *cantConnectToFacebookAlert = [[UIAlertView alloc] initWithTitle:[@"Error" localize] message:[@"Can't connect to facebook! Check your internet connection and try again!" localize] delegate:nil cancelButtonTitle:[@"Ok" localize] otherButtonTitles:nil];
            [cantConnectToFacebookAlert show];
            return;
        }
        
        self.myFBProfile = result;
        
        if(resultHandler != nil)
        {
            resultHandler(result);
        }
    }];
}

-(void)parseFBInfoToProfile:(id)fbProfile
{
    id result = fbProfile;
    self.myProfile = [[Profile alloc] init];
    self.myProfile.s_ID = [result objectForKey:@"id"];
    self.myProfile.s_Name = [result objectForKey:@"name"];
    self.myProfile.s_gender = [[Gender alloc] initWithNSString:[result objectForKey:@"gender"]];
    self.myProfile.s_relationShip = [[RelationShip alloc] initWithNSString:[result objectForKey:@"relationship_status"]];
    NSArray *interests = [result objectForKey:@"interested_in"];
    int countInterest = [interests count];
    if(countInterest == 2)
        self.myProfile.s_interested = [[Gender alloc] initWithNSString:@"Both"];
    else
        if(countInterest == 0 && [self.myProfile.s_gender.text length]!= 0){
            if(self.myProfile.s_gender.ID == MALE)
                self.myProfile.s_interested = [[Gender alloc] initWithID:FEMALE];
            else
                if(self.myProfile.s_gender.ID ==FEMALE)
                    self.myProfile.s_interested = [[Gender alloc] initWithID:MALE];
        }
        else{
            self.myProfile.s_interested = [[Gender alloc] initWithNSString:[interests objectAtIndex:0]];
        }
    
    self.myProfile.s_FB_id = [result objectForKey:@"id"];
    //        self.myFBProfile.id = newAccount.s_FB_id;
    self.myProfile.s_birthdayDate = [result objectForKey:@"birthday"];
    self.myProfile.s_Email = [result objectForKey:@"email"];
    NSMutableDictionary *dict_Location = [result valueForKey:key_location];
    self.myProfile.s_location = [[Location alloc] initWithNSDictionaryFromFB:dict_Location];
}

-(BOOL)isFacebookActivated
{
    return (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen);
}

#pragma mark NAVIGATION

-(NavConOakClub *) createNavigationByClass:(NSString *)className AndHeaderName:(NSString*) headerName andRightButton:(NSString*)rightViewControll andIsStoryBoard:(BOOL)isStoryBoard{
    NavConOakClub *nvOakClub = [[NavConOakClub alloc] initWithNavigationBarClass:[NavBarOakClub class] toolbarClass:nil];
    Class _class = NSClassFromString(className);
    NSArray *array = [NSArray arrayWithObject:[[_class alloc] initWithNibName:className bundle:nil]];
    [nvOakClub setViewControllers:array];

    NavBarOakClub *tempBar = (NavBarOakClub*) nvOakClub.navigationBar;
    [tempBar setHeaderName:headerName];
    [tempBar setCurrentViewController:[array objectAtIndex:0]];

    if(isStoryBoard){
        UIStoryboard *settingsStoryboard = [UIStoryboard
                                            storyboardWithName:rightViewControll
                                            bundle:nil];
        UIViewController *settingsViewConroller = [settingsStoryboard
                                                   instantiateInitialViewController];
        [tempBar setRightViewController:settingsViewConroller];
    }
    else{
        if(rightViewControll != nil)
            [tempBar setRightButton:rightViewControll]; 
    }
    return nvOakClub;
}
-(BOOL)checkInternetConnection{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable) {
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                     message: NSLocalizedString(@"No internet connection found, this application requires an internet connection to gather the data required.", @"Network error")
                     delegate: self
                     cancelButtonTitle: NSLocalizedString(@"Close", @"Network error") otherButtonTitles: nil];
        
        [errorView show];
        return NO;
    }
    return YES;
}
-(void)loadDataForList:(void(^)(NSError *e))completion
{
    self.cityList = [[NSMutableDictionary alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:@"Never" forKey:@"key_EmailSetting"] ;
//    if(self.relationshipList != nil && [self.relationshipList count] > 0)
//        return;
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
    NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:selectedLanguage, @"country", nil];
    __block BOOL isLoadDataList = false, isLoadSnapshotSettings = false;
    __block NSError *apiError = nil;
    [request getPath:URL_getListLangRelWrkEth parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSLog(@"Get data for list completed");
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSMutableDictionary * data= [dict valueForKey:key_data];
         self.ethnicityList =[data valueForKey:key_ethnicity];
         self.workList = [data valueForKey:key_WorkCate];
         self.languageList = [data valueForKey:key_language];
         self.relationshipList = [data valueForKey:key_relationship];
         if([selectedLanguage isEqualToString:value_appLanguage_VI])
             self.genderList = GenderList_vi;
         else
             self.genderList = GenderList;
         
         isLoadDataList = true;
         if(isLoadSnapshotSettings && completion)
         {
             completion(apiError);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"URL_getListLangRelWrkEth - Error Code: %i - %@",[error code], [error localizedDescription]);
         isLoadSnapshotSettings = true;
         apiError = error;
     }];
    
    [self.snapshotSettingsObj loadSettingUseCompletion:^(NSError *err) {
        isLoadSnapshotSettings = true;
        if (!apiError)
        {
            apiError = err;
        }
        
        if (isLoadDataList && completion)
        {
            completion(apiError);
        }
    }];
}
#pragma mark Notification
-(int)countTotalNotifications
{
    return [self.myProfile countTotalNotifications];
}

-(void)updateNavigationWithNotification{
    [(NavBarOakClub*)self.activeVC.navigationBar setNotifications:[self countTotalNotifications]];
}


-(void)showLocalNotification
{
    /*
     // We are not active, so use a local notification instead
     UILocalNotification *localNotification = [[UILocalNotification alloc] init];
     localNotification.alertAction = @"Ok";
     localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName, body];
     
     [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
     */
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
}
-(void)updateLocalNotification:(int)num{
    [UIApplication sharedApplication].applicationIconBadgeNumber = num;
//    [self showLocalNotification];
}

-(void)loadFriendsList
{
    if (![xmppStream isAuthenticated]) {
        return;
    }
    
    int count = [self.myProfile.dic_Roster count];
    
    friendChatList = [[NSMutableDictionary alloc] init];
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSArray *IDs = [self.myProfile.dic_Roster allKeys];
    
    for (int i = 0; i < count; i++)
    {
        Profile *friend = [self.myProfile.dic_Roster objectForKey:[IDs objectAtIndex:i]];
        NSString* xmpp_id = [NSString stringWithFormat:@"%@%@", friend.s_ID, DOMAIN_AT];
        
        XMPPJID* jid = [XMPPJID jidWithString:xmpp_id];
        
        [friendChatList setObject:friend forKey:xmpp_id];
        
        NSLog(@"%d. Add friend id: %@", i, friend.s_ID);
        if(friend.s_Name == nil || [friend.s_Name isEqualToString:@""] || [friend.s_ID isEqualToString:self.myProfile.s_ID])
        {
            [xmppRoster removeUser:jid];
        }
        else
        {
            [xmppRoster addUser:jid withNickname:friend.s_Name];
            NSLog(@"%d.2 Set nick name: %s for user_id: %s", i, friend.s_Name.UTF8String, xmpp_id.UTF8String);
            
            // cache avatar
            [imagePool getImageAtURL:friend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
                
            }];
            
            NSString *notificationName = [NSString stringWithFormat:Notification_ChatFriendChanged_Format, xmpp_id];
            [self.notificationCenter postNotificationName:notificationName object:friend];
        }
    }
    
    if (self.chat)
    {
        VCChat *vcChat = self.chat.viewControllers[0];
        [vcChat loadFriendsInfo];
    }
}

//==============================================================//
#pragma mark Private
- (void)setFieldValue:(NSString *)field forKey:(NSString *)key
{
    if (field != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	//xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = NO; // auto get history chat list - Vanancy
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
	[xmppStream setHostName:HOSTNAME];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

- (void)goOnline
{
//	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
//	
//	[[self xmppStream] sendElement:presence];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}
//==============================================================//
#pragma mark Core Data
- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}
//==============================================================//



#pragma mark Connect/disconnect
- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	//[xmppStream setMyJID:[XMPPJID jidWithString:@"1lxvf4wfg3@doolik.com"]];
	//password = @"fdT2vs0QTLHN4XZaRFvYNuH6L6v64lLJ+I6atCcf2ujxKXatm0XWNgzSzBqDTb8VGPubfIjr4sTW0ddFCIx8Mg==";
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSLog(@"JID: %s", [myJID UTF8String]);
    NSLog(@"Password: %s", [password UTF8String]);
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}
//==============================================================//
#pragma mark XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

-(BOOL)isAuthenticated
{
    return [xmppStream isAuthenticated];
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
    NSLog(@"xmppStreamDidAuthenticate");

    [self loadFriendsList];
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}


-(void)sendMessageState:(NSString*)state to:(NSString*)xmpp_id
{
    NSXMLElement *stateXML = [NSXMLElement elementWithName:state];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:xmpp_id];
    [message addChild:stateXML];
    
    [self.xmppStream sendElement:message];
}

-(void)sendMessageContent:(NSString*)content to:(NSString*)xmpp_id
{
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:content];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:xmpp_id];
    [message addChild:body];
    
    [self.xmppStream sendElement:message];
}

- (XMPPMessage *)xmppStream:(XMPPStream *)sender willReceiveMessage:(XMPPMessage *)message
{
    return message;
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if([[message from].user isEqualToString:self.myProfile.s_ID])
        return;
	// A simple example of inbound message handling.
    
    NSString* jid = [NSString stringWithFormat:@"%@@%@",[message from].user, [message from].domain];
    
    // Vanancy :fix crash on receive new message from new friends.
    Profile *newFriend = [self.myProfile.dic_Roster objectForKey:[message from].user];
    if(!newFriend){
        XMPPJID* xmpp_jid = [XMPPJID jidWithString:jid];
        newFriend = [[Profile alloc]init];
        newFriend.s_ID =[message from].user;
        newFriend.status = ChatUnviewed;
        newFriend.unread_message++;
        [newFriend getProfileInfo:^(void){
            [xmppRoster addUser:xmpp_jid withNickname:newFriend.s_Name];
            [self.myProfile.dic_Roster setValue:newFriend forKey:newFriend.s_ID];
            [friendChatList setObject:newFriend forKey:jid];
            // cache avatar
            [imagePool getImageAtURL:newFriend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
                [self postReceiveMessage:message];
            }];
        }];
        
//        return;
    }
    else
    {
        newFriend.unread_message++;
        [self.friendChatList setObject:newFriend forKey:jid];
        [self postReceiveMessage:message];
    }
}

-(void)postReceiveMessage:(XMPPMessage *)message
{
    NSString* jid = [NSString stringWithFormat:@"%@@%@",[message from].user, [message from].domain];
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *type = [[message attributeForName:@"type"] stringValue];
    
    NSLog(@"didReceiveMessage: type=%@", type);
    
    if(msg == nil)
    {
        msg = [[message elementForName:@"composing"] stringValue];
        
        if(msg == nil)
            msg = [[message elementForName:@"paused"] stringValue];
    }
    NSLog(@"didReceiveMessage: msg=%@", msg);
    NSLog(@"didReceiveMessage: from=%@", jid);
    
    
    if(msg == nil || type == nil || [type isEqualToString:@"error"])
    {
        NSLog(@"send error.");
        return;
    }
	//NSString *from = [[message attributeForName:@"from"] stringValue];
    
    //Vanancy - setNotification for new chat
    int lastViewIndex =[[self.activeVC viewControllers] count] -1;
    if(![[[self.activeVC viewControllers]objectAtIndex:lastViewIndex] isKindOfClass:[SMChatViewController class]]){
        self.myProfile.unread_message++;
        [self updateNavigationWithNotification];
    }
    
	NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    // format message body
    msg = [msg formatForChatMessage];
    
	[m setObject:msg forKey:@"msg"];
    [m setObject:jid forKey:@"sender"];
    
    for (id<SMMessageDelegate> msgDelegate in self.messageDelegates)
    {
        [msgDelegate newMessageReceived:m];
    }
    
	if ([message isChatMessageWithBody])
	{
        [self showLocalNotification];
	}
}

-(void)sendPresence:(NSString*)jid withType:(NSString*)type
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"to" stringValue:jid];
    [presence addAttributeWithName:@"type" stringValue:type];
    [xmppStream sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    NSString* jid = [NSString stringWithFormat:@"%@@%@",[presence from].user, [presence from].domain];
    NSLog(@"---- didReceivePresence: %@ %@", jid, [presence name]);
    
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
    Profile* profile = [friendChatList objectForKey:jid];
    
    if( profile == nil)
        return;
    
    if( ![jid isEqualToString:[[xmppStream myJID] bare]])
    {
        NSLog(@"Presence type: %@", [presence type]);
        
        if([[presence type] isEqual: @"subscribe"])
        {
            [self sendPresence:jid withType:@"available"];
        }
        else
        if([[presence type] isEqual: @"available"])
        {
            [user setSectionNum:[NSNumber numberWithInt:0]];
            
            if(! profile.is_available )
            {
                [self sendPresence:jid withType:@"available"];
                profile.is_available = true;
            }
            
            NSLog(@"---- user go available: %@ %@", jid, [presence name]);
        }
        else
        {
            [user setSectionNum:[NSNumber numberWithInt:2]];
            
            NSLog(@"---- user go un-available: %@ %@", jid, [presence name]);
            
            profile.is_available = false;
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"didReceiveError: %@", error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}
//==============================================================
#pragma mark XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

#if ENABLE_DEMO
#pragma mark Multi Language
-(void)updateLanguageBundle{
    NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
    NSString *path= [[NSBundle mainBundle] pathForResource:selectedLanguage ofType:@"lproj"];
    self.languageBundle = [NSBundle bundleWithPath:path];
}

-(void)updateLanguageToServer{
    NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
    
    NSLog(@"updateLanguageToServer");
    //update to server
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:selectedLanguage, key_appLanguage, nil];
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_updateIOSLanguage parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         //         NSLog(@"dict: %@", dict);
         BOOL error = [[dict objectForKey:key_errorCode] boolValue];
         if (!error)
         {
         }
         else
         {
         }
     }failure:^(AFHTTPRequestOperation *op, NSError *err)
     {
     }];
    
    [operation start];
}

#endif

#pragma mark LOGIN
- (void)tryLoginWithSuccess:(void(^)(int status))success failure:(void(^)(void))failure
{
    [self openSessionWithhandler:^(FBSessionState status)
     {
         if(status == FBSessionStateOpen)
         {
             [self loadFBUserInfo:^(id status)
              {
                  NSLog(@"FB Login request completed!");
                  // clear image cache
                  self.imagePool = [[ImagePool alloc] init];
                  
                  [self startPingTimer];
                  
                  AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
                  NSLog(@"Init API completed");
                  
                  [self parseFBInfoToProfile:self.myFBProfile];
                  
                  NSString *access_token = [FBSession activeSession].accessTokenData.accessToken;
                  NSString *user_id = self.myProfile.s_FB_id;
                  NSString *osVersion = [UIDevice currentDevice].systemVersion;
                  NSString *deviceName = [UIDevice currentDevice].model;
                  NSString *deviceToken = self.s_DeviceToken;
                  NSString *platform = IOS_PLATFORM;
#if DAN_CHEAT
                  NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys: DAN_ACCESSTOKEN, @"access_token", DAN_FACEBOOKID, @"user_id", platform, key_platform, nil];
#else
                  NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                 access_token, @"access_token",
                                                 user_id, @"user_id",
                                                 platform, key_platform,
                                                 nil];
#endif
                  
                  if (deviceName && ![@"" isEqualToString:deviceName])
                  {
                      [params setObject:deviceName forKey:key_DeviceName];
                  }
                  if (osVersion && ![@"" isEqualToString:osVersion])
                  {
                      [params setObject:osVersion forKey:key_OSVersion];
                  }
                  if (deviceToken && ![@"" isEqualToString:deviceToken])
                  {
                      [params setObject:deviceToken forKey:key_DeviceToken];
                  }
                  
                  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                  if (appVersion && ![@"" isEqualToString:appVersion])
                  {
                      [params setObject:appVersion forKey:key_appVersion];
                  }
                  
                  NSLog(@"sendRegister-params: %@", params);
                  [request getPath:URL_sendRegister parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
                   {
                       NSError *e=nil;
                       NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
                       
                       NSLog(@"Login parsed data: %@", dict);
                       NSLog(@"Login string data: %@", [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding]);
                       
                       
                       if (!e && dict)
                       {
                           int status = [[dict valueForKey:key_errorStatus] integerValue];
                           NSDictionary *data = [dict objectForKey:key_data];
                           
                        #if ENABLE_CHECK_APP_VERSION
                           
                           NSString *requiredIOSAppVersion = [data objectForKey:@"required_iOS_app_version"];
                           if (![self checkAppVersion:requiredIOSAppVersion]) {
                               failure();
                               
                               return;
                           }
                           
                        #endif
                           
                           switch (status) {
                               case 0:
                               case 2:
                               case -1:
                               {
                                   [self loadDataForList:^(NSError *e) {
                                       if (!e)
                                       {
                                           [self parseProfileWithData:data];
                                           [self popSnapshotQueue];
                                           
                                           if (success)
                                           {
                                               success(status);
                                           }
                                       }
                                       else if (failure)
                                       {
                                           failure();
                                       }
                                   }];
                               }
                                   break;
                               default:
                                   if (failure)
                                   {
                                       failure();
                                   }
                                   break;
                           }
                       }
                       else if (failure)
                       {
                           failure();
                       }
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                   {
                       if (error.code == kCFURLErrorTimedOut) {
                           [self showErrorSlowConnection:@"sendRegister timeout"];
                       }
                       
                       NSLog(@"Send reg error Code: %i - %@",[error code], [error localizedDescription]);
                       if (failure)
                       {
                           failure();
                       }
                   }];
              }];
         }
         else
         {
             NSLog(@"Try open session in login error %u", status);
             if (failure)
             {
                 failure();
             }
         }
     }];
}

- (BOOL)checkAppVersion:(NSString *)requiredVersion
{
    if (requiredVersion == nil) {
        return YES;
    }
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NEVersionCompare *requiredVersionCompare = [[NEVersionCompare alloc] initWithFullTextVersion:requiredVersion];
    NEVersionCompare *currentVersionCompare = [[NEVersionCompare alloc] initWithFullTextVersion:version];
    
    BOOL isUpdate = !([currentVersionCompare compareWith:requiredVersionCompare] == NEVersionGreaterThan || [currentVersionCompare compareWith:requiredVersionCompare] == NEVersionEquivalent);
    if(isUpdate){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"Update" localize]
                                                            message:@"OakClub detects new version in AppStore! Please update OakClub app"
                                                           delegate:nil
                                                  cancelButtonTitle:[@"Cancel" localize]
                                                  otherButtonTitles:[@"Update" localize], nil];
        alertView.delegate = self;
        [alertView show];
        return NO;
    }

    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {// go to appstore
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:APPSTORE_LINK]];
    }
}


#pragma mark POP-Snapshot QUEUE
-(void)popSnapshotQueue{
    NSMutableDictionary* queueDict = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:key_snapshotQueue]] ;
    NSMutableArray *queue = [[NSMutableArray alloc]initWithArray:[queueDict objectForKey:self.myProfile.s_ID]];
    
    // Vanancy - DEBUG - format for params
//    NSArray *queueTest=@[@{@"profile_id":@"1m00ujci9g",@"is_like":@"0"},@{@"profile_id":@"1lxvpek4v2",@"is_like":@"1"},@{@"profile_id":@"dsc3jk",@"is_like":@"0"}];
    
//    [queueDict setObject:queueTest forKey:self.myProfile.s_ID];
//    [[NSUserDefaults standardUserDefaults] setObject:queueDict forKey:key_snapshotQueue];
    if(queue && [queue count]>0){
        AFHTTPClient* request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
        NSDictionary* params = [[NSDictionary alloc]initWithObjectsAndKeys:queue,@"list_like", nil];
        [request setParameterEncoding:AFFormURLParameterEncoding];
        [request postPath:URL_setListLikedSnapshot parameters:params success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"URL_setListLikedSnapshot - post success : %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [queue removeAllObjects];
            [queueDict setObject:queue forKey:self.myProfile.s_ID];
            [[NSUserDefaults standardUserDefaults] setObject:queueDict forKey:key_snapshotQueue];
             [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"URL_setListLikedSnapshot - Error Code: %i - %@",[error code], [error localizedDescription]);
        }];
    }
}
#pragma mark ping timer
-(void)startPingTimer
{
    if (!pingTimer)
    {
        pingTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(pingToServer:) userInfo:nil repeats:YES];
        [self pingToServer:pingTimer];
    }
}

-(void)pingToServer:(id)timer
{
    if (self.myFBProfile)
    {
        AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
        
        [request getPath:URL_ping parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Ping to server completed");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Cannot ping to server with error %@", [error localizedDescription]);
        }];
    }
}

-(void)stopPingTimer
{
    if (pingTimer)
    {
        [pingTimer invalidate];
        pingTimer = nil;
    }
}

#pragma mark check language
-(void)tryGetLanguageFromDevice
{
    BOOL isSetLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:key_ChosenLanguage] boolValue];
    NSDictionary *appLanguage = AppLanguageList;
    if (!isSetLanguage)
    {
        for (int i = 0; i < appLanguage.count; i++)
        {
            NSString *langID = [[appLanguage  allKeys] objectAtIndex:i];
            if ([[self checkLanguage] isEqualToString: langID])
            {
                [[NSUserDefaults standardUserDefaults] setObject:langID forKey:key_appLanguage];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString* str=[self.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
                NSLog(@"%@ %@",[appLanguage valueForKey:langID], str);
                break;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_EN forKey:key_appLanguage];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString* str=[self.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
                NSLog(@"English %@",str);
            }
        }
        
        //[self.view localizeAllViews];
    }
    
    [self updateLanguageBundle];
}

-(NSString* ) checkLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Language machine: %@", preferredLang);
    return preferredLang;
}

- (void)showErrorSlowConnection:(NSString *)problem
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"Error" localize]
                                                        message:[@"OakClub detects slow connection to server. Please try again later" localize]
                                                       delegate:nil
                                              cancelButtonTitle:[@"Ok" localize]
                                              otherButtonTitles:nil];
    [alertView show];
    
    [self reportIOSProblemToOakClub:problem];
}

- (void)showErrorData
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"Error" localize]
                                                        message:[NSString stringWithFormat:@"%@%@", [@"Error" localize], @"Please try again later"]
                                                       delegate:nil
                                              cancelButtonTitle:[@"Ok" localize]
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)reportIOSProblemToOakClub:(NSString *)problem
{
    
    NSDictionary *params;
    
    if (self.myFBProfile && [self.myFBProfile objectForKey:@"id"] && [self.myFBProfile objectForKey:@"name"]) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                    problem, @"problem",
                    [self.myFBProfile objectForKey:@"id"], @"fb_id",
                    [self.myFBProfile objectForKey:@"name"], @"name",
                    [NSDate date], @"date",
                    [UIDevice currentDevice].name, @"device_name",
                    [UIDevice currentDevice].model, @"device_model",
                    [UIDevice currentDevice].systemVersion, @"device_version",
                    nil];
    }
    
    NSLog(@"reportProblemToOakClub %@",params);
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    
    [request postPath:URL_reportIOSProblemToOakClub parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}

@end
