//
//  VCReportPopup.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCReportPopup.h"

@interface VCReportPopup ()

@end

@implementation VCReportPopup

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
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTouchBlockThisUser:(id)sender {
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)onTouchSendReport:(id)sender {
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController popViewControllerAnimated:NO];
}
@end
