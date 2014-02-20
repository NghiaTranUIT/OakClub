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
    
    [self loadWebView];
}

- (void)loadWebView {
    NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];

    NSString *html;
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"normalVerify_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
    [self.normalVerifyWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    html = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"forceVerify_%@.html", selectedLanguage] ofType:nil]] encoding:NSUTF8StringEncoding error:nil];
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
    
    NSString *message = [NSString stringWithFormat:@"%@", [@"I have just joined OakClub - a cool app to make new connections. Check it out!" localize]];
    
    NSString *shareURL = @"http://oakclub.com";
    
    [FBNativeDialogs presentShareDialogModallyFrom:self initialText:message image:image url:[NSURL URLWithString:shareURL]
                                           handler:^(FBNativeDialogResult result, NSError *error) {
                                               if (error) {
                                                   self.successPopupView.hidden = YES;
                                                   self.failedPopupView.hidden = NO;
                                               } else {
                                                   if (result == FBNativeDialogResultSucceeded) {
                                                       
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
                                                               self.successPopupView.hidden = NO;
                                                               self.failedPopupView.hidden = YES;
                                                           {
                                                           }
                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           self.successPopupView.hidden = YES;
                                                           self.failedPopupView.hidden = NO;
                                                       }];
                                                       
                                                       [operation start];
                                                       
                                                       
                                                       
                                                   } else {
                                                       self.successPopupView.hidden = YES;
                                                       self.failedPopupView.hidden = NO;
                                                   }
                                               }
                                               
                                           }];
    
}


- (void)skipVerification {
    if (self.isFirstLogin || self.isForceVerify) {
        TutorialViewController *tut = [[TutorialViewController alloc] init];
        appDel.window.rootViewController = tut;
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
