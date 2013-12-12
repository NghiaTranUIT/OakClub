//
//  VCLogout.m
//  OakClub
//
//  Created by VanLuu on 10/30/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCLogout.h"
#import "AppDelegate.h"
@interface VCLogout (){
    AppDelegate *appDel;
}
@end

@implementation VCLogout

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
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
}
-(void)viewDidAppear:(BOOL)animated{
     appDel.rootVC.recognizesPanningOnFrontView = NO;
    [appDel.rootVC setRecognizesResetTapOnFrontView:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}
-(void)viewDidDisappear:(BOOL)animated{
    [appDel.rootVC setRecognizesResetTapOnFrontView:NO];
    appDel.rootVC.recognizesPanningOnFrontView = YES;
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark handle on touch
- (IBAction)onTouchConfirmLogout:(id)sender {
    [self.view removeFromSuperview];
    [appDel  logOut];
}
- (IBAction)onTouchCancelLogout:(id)sender {
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.view setFrame:CGRectMake(0, self.view.frame.size.height*2, self.view.frame.size.width, self.view.frame.size.height)];
                     }completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
    
}

@end
