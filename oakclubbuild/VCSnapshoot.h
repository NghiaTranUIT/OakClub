//
//  VCSnapshoot.h
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "AFHTTPClient+OakClub.h"
#import "VCSnapshotSetting.h"

@interface VCSnapshoot : UIViewController<UIScrollViewDelegate, UIAlertViewDelegate>{
    Profile * currentProfile;
    int currentIndex;
    AFHTTPClient *request;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)btnYES:(id)sender;
- (IBAction)btnShowProfile:(id)sender;
- (IBAction)btnNOPE:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewTest;
@property (weak, nonatomic) IBOutlet UILabel *lbl_indexPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mutualFriends;
@property (weak, nonatomic) IBOutlet UIButton *buttonProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mutualLikes;
@property (weak, nonatomic) IBOutlet UIButton *buttonNO;
@property (weak, nonatomic) IBOutlet UIScrollView *sv_photos;
@property (weak, nonatomic) IBOutlet UIImageView *imgMutualFriend;
@property (weak, nonatomic) IBOutlet UIImageView *imgMutualLike;
@property (weak, nonatomic) IBOutlet UIButton *buttonMAYBE;
@property (weak, nonatomic) IBOutlet UIButton *buttonYES;

-(void)showNotifications;
@end
