//
//  VCGetPoints.m
//  OakClub
//
//  Created by VanLuu on 7/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCGetPoints.h"

@interface VCGetPoints ()

@end

@implementation VCGetPoints

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
    self.view.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
