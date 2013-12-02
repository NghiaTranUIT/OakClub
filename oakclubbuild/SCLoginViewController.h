//
//  SCLoginViewController.h
//  OakClub
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCLoginViewController : UIViewController
- (void)loginFailed;
- (void)startSpinner;
- (void)stopSpinner;
- (void) tryLogin;
- (IBAction)performLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@end