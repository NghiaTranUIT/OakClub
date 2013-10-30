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
    UIPageControl *pageControl;
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
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_cancel.png"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    closeButton.frame = CGRectMake(self.view.frame.size.width - closeButton.frame.size.width - 10, 10, closeButton.frame.size.width, closeButton.frame.size.height);
    [closeButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 3;
    [pageControl sizeToFit];
    NSLog(@"old frame %f-%f-%f-%f", pageControl.frame.origin.x, pageControl.frame.origin.y, pageControl.frame.size.width, pageControl.frame.size.height);
    pageControl.frame = CGRectMake((self.view.frame.size.width - pageControl.frame.size.width) / 2, self.view.frame.size.height - pageControl.frame.size.height - 10, pageControl.frame.size.width, pageControl.frame.size.height);
    NSLog(@"new frame %f-%f-%f-%f", pageControl.frame.origin.x, pageControl.frame.origin.y, pageControl.frame.size.width, pageControl.frame.size.height);
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    
    NSArray* pageImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"tutorial_snapshots.png"],
                           [UIImage imageNamed:@"tutorial_chat.png"],
                           [UIImage imageNamed:@"tutorial_options.png"],
                           nil];
    CycleScrollView *cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
                                                     cycleDirection:CycleDirectionLandscape
                                                           pictures:pageImages];
    
    cycle.delegate = self;
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    [self.view bringSubviewToFront:pageControl];
    [pageControl setHidden:NO];
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
    pageControl.currentPage = index-1;
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
