//
//  SCLoginViewController.m
//  OakClub
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SCLoginViewController.h"
#import "AppDelegate.h"
#import "CycleScrollView.h"
#import "UAModelPanelEx.h"
#import "UIView+Localize.h"
#import "VCPrivacy.h"
#import "TutorialViewController.h"

@interface SCLoginViewController (){
    AppDelegate* appDelegate;
    
    NSArray *descText;
}
- (IBAction)performLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation SCLoginViewController
@synthesize spinner,btnLogin,pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    NSString* language = [[NSUserDefaults standardUserDefaults] objectForKey:key_language];
//    NSString* path= [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
//    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (id) [UIApplication sharedApplication].delegate;
    }

    return self;
}

//-(void)viewDidLayoutSubviews{
//    [self.view setFrame:CGRectMake(0, 0, 320, 480)];
//    CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
//    self.view.center = CGPointMake(screenBounds.size.width/2 + screenBounds.origin.x,screenBounds.size.height/2 + screenBounds.origin.y);
//    
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showMenuLanguage];
    
    descText = [[NSArray alloc] initWithObjects:
                @"Anonymouly \"like\" or \"pass\" on people OakClub suggests",
                @"Chat with your matches inside the app",
                @"if someone you've liked happen to like you as well …",
                nil];
    
    // Do any additional setup after loading the view from its nib.
    NSArray* pageImages = [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"intropage_snap.png"],
                  [UIImage imageNamed:@"intropage_chat.png"],
                  [UIImage imageNamed:@"intropage_match.png"],
                  nil];
    CycleScrollView *cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
                                                     cycleDirection:CycleDirectionLandscape
                                                           pictures:pageImages];
    
    cycle.delegate = self;
    [cycle refreshScrollView];
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    
    //init for pageControl
    pageControl.numberOfPages = pageImages.count;
    pageControl.currentPage = 0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view localizeAllViews];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startSpinner{
    [self.spinner startAnimating];
    [btnLogin setEnabled:NO];
    self.btnInfo.enabled = NO;
}
- (void)stopSpinner{
    [self.spinner stopAnimating];
    [btnLogin setEnabled:YES];
    self.btnInfo.enabled = YES;
}

- (IBAction)performLogin:(id)sender
{
    if(btnLogin.selected)
        return;
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen)
    {
        [self startSpinner];
        [self tryLogin];
    }
    else
    {
        UAModalPanel *popup = [[VCPrivacy alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andLoginPage:self];
        [self.view addSubview:popup];
        
        [popup showFromPoint:[self.view center]];
    }
}

- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self stopSpinner];
}

- (void)viewDidUnload {
    [self setBtnLogin:nil];
    [super viewDidUnload];
}

#pragma mark delegate for CyclescrollView
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index{
    pageControl.currentPage = index-1;
}

- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView customizeImageView:(TapDetectingImageView *)imageView atIndex:(int)index
{
    NSLog(@"Customize cycle view at index: %d", index);
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:FONT_HELVETICANEUE_LIGHT(16)];//[UIFont systemFontOfSize:16]];
    [lbl setTextColor:[UIColor darkTextColor]];
    [lbl setShadowColor:[UIColor lightTextColor]];
    [lbl setLineBreakMode:NSLineBreakByWordWrapping];
    lbl.numberOfLines = 2;
    lbl.textAlignment = NSTextAlignmentCenter;
    [lbl setFrame:CGRectMake(0, 5, 240, 50)];
    [lbl setText:[descText objectAtIndex:index]];
    [lbl localizeAllViews];
    [lbl setFrame:CGRectMake((imageView.frame.size.width - lbl.frame.size.width) / 2, lbl.frame.origin.y, lbl.frame.size.width, lbl.frame.size.height)];
    
    [imageView addSubview:lbl];
}

#pragma mark Facebook Login
- (void) tryLogin
{
    [appDelegate openSessionWithWebDialogWithhandler:^(FBSessionState status)
    {
        if(status == FBSessionStateOpen)
        {
            [appDelegate loadFBUserInfo:^(id status)
             {
                 NSLog(@"FB Login request completed!");
                 
                 AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
                 NSLog(@"Init API completed");
                 
                 [appDelegate parseFBInfoToProfile:appDelegate.myFBProfile];
                 NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                                         [FBSession activeSession].accessTokenData.accessToken, @"access_token",
                                         appDelegate.myProfile.s_FB_id, @"user_id",
                                         nil];
                 NSLog(@"Params: %@", params);
                 [request getPath:URL_sendRegister parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
                  {
                      [self.view setUserInteractionEnabled:YES];
                      NSError *e=nil;
                      NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
                      
                      NSLog(@"Login parsed data: %@", dict);
                      NSLog(@"Login string data: %@", [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding]);
                      
                      int status = [[dict valueForKey:key_status] integerValue];
                      if (status == 0) {
                          NSString *msg = [dict valueForKey:@"msg"];
                          if ([msg isEqualToString:@"This user exists already."])   // string check !=,=
                          {
                              [appDelegate getProfileInfoWithHandler:^(void)
                               {
                                   [self stopSpinner];
                                   if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstLogin"] boolValue])
                                   {
                                       menuViewController *leftController = [[menuViewController alloc] init];
                                       [leftController setUIInfo:appDelegate.myProfile];
                                       [appDelegate.rootVC setRightViewController:appDelegate.chat];
                                       [appDelegate.rootVC setLeftViewController:leftController];
                                       appDelegate.window.rootViewController = appDelegate.rootVC;
                                   }
                                   else
                                   {
                                       [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isFirstLogin"];
                                       
                                       TutorialViewController *tut = [[TutorialViewController alloc] init];
                                       appDelegate.window.rootViewController = tut;
                                       [appDelegate.window makeKeyAndVisible];
                                   }
                               }];
                          }
                          else
                          {
                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:msg
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                              [alertView show];
                          }
                      }
                      else
                      {
                          NSLog(@"Goto profile comfirmation");
                          [appDelegate getProfileInfoWithHandler:^(void)
                          {
                              menuViewController *leftController = [[menuViewController alloc] init];
                              [leftController setUIInfo:appDelegate.myProfile];
                              [appDelegate.rootVC setRightViewController:appDelegate.chat];
                              [appDelegate.rootVC setLeftViewController:leftController];
                              appDelegate.window.rootViewController = appDelegate.rootVC;
                              [appDelegate showConfirm];
                          }];
                      }
                      
                      [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:key_ChosenLanguage];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      NSLog(@"Send reg error Code: %i - %@",[error code], [error localizedDescription]);
                  }];
             }];
        }
        else
        {
            NSLog(@"Try open session in login error %u", status);
        }
    }];
}

- (IBAction)showInfoPanel:(id)sender
{
    UAModalPanel *popup = [[UAModelPanelEx alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andLoginPage:self];
    [self.view addSubview:popup];
    
    [popup showFromPoint:[self.view center]];
}

#pragma mark Language
-(void) showMenuLanguage{
    BOOL isSetLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:key_ChosenLanguage] boolValue];
    if (!isSetLanguage)
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_VI forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString* language = [[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage];
    if(language != nil){
        [appDelegate updateLanguageBundle];
        [self.view localizeAllViews];
        [appDelegate loadAllViewControllers];
    }
    
    if (!isSetLanguage)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Welcome"
                              message:@""
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Vietnamese",@"English",nil];
        [alert show];
    }
    else
    {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen)
        {
            [self startSpinner];
            [self tryLogin];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Vietnamese"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_VI forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"Vietnamese %@",str);
    }
    else if([title isEqualToString:@"English"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_EN forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"English %@",str);
    }
    
    [self.view localizeAllViews];
    [appDelegate loadAllViewControllers];
}

#pragma mark Load TEXT for all control
-(void) localizeAllText{
    for(UIView* view in [self.view subviews]){
        [view localizeText];
    }
//    self.lblNote = (UILabel*)[NSString localizeStringByObject:self.lblNote];
//    NSString* loginText =[appDelegate.languageBundle localizedStringForKey:btnLogin.titleLabel.text value:@"" table:nil];
//    NSString* noteText =[appDelegate.languageBundle localizedStringForKey:self.lblNote.text value:@"" table:nil];
//    [btnLogin setTitle:loginText forState:UIControlStateNormal];
//    [self.lblNote setText:noteText];
}
@end
