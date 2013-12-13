//
//  AppDelegate.h
//  oakclubbuild
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SCLoginViewController.h"
//#import "DDMenuController.h"
#import "menuViewController.h"

#import "VCChat.h"
#import "VCMyProfile.h"
#import "NavConOakClub.h"
#import "NavBarOakClub.h"
#import "VCHangoutSetting.h" // for test
#import "FlashIntro.h"
// ==== chatting
#import "UpdateProfileViewController.h"
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
#import "SMMessageDelegate.h"

//#import "MTStackViewController.h"
#import "PKRevealController.h"
#import "Reachability.h"
#import "ProfileSetting.h"
#import "TutorialViewController.h"
#import "ImagePool.h"

@class SettingsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPRosterDelegate>{
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	
	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
	
	UIWindow *window;
	UINavigationController *navigationController;
    SettingsViewController *loginViewController;
    UIBarButtonItem *loginButton;
    
    __unsafe_unretained NSObject <SMMessageDelegate> *_messageDelegate;
    
    //requests
    NSMutableDictionary *friendChatList;
    
    ProfileSetting* _accountSetting;
}
// methods for chatting
@property (nonatomic, assign) id  _messageDelegate;
@property(strong, nonatomic) NSMutableDictionary *friendChatList;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

//@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;
// end chatting

@property (strong, nonatomic) ProfileSetting* accountSetting;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<FBGraphUser> myFBProfile;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) Profile *myProfile;
@property (strong, nonatomic) NSString* s_DeviceToken;

extern NSString *const SCSessionStateChangedNotification;

@property (strong, nonatomic) UINavigationController *activeVC;
@property (strong, nonatomic) UINavigationController *chat;
#if ENABLE_DEMO
@property (strong, nonatomic) UINavigationController *snapShotSettings;
@property (strong, nonatomic) UINavigationController *simpleSnapShot;
@property (strong, nonatomic) UINavigationController *snapshotLoading;
//multi Language
@property (strong, nonatomic) NSBundle *languageBundle;

#endif

@property (strong, nonatomic) UINavigationController *myProfileVC;
//@property (strong, nonatomic) UINavigationController *getPoints;
@property (strong, nonatomic) PKRevealController *rootVC;
@property (strong, nonatomic) SCLoginViewController *loginView;
@property (strong, nonatomic) UINavigationController *confirmVC;
@property (strong, nonatomic) FlashIntro *flashIntro;

@property (strong, nonatomic) NSArray *countryList;
@property (strong, nonatomic) NSMutableDictionary *cityList;
@property (strong, nonatomic) NSArray *ethnicityList;
@property (strong, nonatomic) NSArray *workList;
@property (strong, nonatomic) NSArray *languageList;
@property (strong, nonatomic) NSArray *relationshipList;
@property (strong, nonatomic) NSArray *genderList;
@property (strong, nonatomic) NSArray *likedMeList;

@property BOOL reloadSnapshot;

@property (strong, nonatomic) NSMutableArray *appLCObservers;

@property (strong, nonatomic) ImagePool *imagePool;
@property (strong, nonatomic) SettingObject *snapshotSettingsObj;

-(void)openSession;
-(void)openSessionWithWebDialogWithhandler:(void(^)(FBSessionState))resultHandler;
-(void)loadFBUserInfo:(void(^)(id))resultHandler;
-(void)parseFBInfoToProfile:(id)fbProfile;
-(BOOL)isFacebookActivated;

-(void)loadAllViewControllers;
//-(void)loadDataForList;
-(void)loadDataForList:(void(^)(NSError *e))completion;
-(void)showChat;
//-(void)showSnapshoot;
-(void)gotoLogin;
-(void)gotoVCAtCompleteLogin;
#if ENABLE_DEMO
-(void)showSnapshotSettings;
-(void)showSimpleSnapshotThenFocus:(BOOL)focus;
-(void)showSnapshotLoadingThenFocus:(BOOL)focus;
-(void)updateLanguageBundle;
#endif
//-(void)showMylink;
//-(void)showVisitor;
-(void)showLeftView;
-(void)logOut;
//-(void)showHangOut;
-(void)showMyProfile;
-(void)showConfirm;
-(void)showInvite;
//-(void)showGetPoints;
//-(NavConOakClub *) createNavigationByClass:(NSString *)className;
-(BOOL)checkInternetConnection;
-(void)loadFriendsList;
-(BOOL)isAuthenticated;
-(int)countTotalNotifications;
-(UINavigationController*)activeViewController;

-(void)sendMessageState:(NSString*)state to:(NSString*)xmpp_id;
-(void)sendMessageContent:(NSString*)content to:(NSString*)xmpp_id;

-(void)updateNavigationWithNotification;

- (void)tryLoginWithSuccess:(void(^)(int status))success failure:(void(^)(void))failure;
@end
