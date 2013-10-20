//
//  ProfileSettings.h
//  OakClub
//
//  Created by VanLuu on 6/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "ListForChoose.h"
@interface ProfileSettings : UITableViewController<UITableViewDataSource, UITableViewDelegate,ListForChooseDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UITableView *tbEditProfile;

@end
