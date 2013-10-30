//
//  FlashIntro.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "FlashIntro.h"
#import "AppDelegate.h"

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
    background = [[UIImageView alloc] initWithFrame:self.view.frame];
    UIImage *backgroundImg = [UIImage imageNamed:@"FlashIntro_background.jpg"];
    [background setImage:backgroundImg];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:background];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [self beginFlash];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginFlash
{
    background.alpha = 0.75;
    deltaAlpha = 0.25/75;
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
