//
//  VCProfile.h
//  oakclubbuild
//
//  Created by VanLuu on 4/15/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "AFHTTPClient+OakClub.h"
#import "ProfileCell.h"
@interface VCProfile : UIViewController<UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    Profile *currentProfile;
    UIImage *img_avatar;
    UIImageView *test;
//    IBOutlet UIViewController *likePopoverView;
    UIPopoverController *pop;
    NSMutableArray *tableSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewProfile;
@property (weak, nonatomic) IBOutlet UIScrollView *svPhotos;

@property (weak, nonatomic) IBOutlet UILabel *labelInterests;
@property (weak, nonatomic) IBOutlet UIImageView *imgView_avatar;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *lblProfileName;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthdate;
@property (weak, nonatomic) IBOutlet UILabel *lblInterested;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UILabel *lblRelationShip;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UITextView *lblAboutMe;
@property (weak, nonatomic) IBOutlet UILabel *lblEthnicity;
@property (weak, nonatomic) IBOutlet UILabel *lblAge;
@property (weak, nonatomic) IBOutlet UILabel *lblPopularity;
@property (weak, nonatomic) IBOutlet UILabel *lblWanttoMake;
- (IBAction)showLikePopover:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIViewController *likePopoverView;
- (IBAction)showReportPopover:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (strong, nonatomic) IBOutlet UIViewController *reportPopoverView;
@property (weak, nonatomic) IBOutlet UIButton *btnBlock;
- (IBAction)onTouchBlock:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UIScrollView *mutualFriendsImageView;

@property (weak, nonatomic) IBOutlet UIButton *buttonAvatar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewInterest;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnIwantToMeet;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingAvatar;
@property (weak, nonatomic) IBOutlet UIPageControl *photoPageControl;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;

-(void) loadProfile:(Profile*) _profile andImage:(UIImage*)avatar;
-(void) loadProfile:(Profile*) _profile;
@end
