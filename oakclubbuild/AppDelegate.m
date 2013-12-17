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
NSString *const SCSessionStateChangedNotification =
@"com.facebook.Scrumptious:SCSessionStateChangedNotification";
@interface AppDelegate()

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
@synthesize _messageDelegate;
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
@synthesize loginButton;
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

@synthesize appLCObservers;
@synthesize imagePool;
@synthesize snapshotSettingsObj;
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
    self.appLCObservers = [[NSMutableArray alloc] init];
    self.imagePool = [[ImagePool alloc] init];
    self.snapshotSettingsObj = [[SettingObject alloc] init];
    _messageDelegate = nil;
   
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
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
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
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstLogin"] boolValue])
    {
        
//        //test
//        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isFirstLogin"];
//        TutorialViewController *tut = [[TutorialViewController alloc] init];
//        self.window.rootViewController = tut;
//        [self.window makeKeyAndVisible];
        
        
        menuViewController *leftController = [[menuViewController alloc] init];
        [leftController setUIInfo:self.myProfile];
        [self.rootVC setRightViewController:self.chat];
        [self.rootVC setLeftViewController:leftController];
        self.window.rootViewController = self.rootVC;
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isFirstLogin"];
        
        TutorialViewController *tut = [[TutorialViewController alloc] init];
        self.window.rootViewController = tut;
        [self.window makeKeyAndVisible];
    }
}

-(void)loadAllViewControllers{
    self.chat = [self createNavigationByClass:@"VCChat" AndHeaderName:@"Chat History" andRightButton:nil andIsStoryBoard:NO];

    self.simpleSnapShot = [self createNavigationByClass:@"VCSimpleSnapshot" AndHeaderName:nil/*[NSString localizeString:@"Snapshot"]*/ andRightButton:@"VCChat" andIsStoryBoard:NO];
    //     self.snapShotSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"SnapshotSettings"];
    self.snapShotSettings = [self createNavigationByClass:@"VCSimpleSnapshotSetting" AndHeaderName:[NSString localizeString:@"Settings"] andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.snapshotLoading = [self createNavigationByClass:@"VCSimpleSnapshotLoading" AndHeaderName:nil andRightButton:@"VCChat" andIsStoryBoard:NO];
    self.myProfileVC = [self createNavigationByClass:@"VCMyProfile" AndHeaderName:[NSString localizeString:@"Edit Profile"] andRightButton:@"VCChat" andIsStoryBoard:NO];
//    self.getPoints = [self createNavigationByClass:@"VCGetPoints" AndHeaderName:@"Get Coins" andRightButton:nil andIsStoryBoard:NO];
    self.confirmVC = [self createNavigationByClass:@"UpdateProfileViewController" AndHeaderName:[@"Update Profile" localize] andRightButton:nil andIsStoryBoard:NO];
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
	// This method is invoked when the app is running and a push notification
	// is received. If the app was suspended in the background, it is woken up
	// and this method is invoked as well. We add the new message to the data
	// model and add it to the ChatViewController's table view.
    
	NSLog(@"Received notification: %@", userInfo);
    
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
	// Create a new Message object
    
	// The JSON payload is already converted into an NSDictionary for us.
	// We are interested in the contents of the alert message.
    //NSDictionary *dict = [userInfo valueForKey:@"aps"] ;
	//NSString* alertValue = [dict valueForKey:@"alert"];
    //NSString* type = [dict valueForKey:@"type"];
    
    if (updateUI)
    {
//        [self showChat];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //Vanancy - check for sure internet connection always work in app
    [self checkInternetConnection];
    
    [FBSession.activeSession handleDidBecomeActive];
    
    for (id<AppLifeCycleDelegate> appLCDel in self.appLCObservers)
    {
        [appLCDel applicationDidBecomeActive:application];
    }
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
//    [self.rootVC setRootController:self.chat animated:YES];
//    [self.rootVC setContentViewController:self.chat snapToContentViewController:YES animated:YES];
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
    //    [self.rootVC setRootController:self.snapShoot animated:YES];
    //    [self.rootVC setContentViewController:self.snapShoot snapToContentViewController:YES animated:YES];
    activeVC = _snapShotSettings;
    AppDelegate *appDel = self;
    [self.rootVC setFrontViewController:self.snapShotSettings focusAfterChange:YES completion:^(BOOL finished) {
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
            selfCopy.reloadSnapshot = FALSE;
        }
        return;
    }
    activeVC = _simpleSnapShot;
    PKRevealControllerState state =  self.rootVC.state;
//    UIViewController* vchat = [self.chat.viewControllers objectAtIndex:0]; //DEBUG
    if(state == PKRevealControllerFocusesRightViewController && [[self.chat viewControllers] count] > 1){
        return;
    }
    
    [self.rootVC setFrontViewController:self.simpleSnapShot focusAfterChange:focus completion:^(BOOL finished) {
        //load profile list if needed
        if(selfCopy.reloadSnapshot){
            [VCSSnapshot refreshSnapshotFocus:focus];
            selfCopy.reloadSnapshot = FALSE;
        }
        if(!focus && selfCopy.rootVC.state != PKRevealControllerFocusesFrontViewController){
            [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:NO];
        }
        else{
            [selfCopy.rootVC.frontViewController.view setUserInteractionEnabled:YES];
        }
    }];
}
-(void)showSimpleSnapshot{
    AppDelegate *selfCopy = self;   // copy for retain cycle
    activeVC = _simpleSnapShot;
    [self.rootVC setFrontViewController:self.simpleSnapShot focusAfterChange:NO completion:^(BOOL finished) {
        
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
            
//            [self.loginView dismissModalViewControllerAnimated:YES];
//            self.loginView = nil;
//            
//            [FBRequestConnection startForMeWithCompletionHandler:
//             ^(FBRequestConnection *connection, id result, NSError *error)
//             {
//                 self.myFBProfile = (id<FBGraphUser>)result;
//                 NSLog(@"%@",[result objectForKey:@"gender"]);
//                 NSLog(@"%@",[result objectForKey:@"gender"]);
//                 NSLog(@"%@",[result objectForKey:@"relationship_status"]);
//                 NSLog(@"%@",[result objectForKey:@"about"]);
//#if ENABLE_DEMO
//                 [self  getProfileInfo];
//#else
//                 UIStoryboard *registerStoryboard = [UIStoryboard
//                                                     storyboardWithName:@"RegisterConfirmation"
//                                                     bundle:nil];
//                 UIViewController *registerViewConroller = [registerStoryboard
//                                                            instantiateInitialViewController];
//                 self.window.rootViewController = registerViewConroller;
//#endif
//             }];
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
    [self.myProfile parseProfileWithData:data withFullName:YES];
    [self.myProfile getRosterListIDSync:^{
        if (self.chat)
        {
            VCChat *vcChat = self.chat.viewControllers[0];
            [vcChat loadFriendsInfo];
        }
    }];
    [self.imagePool getImageAtURL:self.myProfile.s_Avatar withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        
    }];
    [self.imagePool getImageAtURL:self.myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        
    }];
    [self setFieldValue:[NSString stringWithFormat:DOMAIN_AT_FMT,self.myProfile.s_usenameXMPP] forKey:kXMPPmyJID];
    [self setFieldValue:self.myProfile.s_passwordXMPP forKey:kXMPPmyPassword];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup the XMPP stream
    [self setupStream];
    [self connect];
    
    [self loadAllViewControllers];
}
/*
 // Vanancy - unused
- (void)updateProfile
{
    AFHTTPClient *requestHangout = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    [requestHangout getPath:URL_getProfileInfo parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         //self.myProfile = [[Profile alloc]init];
         [self.myProfile parseForGetHangOutProfile:JSON];
         [self setFieldValue:[NSString stringWithFormat:DOMAIN_AT_FMT,self.myProfile.s_usenameXMPP] forKey:kXMPPmyJID];
         [self setFieldValue:self.myProfile.s_passwordXMPP forKey:kXMPPmyPassword];
         // Configure logging framework
         
         [DDLog addLogger:[DDTTYLogger sharedInstance]];
         
         // Setup the XMPP stream
         [self setupStream];
         [self connect];

         AFHTTPClient *requestPhoto = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
         NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:self.myProfile.s_ID, key_profileID, nil];
         self.myProfile.arr_photos = [[NSMutableArray alloc] init];
         [requestPhoto getPath:URL_getListPhotos parameters:params
                       success:^(__unused AFHTTPRequestOperation *operation, id JSON)
          {
              self.myProfile.arr_photos = [Profile parseListPhotos:JSON];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
          }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"URL_getProfileInfo Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
    
}

- (void) updateChatList{
    NSMutableArray *_arrRoster = [[NSMutableArray alloc] init];
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getListChat parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict_ListChat = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        //        NSMutableDictionary * data= [dict valueForKey:key_data];
        
        self.myProfile.unread_message = 0;
        NSMutableArray* rosterList = [dict_ListChat valueForKey:key_data];
        
        for (int i = 0; rosterList!=nil && i < [rosterList count]; i++) {
            NSMutableDictionary *objectData = [rosterList objectAtIndex:i];
            
            if(objectData != nil)
            {
                NSString* profile_id = [objectData valueForKey:key_profileID];
                bool deleted = [[objectData valueForKey:@"is_deleted"] boolValue];
                bool blocked = [[objectData valueForKey:@"is_blocked"] boolValue];
                //bool deleted_by = [[objectData valueForKey:@"is_deleted_by_user"] boolValue];
                bool blocked_by = [[objectData valueForKey:@"is_blocked_by_user"] boolValue];
                // vanancyLuu : cheat for crash
                if(!deleted && !blocked && !blocked_by )
                {
                    [_arrRoster addObject:profile_id];
                    
                    int unread_count = [[objectData valueForKey:@"unread_count"] intValue];
                    
                    NSLog(@"%d. unread message: %d", i, unread_count);
                    
                    self.myProfile.unread_message += unread_count;
                }
            }
        }
        
        NSLog(@"unread message: %d", self.myProfile.unread_message);
        
        self.myProfile.a_RosterList = [NSArray arrayWithArray:_arrRoster];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@", [error code], [error localizedDescription]);
    }];
}
*/
- (void)openSession
{
    NSArray *permission = [[NSArray alloc] initWithObjects:@"email",@"user_birthday",@"user_location",nil];
    [FBSession openActiveSessionWithReadPermissions:permission
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
    
//    NSArray *permissions =[NSArray arrayWithObjects:@"email",@"user_birthday",@"user_location",@"user_photos", @"friends_photos", nil];
//    
//    [[FBSession activeSession] reauthorizeWithReadPermissions:permissions
//                                            completionHandler:^(FBSession *session, NSError *error) {
//                                                /* handle success + failure in block */
//                                                NSDictionary* params = [NSDictionary dictionaryWithObject:@"id,name,gender,relationship_status,about,location,interested_in,birthday,email" forKey:@"fields"];
//                                                [FBRequestConnection startWithGraphPath:@"me" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                    NSLog(@"USER INFO _ %@",result);
//                                                }];
//                                            }];
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
        NSLog(@"USER INFO _ error : %@",error);
        if(result == NULL)
            return;
        NSLog(@"USER INFO _ %@",result);
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
            ///NSLog(@"%d.1 Remove user: %s for user_id: %s", i, friend.s_Name.UTF8String, xmpp_id.UTF8String);
        }
        else
        {
            [xmppRoster addUser:jid withNickname:friend.s_Name];
            //[xmppRoster setNickname:friend.s_Name forUser:jid];
            NSLog(@"%d.2 Set nick name: %s for user_id: %s", i, friend.s_Name.UTF8String, xmpp_id.UTF8String);
            
            // cache avatar
            [imagePool getImageAtURL:friend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
                
            }];
        }
/*
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:profile.s_ID , key_profileID, nil];
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                                path:URL_getProfileInfo
                                                          parameters:params];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError *e=nil;
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&e];
            
            NSMutableDictionary * data= [dict valueForKey:key_data];
            
            NSString* profile_id = [data valueForKey:key_profileID];
            
            NSString* xmpp_id = [NSString stringWithFormat:@"%@%@", profile_id, DOMAIN_AT];
            
            Profile* friend = [friendChatList objectForKey:xmpp_id];
            
            [friend parseProfileWithDictionary:data];
            
            
            if(friend.s_Name == nil || [friend.s_Name isEqualToString:@""] || [friend.s_ID isEqualToString:self.myProfile.s_ID])
            {
                //[xmppRoster removeUser:jid];
                ///NSLog(@"%d.1 Remove user: %s for user_id: %s", i, friend.s_Name.UTF8String, xmpp_id.UTF8String);
                
            }
            else
            {
                [xmppRoster addUser:jid withNickname:friend.s_Name];
                //[xmppRoster setNickname:friend.s_Name forUser:jid];
                NSLog(@"%d.2 Set nick name: %s for user_id: %s", i, friend.s_Name.UTF8String, xmpp_id.UTF8String);
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Get friend hangout profile error: %@", error);
        }];
        
        
        
        //[operation start];
        [queue addOperation:operation];
*/
        
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

    [self loadFriendsList ];
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
            [imagePool getImageAtURL:newFriend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
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
	[m setObject:msg forKey:@"msg"];
	//[m setObject:from forKey:@"sender"];
    [m setObject:jid forKey:@"sender"];
    
	//vanancy update info of list chat in Chat history view
    
    
    if(_messageDelegate != nil)
        [_messageDelegate newMessageReceived:m];
    //    else
    //    {
    //        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
    //		                                                         xmppStream:xmppStream
    //		                                               managedObjectContext:[self managedObjectContext_roster]];
    //
    //		NSString *body = [[message elementForName:@"body"] stringValue];
    //		NSString *displayName = [user displayName];
    //
    //        [self showLocalNotification:displayName and:body];
    //    }
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        [self showLocalNotification];
        /*
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
            
            //             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
            //             message:body
            //             delegate:nil
            //             cancelButtonTitle:@"Ok"
            //             otherButtonTitles:nil];
            //             [alertView show];
            
		}
		else
		{
			[self showLocalNotification:displayName and:body];
		}
        */
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
//        else 
//        {
//            [user setSectionNum:[NSNumber numberWithInt:1]];
//        }
        

    }

    [[self.chat.viewControllers objectAtIndex:0] reloadFriendList];

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
#endif

#pragma mark LOGIN
- (void)tryLoginWithSuccess:(void(^)(int status))success failure:(void(^)(void))failure
{
    [self openSessionWithWebDialogWithhandler:^(FBSessionState status)
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
                  
#if DAN_CHEAT
                  NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys: @"CAAHo9PiL7dwBABLVeIqWTGFwC5BPfjl8zq66SIufQLO39WhamZB76h2Ku5TmZB79f6SJnSXJK1j8ksVOYKJwZB9TT9dTiRXtYsn2kgnEOwZCNkdbitnDqHgZCul3Ez5LIzJeuofWWAFCZAAQBsUkzFCB7oZChE1uC7tZAdRvYJkY98SZAubpMrxjG", @"access_token",
                                                 @"511391007", @"user_id",
                                                 nil];
#else
                  NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                                 [FBSession activeSession].accessTokenData.accessToken, @"access_token",
                                                 self.myProfile.s_FB_id, @"user_id",
                                                 nil];
#endif
                  
                  if (self.s_DeviceToken && ![@"" isEqualToString:self.s_DeviceToken])
                  {
                      [params setObject:self.s_DeviceToken forKey:@"device_token"];
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
            NSLog(@"Ping to server completed with respond %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
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
    NSLog(@"Language: %@", preferredLang);
    return preferredLang;
}
@end
