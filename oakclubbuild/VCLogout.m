//
//  VCLogout.m
//  OakClub
//
//  Created by VanLuu on 10/30/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCLogout.h"
#import "AppDelegate.h"
@interface VCLogout ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark handle on touch
- (IBAction)onTouchConfirmLogout:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
    [self.view removeFromSuperview];
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [appDel  logOut];
}
- (IBAction)onTouchCancelLogout:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.view setFrame:CGRectMake(0, self.view.frame.size.height*2, self.view.frame.size.width, self.view.frame.size.height)];
                     }completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
    
}

@end
