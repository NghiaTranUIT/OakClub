//
//  VCReportPopup.h
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "SMChatViewController.h"

@interface VCReportPopup : UIViewController
-(id)initWithProfileID:(Profile *)_profile andChat:(SMChatViewController *)chatVC;
@end

@interface VCReportMore : UIViewController

@end