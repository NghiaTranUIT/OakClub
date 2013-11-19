//
//  FlashIntro.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "FlashIntro.h"
#import "AppDelegate.h"
#import "AnimatedGif.h"
#import "UIView+Localize.h"

@interface FlashIntro ()
{
    UIImageView *background;
    AppDelegate *appDelegate;
    UIActivityIndicatorView *indicatorView;
}
@end

@implementation FlashIntro

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
	// Do any additional setup after loading the view.
    if(IS_OS_7_OR_LATER)
        background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height)];
    else
        background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSString *localSpashScreen;
    if ([value_appLanguage_VI isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage]])
    {
        localSpashScreen = @"spashscreen_vn";
    }
    else
    {
        localSpashScreen = @"spashscreen";
    }
    UIImage *backgroundImg = [UIImage imageNamed:localSpashScreen];
    [background setImage:backgroundImg];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:background];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView setFrame:CGRectMake(142, 138, indicatorView.frame.size.width,  indicatorView.frame.size.height)];
    indicatorView.color = [UIColor colorWithRed:(121.f / 255.f) green:(1.f / 255.f) blue:(88.f / 255.f) alpha:1];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView stopAnimating];
    
    [self.view addSubview:indicatorView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [background setAlpha:1];
    
    if (appDelegate.isFacebookActivated)
    {
        [self tryLogin];
    }
    else
    {
        [self animatingGoToLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tryLogin
{
    [indicatorView startAnimating];
    [appDelegate tryLoginWithSuccess:^(int _status)
    {
        if (_status == 2)
        {
            [self animatingGoToLogined];
        }
        else
        {
            [self animatingGoToLogin];
        }
        [indicatorView stopAnimating];
    } failure:^{
        [self animatingGoToLogin];
        [indicatorView stopAnimating];
    }];
}

-(void)animatingGoToLogin
{
    [background setAlpha:1];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [UIView animateWithDuration:1.5
                     animations:^{
                         [background setAlpha:0.1];
                     }completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              [self.view setBackgroundColor:[UIColor blackColor]];
                                              [background setAlpha:0];
                                          }completion:^(BOOL finished) {
                                              [appDelegate gotoLogin];
                                          }];
                     }];
}

-(void)animatingGoToLogined
{
    [background setAlpha:1];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [UIView animateWithDuration:2
                     animations:^{
                         [background setAlpha:0];
                     }completion:^(BOOL finished) {
                         [appDelegate gotoVCAtCompleteLogin];
                     }];
}
@end
