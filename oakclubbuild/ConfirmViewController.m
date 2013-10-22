//
//  ConfirmViewController.m
//  OakClub
//
//  Created by Salm on 10/22/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ConfirmViewController.h"
#import "AppDelegate.h"

@interface ConfirmViewController ()

@end

@implementation ConfirmViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollview.bounces = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *confirmButtonID = @"ConfirmButtonCell";
    
    NSLog(@"Confirm: create cell %@", indexPath);
    int nRows = [super tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row < nRows)
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    UITableViewCell *confirmButton = [tableView dequeueReusableCellWithIdentifier:confirmButtonID];
    if (confirmButton == nil)
    {
        confirmButton = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:confirmButtonID];
        confirmButton.textLabel.text = @"Confrim";
    }
    
    return confirmButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int nRows = [super tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row < nRows)
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else
    {
        // next button selected
        [super saveSettingWithWarning:NO];
        AppDelegate *appDelegate = (id) [UIApplication sharedApplication].delegate;
        
        menuViewController *leftController = [[menuViewController alloc] init];
        [leftController setUIInfo:appDelegate.myProfile];
        [appDelegate.rootVC setRightViewController:appDelegate.chat];
        [appDelegate.rootVC setLeftViewController:leftController];
        appDelegate.window.rootViewController = appDelegate.rootVC;
    }
}

@end
