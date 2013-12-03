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
#import "UIView+Localize.h"

@interface TutorialViewController () <CycleScrollViewDelegate>
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
    [closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_btn_cancel.png"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    float padding = 0;
    if (IS_OS_7_OR_LATER)
    {
        padding = 30;
        if(IS_HEIGHT_GTE_568)
            padding += 10;
    }
    
    closeButton.frame = CGRectMake(10, 10 + padding, 27, 27);
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
                           [UIImage imageNamed:[@"tutorial_snapshots" localize]],
                           [UIImage imageNamed:[@"tutorial_chat" localize]],
                           [UIImage imageNamed:[@"tutorial_options" localize]],
                           nil];
    CGRect mainFrame = [[UIScreen mainScreen]applicationFrame];
    CycleScrollView *cycle;
    if(IS_OS_7_OR_LATER){
        cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 5, mainFrame.size.width, mainFrame.size.height + 10)
                                        cycleDirection:CycleDirectionLandscape
                                              pictures:pageImages];
    }
    else{
        cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, mainFrame.size.width, mainFrame.size.height)
                                        cycleDirection:CycleDirectionLandscape
                                              pictures:pageImages];
        
    }

    cycle.delegate = self;
    [cycle refreshScrollView];
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    [self.view bringSubviewToFront:pageControl];
    [pageControl setHidden:NO];
}

-(void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView customizeImageView:(TapDetectingImageView *)imageView atIndex:(int)index
{
    [self transText:index :imageView];

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

-(void) transText: (int) index: (TapDetectingImageView *)image {
    
    switch (index) {
        case 0:
        {
            UILabel *content1Label = [[UILabel alloc] init];
            UILabel *content2Label = [[UILabel alloc] init];
            UILabel *content3Label = [[UILabel alloc] init];
            
            [content1Label setText: @""];
            [content2Label setText: @""];
            [content3Label setText: @""];
            NSString *content1String = [@"Swipe photo right\nto LIKE a profile" localize];
            NSString *content2String = [@"Swipe photo left\nto REJECT a profile" localize];
            NSString *content3String = [@"Or just use REJECT / LIKE\nbuttons below" localize];
            
            
            [content1Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content1Label setNumberOfLines: 2];
            [content1Label setText: content1String];
            [content1Label setFrame: CGRectMake((image.frame.size.width - 265)/2, 75, 260, 70)];
            [content1Label setFont: [UIFont systemFontOfSize: 23]];
            [content1Label setTextAlignment: NSTextAlignmentCenter];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
            
            [content2Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content2Label setNumberOfLines: 2];
            [content2Label setText: content2String];
            [content2Label setFrame: CGRectMake((image.frame.size.width - 224)/2, 175, 260, 70)];
            [content2Label setFont: [UIFont systemFontOfSize: 23]];
            [content2Label setTextAlignment: NSTextAlignmentCenter];
            [content2Label setBackgroundColor: [UIColor clearColor]];
            [content2Label setTextColor: [UIColor whiteColor]];
            
            
            [content3Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content3Label setNumberOfLines: 2];
            [content3Label setText: content3String];
            [content3Label setFrame: CGRectMake((image.frame.size.width - 254)/2, 283, 260, 70)];
            [content3Label setFont: [UIFont systemFontOfSize: 21]];
            [content3Label setTextAlignment: NSTextAlignmentCenter];
            [content3Label setBackgroundColor: [UIColor clearColor]];
            [content3Label setTextColor: [UIColor whiteColor]];
            
            [image addSubview: content1Label];
            [image addSubview: content2Label];
            [image addSubview: content3Label];
            
            break;
        }
        case 1:
        {
            UILabel *content1Label = [[UILabel alloc] init];
            [content1Label setText: @""];
            
            NSString *content1String = [@"If you match who someone\nyou can chat with them privately" localize];
            [content1Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content1Label setNumberOfLines: 2];
            [content1Label setText: content1String];
            [content1Label setFrame: CGRectMake((image.frame.size.width - 280)/2, 180, 280, 70)];
            [content1Label setFont: [UIFont systemFontOfSize: 18]];
            [content1Label setTextAlignment: NSTextAlignmentCenter];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
            [image addSubview: content1Label];
            break;
        }
        case 2:
        {
            UILabel *content1Label = [[UILabel alloc] init];
            UILabel *content2Label = [[UILabel alloc] init];
            [content1Label setText: @""];
            [content2Label setText: @""];
            
            NSString *content1String = [@"You can edit your\nprofile here" localize];
            NSString *content2String = [@"You can choose\nwho to see here" localize];
            
            [content1Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content1Label setNumberOfLines: 2];
            [content1Label setText: content1String];
            [content1Label setFrame: CGRectMake((image.frame.size.width)/2, 45, 260, 70)];
            [content1Label setFont: [UIFont systemFontOfSize: 15]];
            [content1Label setTextAlignment: NSTextAlignmentLeft];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
            [content2Label setLineBreakMode: NSLineBreakByCharWrapping];
            [content2Label setNumberOfLines: 2];
            [content2Label setText: content2String];
            [content2Label setFrame: CGRectMake((image.frame.size.width)/2, 200, 260, 70)];
            [content2Label setFont: [UIFont systemFontOfSize: 15]];
            [content2Label setTextAlignment: NSTextAlignmentLeft];
            [content2Label setBackgroundColor: [UIColor clearColor]];
            [content2Label setTextColor: [UIColor whiteColor]];
            [image addSubview: content1Label];
            [image addSubview: content2Label];
            
            break;
        }
            
            
        default:
            break;
    }
}

@end
