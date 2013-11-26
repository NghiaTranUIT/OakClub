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
#import "LoadingIndicator.h"

@interface FlashIntro () <LoadingIndicatorDelegate>
{
    UIImageView *background;
    AppDelegate *appDelegate;
    LoadingIndicator *indicator;
}
@end

@implementation FlashIntro

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (id) [UIApplication sharedApplication].delegate;
        
        indicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:self];
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
    
    //    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //    [indicatorView setFrame:CGRectMake(142, 138, indicatorView.frame.size.width,  indicatorView.frame.size.height)];
    //    indicatorView.color = [UIColor colorWithRed:(121.f / 255.f) green:(1.f / 255.f) blue:(88.f / 255.f) alpha:1];
    //    [indicatorView setHidesWhenStopped:YES];
    //    [indicatorView stopAnimating];
    //
    //    [self.view addSubview:indicatorView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [background setAlpha:1];
    
    BOOL isSetLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:key_ChosenLanguage] boolValue];
    if (!isSetLanguage)
    {
        if([[self checkLanguage] isEqualToString:@"vi"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_VI forKey:key_appLanguage];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //        NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
            [appDelegate updateLanguageBundle];
            NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
            NSLog(@"Vietnamese %@",str);
        }
        else if([[self checkLanguage] isEqualToString:@"de"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_DE forKey:key_appLanguage];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //        NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
            [appDelegate updateLanguageBundle];
            NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
            NSLog(@"German %@",str);
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_EN forKey:key_appLanguage];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [appDelegate updateLanguageBundle];
            NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
            NSLog(@"English %@",str);
        }
        //[self.view localizeAllViews];
    }
    
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
    [indicator lockViewAndDisplayIndicator];
    [appDelegate tryLoginWithSuccess:^(int _status)
     {
         [indicator unlockViewAndStopIndicator];
        if (_status == 2)
        {
            [self animatingGoToLogined];
        }
        else if (_status == 0)
        {
            [self animatingGoToUpdateProfile];
        }
        else
        {
            [self animatingGoToLogin];
        }
    } failure:^{
        [self animatingGoToLogin];
        [indicator unlockViewAndStopIndicator];
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

-(void)animatingGoToUpdateProfile
{
    [background setAlpha:1];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [UIView animateWithDuration:2
                     animations:^{
                         [background setAlpha:0];
                     }completion:^(BOOL finished) {
                         [appDelegate showConfirm];
                     }];
}
@end
