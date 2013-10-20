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
@interface SCLoginViewController (){
    AppDelegate* appDelegate;
}
- (IBAction)performLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView* splashImage;
@end

@implementation SCLoginViewController
@synthesize spinner,btnLogin,pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = [UIApplication sharedApplication].delegate;
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
    
    [NSTimer scheduledTimerWithTimeInterval:4.0f
                                     target:self
                                   selector:@selector(dismissSplashScreen)
                                   userInfo:nil
                                    repeats:NO];
}
-(void)dismissSplashScreen{
    [self.splashImage removeFromSuperview];
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
}
- (void)stopSpinner{
    [self.spinner stopAnimating];
    [btnLogin setEnabled:YES];
}
- (IBAction)performLogin:(id)sender {
    if(btnLogin.selected)
        return;
    [self.spinner startAnimating];
    [btnLogin setEnabled:NO];
    [appDelegate openSession];
}

- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self.spinner stopAnimating];
}



- (void)viewDidUnload {
    [self setBtnLogin:nil];
    [super viewDidUnload];
}

#pragma mark delegate for CyclescrollView
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index{
    pageControl.currentPage = index-1;
}

@end
