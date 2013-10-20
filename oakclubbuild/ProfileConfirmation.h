//
//  ProfileConfirmation.h
//  OakClub
//
//  Created by VanLuu on 7/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+Custom.h"
#import "Define.h"
#import "AppDelegate.h"
#import "Profile.h"
@interface ProfileConfirmation : UITableViewController<EditTextViewDelegate, ListForChooseDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblNext;
@property (strong, nonatomic) IBOutlet UITableView *tb_Profile;

@end
