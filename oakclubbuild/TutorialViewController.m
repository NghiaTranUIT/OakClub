//
//  TutorialViewController.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "TutorialViewController.h"
#import "CycleScrollView.h"
#import "AppDelegate.h"

@interface TutorialViewController ()
{
}
@end

@implementation TutorialViewController

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
    
    NSArray* pageImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"intropage_snap.png"],
                           [UIImage imageNamed:@"intropage_chat.png"],
                           [UIImage imageNamed:@"intropage_match.png"],
                           nil];
    CycleScrollView *cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 455)
                                                     cycleDirection:CycleDirectionLandscape
                                                           pictures:pageImages];
    
    cycle.delegate = self;
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"cancel-btn.png"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    closeButton.frame = CGRectMake(self.view.frame.size.width - closeButton.frame.size.width, 0, closeButton.frame.size.width, closeButton.frame.size.height);
    [closeButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:closeButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index{
    //pageControl.currentPage = index-1;
}

-(void)closeButtonTouched:(id)sender
{
    AppDelegate *appDelegate = (id) [UIApplication sharedApplication].delegate;
    menuViewController *leftController = [[menuViewController alloc] init];
    [leftController setUIInfo:appDelegate.myProfile];
    [appDelegate.rootVC setRightViewController:appDelegate.chat];
    [appDelegate.rootVC setLeftViewController:leftController];
    appDelegate.window.rootViewController = appDelegate.rootVC;
}
@end
