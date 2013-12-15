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
    [self transText:index forImage:imageView];
    [self localizeAllText];

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

-(void)transText:(int)index forImage:(TapDetectingImageView *)image {
    
    switch (index) {
        case 0:
        {
            UILabel *content1Label = [[UILabel alloc] init];
            UILabel *content2Label = [[UILabel alloc] init];
            UILabel *content3Label = [[UILabel alloc] init];
            
            [content1Label setText: @""];
            [content2Label setText: @""];
            [content3Label setText: @""];
            NSString *content1String = [@"Swipe photo Right to LIKE a profile" localize];
            NSString *content2String = [@"Swipe photo Left to PASS a profile" localize];
            NSString *content3String = [@"Or just use PASS / LIKE button below" localize];
            
            
            [content1Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content1Label setNumberOfLines: 0];
            [content1Label setText: content1String];
            
            [content1Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            CGSize size1 = [content1Label.text sizeWithFont:content1Label.font
                                          constrainedToSize:CGSizeMake(210, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            [content1Label setFrame: CGRectMake(20, 70, size1.width, size1.height)];
            [content1Label setTextAlignment: NSTextAlignmentCenter];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
//            [content1Label setAdjustsFontSizeToFitWidth: YES];
//            [content1Label setMinimumFontSize:10];
            
            
            [content2Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content2Label setNumberOfLines: 0];
            [content2Label setText: content2String];
            [content2Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            CGSize size2 = [content2Label.text sizeWithFont:content2Label.font
                                          constrainedToSize:CGSizeMake(210, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            [content2Label setFrame: CGRectMake(100, 150, size2.width, size2.height)];
            [content2Label setTextAlignment: NSTextAlignmentCenter];
            [content2Label setBackgroundColor: [UIColor clearColor]];
            [content2Label setTextColor: [UIColor whiteColor]];
            [content2Label setAdjustsFontSizeToFitWidth:YES];
            
            [content3Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content3Label setNumberOfLines: 0];
            [content3Label setText: content3String];
            [content3Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            CGSize size3 = [content3Label.text sizeWithFont:content3Label.font
                                          constrainedToSize:CGSizeMake(self.view.frame.size.width - 10, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            [content3Label setFrame: CGRectMake(10, 283, size3.width, size3.height)];
            [content3Label setTextAlignment: NSTextAlignmentCenter];
            [content3Label setBackgroundColor: [UIColor clearColor]];
            [content3Label setTextColor: [UIColor whiteColor]];
            [content3Label setAdjustsFontSizeToFitWidth:YES];
            
            if(IS_HEIGHT_GTE_568)
            {
                [content1Label setFrame: CGRectMake(10, 75, size1.width, size1.height)];
                [content2Label setFrame: CGRectMake(100, 170, size2.width, size2.height)];
                [content3Label setFrame: CGRectMake(10, 310, size3.width, size3.height)];
            }
            
            [image addSubview: content1Label];
            [image addSubview: content2Label];
            [image addSubview: content3Label];
            
            break;
        }
        case 1:
        {
            UILabel *content1Label = [[UILabel alloc] init];
            [content1Label setText: @""];
            
            NSString *content1String = [@"If you match with someone you can chat with them privately" localize];
            [content1Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content1Label setNumberOfLines: 0];
            [content1Label setText: content1String];
            [content1Label setFrame: CGRectMake(20, 190, self.view.frame.size.width - 40, 100)];
            [content1Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            [content1Label setTextAlignment: NSTextAlignmentCenter];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
            if(IS_HEIGHT_GTE_568)
            {
                [content1Label setFrame:CGRectMake(0, 205, self.view.frame.size.width, 70)];

            }
            [image addSubview: content1Label];
            break;
        }
        case 2:
        {
            CGFloat textWidth = 120;
            UILabel *content1Label = [[UILabel alloc] init];
            UILabel *content2Label = [[UILabel alloc] init];
            [content1Label setText: @""];
            [content2Label setText: @""];
            
            NSString *content1String = [@"You can edit your profile here" localize];
            NSString *content2String = [@"You can choose who to see here" localize];
            
            [content1Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content1Label setNumberOfLines: 0];
            [content1Label setText: content1String];
            [content1Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            CGSize size1 = [content1Label.text sizeWithFont:content1Label.font
                                          constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            [content1Label setFrame: CGRectMake((image.frame.size.width)/2, 53, size1.width, size1.height)];
            [content1Label setTextAlignment: NSTextAlignmentLeft];
            [content1Label setBackgroundColor: [UIColor clearColor]];
            [content1Label setTextColor: [UIColor whiteColor]];
            
            [content2Label setLineBreakMode: NSLineBreakByWordWrapping];
            [content2Label setNumberOfLines: 0];
            [content2Label setText: content2String];
            [content2Label setFont: FONT_HELVETICANEUE_LIGHT(20)];
            CGSize size2 = [content2Label.text sizeWithFont:content2Label.font
                                          constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            [content2Label setFrame: CGRectMake((image.frame.size.width)/2, 190, size2.width, size2.height)];
            [content2Label setTextAlignment: NSTextAlignmentLeft];
            [content2Label setBackgroundColor: [UIColor clearColor]];
            [content2Label setTextColor: [UIColor whiteColor]];
            
            if(IS_HEIGHT_GTE_568)
            {
                [content1Label setFrame: CGRectMake(3 * (image.frame.size.width)/ 5, 55, size1.width, size1.height)];
                [content2Label setFrame: CGRectMake(3 * (image.frame.size.width)/ 5, 235, size2.width, size2.height)];
            }
            [image addSubview: content1Label];
            [image addSubview: content2Label];
            
            break;
        }
            
            
        default:
            break;
    }
}

-(void) localizeAllText{
    for(UIView* view in [self.view subviews]){
        [view localizeText];
    }
}

@end
