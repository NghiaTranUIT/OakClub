//
//  NCOakClub.m
//  oakclubbuild
//
//  Created by hoangle on 4/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "NavConOakClub.h"
#import "NavBarOakClub.h"
#import "PhotoViewController.h"
@interface NavConOakClub ()

@end

@implementation NavConOakClub
@synthesize headerName;
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
    self.delegate = self;
//    self.view.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation Delegate
-(void) navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    NavBarOakClub *navBar = (NavBarOakClub *) self.navigationBar;
    if(!(viewController == self.viewControllers[0])) {
        navBar.customView.hidden = YES;
        
    }
}

-(void) navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    NavBarOakClub *navBar = (NavBarOakClub *) self.navigationBar;
    if(viewController == self.viewControllers[0]) {
        navBar.customView.hidden = NO;
    }
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


-(BOOL)shouldAutorotate
{
    NSArray *viewControllers = self.viewControllers;
    UIViewController *currentController = [viewControllers objectAtIndex:[viewControllers count]-1];
    if([currentController isKindOfClass:[PhotoViewController class]])
        return YES;
    else
        return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}
@end
