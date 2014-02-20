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
#import "CGRect+Utils.h"
#import "LoadingIndicator.h"

@interface FlashIntro () <LoadingIndicatorDelegate>
{
    UIImageView *logo;
    UIView *backView;
    AppDelegate *appDelegate;
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
    
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    
    if(IS_OS_7_OR_LATER)
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height)];
    else
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImage *logoImg = [UIImage imageNamed:@"splashscreen_logo"];
    [logo setImage:logoImg];
    [logo setContentMode:UIViewContentModeScaleAspectFit];
    [logo sizeToFit];
    [logo setFrame:[CGRectUtils centerRect:logo.frame inOuter:self.view.frame applyForXDim:YES yDim:YES]];
    [logo setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [backView addSubview:logo];
    
    [self.view addSubview:backView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [logo setAlpha:1];
    
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
    [appDelegate tryLoginWithSuccess:^(int _status)
     {
         if (_status == 2 || _status == -1)
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
    }];
}

-(void)animatingGoToLogin{
    [self animateEndSplashWithCompletion:^{
        [appDelegate gotoLogin];
    }];
}

-(void)animatingGoToLogined
{
    [self animateEndSplashWithCompletion:^{
        [appDelegate gotoVCAtCompleteLogin];
        [self dismissModalViewControllerAnimated:NO];
    }];
}

-(void)animatingGoToUpdateProfile
{
    [self animateEndSplashWithCompletion:^{
        [appDelegate showConfirm];
    }];
}

-(void)animateEndSplashWithCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.15 animations:^{
        CGRect backViewFrame = backView.frame;
        backViewFrame.size = CGSizeMake(1.2*backViewFrame.size.width, 1.2*backViewFrame.size.height);
        backViewFrame = [CGRectUtils centerRect:backViewFrame inOuter:self.view.frame applyForXDim:YES yDim:NO];
        [backView setFrame:backViewFrame];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 animations:^{
            CGRect backViewFrame = backView.frame;
            backViewFrame.size = CGSizeMake(backViewFrame.size.width, 0.05*backViewFrame.size.height);
            backViewFrame = [CGRectUtils centerRect:backViewFrame inOuter:self.view.frame applyForXDim:YES yDim:NO];
            backViewFrame.origin.y = -backViewFrame.size.height;
            [backView setFrame:backViewFrame];
            
            [backView setAlpha:0.4];
        } completion:^(BOOL finished) {
            if (completion)
            {
                completion();
            }
        }];
    }];
}
@end
