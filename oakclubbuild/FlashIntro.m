//
//  FlashIntro.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "FlashIntro.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"

@interface FlashIntro ()
{
    float deltaAlpha;
    UIImageView *background;
}
@end

@implementation FlashIntro

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    if ([value_appLanguage_EN isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage]])
    {
        localSpashScreen = @"spashscreen";
    }
    else
    {
        localSpashScreen = @"spashscreen_vn";
    }
    UIImage *backgroundImg = [UIImage imageNamed:localSpashScreen];
    [background setImage:backgroundImg];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:background];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [self beginFlash:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginFlash:(float)flashTime
{
    background.alpha = 0.75;
    deltaAlpha = 0.25/(0.75 * (flashTime / 0.04));
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(onFlashing:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)endFlash
{
    background.alpha = 0.0;
    //go to login
    
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    [appDel gotoLogin];
}

- (void)onFlashing:(NSTimer *)timer
{
    background.alpha += deltaAlpha;
    if (deltaAlpha > 0 && background.alpha >= 1)
    {
        deltaAlpha = -4*deltaAlpha;
    }
    else if (background.alpha <= 0)
    {
        [timer invalidate];
        [self endFlash];
    }
}

@end
