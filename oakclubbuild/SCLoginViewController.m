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

@interface SCLoginViewController (){
    AppDelegate* appDelegate;
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
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray* pageImages = [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"first-screen"],
                  [UIImage imageNamed:@"second-screen"],
                  [UIImage imageNamed:@"third-screen"],
                  nil];
    CycleScrollView *cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 455)
                                                     cycleDirection:CycleDirectionLandscape
                                                           pictures:pageImages];
    cycle.delegate = self;
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    
    //init for pageControl
    pageControl.numberOfPages = pageImages.count;
    pageControl.currentPage = 0;
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen)
    {
        [self startSpinner];
        [self tryLogin];
    }
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
    [self startSpinner];
    [self tryLogin];
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

#pragma mark Facebook Login
- (void) tryLogin
{
    [appDelegate openSessionWithWebDialogWithhandler:^(FBSessionState status)
    {
        if(status == FBSessionStateOpen)
        {
            //[self updateView];
            // register
            [appDelegate loadFBUserInfo:^(id status)
             {
                 NSLog(@"FB Login request completed!");
//                 NSLog(@"s_FB_id : %@",appDelegate.myFBProfile.id);
//                 NSLog(@"access_token : %@",[FBSession activeSession].accessTokenData.accessToken);
//                 NSLog(@"s_FB_id : %@",appDelegate.myProfile.s_FB_id);
//                 NSLog(@"s_Email : %@",appDelegate.myProfile.s_Email);
//                 NSLog(@"s_Name : %@",appDelegate.myProfile.s_Name);
//                 NSLog(@"s_gender :%@",appDelegate.myProfile.s_gender.text);
//                 NSLog(@"s_interested : %@",appDelegate.myProfile.s_interested.text);
//                 NSLog(@"s_birthdayDate : %@",appDelegate.myProfile.s_birthdayDate);
//                 NSLog(@"s_location.ID : %@",appDelegate.myProfile.s_location.ID);
//                 NSLog(@"s_location.name : %@",appDelegate.myProfile.s_location.name);
                 
                 AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
                 NSLog(@"Init API completed");
                 
                 // check if user exists
                 
                 [appDelegate parseFBInfoToProfile:appDelegate.myFBProfile];
                 NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                                         [FBSession activeSession].accessTokenData.accessToken, @"access_token",
                                         appDelegate.myProfile.s_FB_id, @"user_id",
                                         //                                                  appDelegate.myProfile.s_Name, @"name",
                                         //                                                  appDelegate.myProfile.s_Email, @"email",
                                         //                                                  [NSString stringWithFormat:@"%i",appDelegate.myProfile.s_gender.ID], @"sex",
                                         //                                                  [NSString stringWithFormat:@"%i",appDelegate.myProfile.s_interested.ID], @"interested_in",
                                         //                                                  appDelegate.myProfile.s_birthdayDate, @"birthdate",
                                         //                                                  appDelegate.myProfile.s_location.ID, @"location_id",
                                         //                                                  appDelegate.myProfile.s_location.name, @"location_name",
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
                                   menuViewController *leftController = [[menuViewController alloc] init];
                                   [leftController setUIInfo:appDelegate.myProfile];
                                   [appDelegate.rootVC setRightViewController:appDelegate.chat];
                                   [appDelegate.rootVC setLeftViewController:leftController];
                                   appDelegate.window.rootViewController = appDelegate.rootVC;
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
                              [appDelegate showMyProfile];
                          }];
                      }
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

- (void) saveDefaultSettings
{
}

#define padding 15
- (IBAction)showInfoPanel:(id)sender
{
    UAModalPanel *popup = [[UAModelPanelEx alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:popup];
    
    [popup showFromPoint:[self.view center]];
}
@end
