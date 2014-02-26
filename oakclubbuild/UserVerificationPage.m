//
//  UserVerificationPage.m
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UserVerificationPage.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"
#import "menuViewController.h"

#define kOakClub_Name @"OakClub_Name"

@interface UserVerificationPage ()
{
    AppDelegate *appDel;
}


@end

@implementation UserVerificationPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDel = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.isForceVerify) {
        [self.view addSubview:self.forceVerifyView];
    } else {
        [self.view addSubview:self.normalVerifyView];
    }
    
    [self.view addSubview:self.failedPopupView];
    [self.view addSubview:self.successPopupView];

    [self loadWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.successPopupView.hidden = YES;
    self.failedPopupView.hidden = YES;

    [self loadWebView];
    [self.navigationController.view localizeAllViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:NSStringFromClass([self class])
                           forKey:kGAIScreenName] build]];
}

- (void)loadWebView {
    NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];

    NSString *html;
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"normalVerify_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
    [self.normalVerifyWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"forceVerify_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:kOakClub_Name withString:appDel.myProfile.firstName];
    [self.forceVerifyWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"failedpopup_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
    [self.failedPopupWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"successpopup_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
    [self.successPopupWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postFacebook {
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        [FBSession.activeSession
         requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // re-call assuming we now have the permission
                 [self publishStory];
             }
         }];
    } else {
        [self publishStory];
    }

}

- (void)publishStory
{
    UIImage *image = [UIImage imageNamed:@"Default-image_share"];
    
    NSString *message = [NSString stringWithFormat:@"%@", [@"I have just joined OakClub – a great app to connect to cool people around you. Check it out!" localize]];
    
    NSString *shareURL = @"http://oakclub.com";
    
    NSString *name = [@"I Got Verified!" localize];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   name, @"name",
                                   message, @"description",
                                   shareURL, @"link",
                                   @"http://oakclub.com/bundles/likevnblissdate/v3/images/logo.png", @"picture",
                                   nil];
    
    if ([FBNativeDialogs canPresentShareDialogWithSession:nil]) {
        [FBNativeDialogs presentShareDialogModallyFrom:self initialText:message image:image url:[NSURL URLWithString:shareURL]
                                               handler:^(FBNativeDialogResult result, NSError *error) {
                                                   if (error) {
                                                       self.successPopupView.hidden = YES;
                                                       self.failedPopupView.hidden = NO;
                                                   } else {
                                                       if (result == FBNativeDialogResultSucceeded) {
                                                           
                                                           [self verificationDidShared];
                                                           
                                                       } else {
                                                           self.successPopupView.hidden = YES;
                                                           self.failedPopupView.hidden = NO;
                                                       }
                                                   }
                                                   
                                               }];
    
    } else {
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          self.successPopupView.hidden = YES;
                                                          self.failedPopupView.hidden = NO;
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              self.successPopupView.hidden = YES;
                                                              self.failedPopupView.hidden = NO;
                                                          } else {
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User clicked the Cancel button
                                                                  NSLog(@"User canceled story publishing.");
                                                                  self.successPopupView.hidden = YES;
                                                                  self.failedPopupView.hidden = NO;
                                                              } else {
                                                                  // User clicked the Share button
                                                                  [self verificationDidShared];
                                                                  
                                                              }
                                                              
                                                          }
                                                      }
                                                  }];
        
    }
    
    
}

- (void)verificationDidShared {
    self.successPopupView.hidden = NO;
    self.failedPopupView.hidden = YES;
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"GET" path:URL_verifyUser parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL error = [[dict objectForKey:key_errorCode] boolValue];
        
        if (error)
        {
            self.successPopupView.hidden = YES;
            self.failedPopupView.hidden = NO;
        }
        else
        {
            self.successPopupView.hidden = NO;
            self.failedPopupView.hidden = YES;
            
            appDel.myProfile.isVerified = YES;
            
            UIViewController *leftViewController = [appDel.rootVC leftViewController];
            if ([leftViewController isKindOfClass:[menuViewController class]]) {
                menuViewController *menu = (menuViewController *)leftViewController;
                [menu refreshMenu];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.successPopupView.hidden = YES;
        self.failedPopupView.hidden = NO;
    }];
    
    [operation start];
    
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (void)skipVerification {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isSkipButtonPressed"];

    if (self.isPopOver) {
        menuViewController *leftController = [[menuViewController alloc] init];
        [leftController setUIInfo:appDel.myProfile];
        [appDel.rootVC setRightViewController:appDel.chat];
        [appDel.rootVC setLeftViewController:leftController];
        appDel.window.rootViewController = appDel.rootVC;
    } else {
        [appDel  showSimpleSnapshotThenFocus:YES];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"%@: shouldStartLoadWithRequest = %@, navigationType = %d", [self class], [request URL], navigationType);
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        NSString *key = [[request URL] description];
        
        if ([key rangeOfString:@"hihioakclub:///continue"].location != NSNotFound){
            [self postFacebook];
        }
        
        if ([key rangeOfString:@"hihioakclub:///skip"].location != NSNotFound){
            [self skipVerification];
        }
        
        if ([key rangeOfString:@"hihioakclub:///hidepopup"].location != NSNotFound){
            self.successPopupView.hidden = YES;
            self.failedPopupView.hidden = YES;
        }
        
        return NO;
    }
    
    return YES;
}


@end
