//
//  VCSimpleSnapshot.h
//  OakClub
//
//  Created by VanLuu on 9/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface VCSimpleSnapshot : UIViewController<UIScrollViewDelegate>{
    Profile * currentProfile;
    int currentIndex;
    AFHTTPClient *request;
    NSMutableArray* profileList;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)btnYES:(id)sender;
- (IBAction)btnShowProfile:(id)sender;
- (IBAction)btnNOPE:(id)sender;
-(void)loadCurrentProfile;
-(void)loadNextProfileByCurrentIndex;
-(void) gotoPROFILE;
-(void)loadProfileList:(void(^)(void))handler;
-(void)showMatchView;
-(void)setLikedSnapshot:(NSString*)answerChoice;
-(BOOL)isContinueLoad;
-(void) refreshSnapshot;
-(void) showWarning;
@property (weak, nonatomic) IBOutlet UILabel *lbl_indexPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mutualFriends;
@property (weak, nonatomic) IBOutlet UIButton *buttonProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mutualLikes;
@property (weak, nonatomic) IBOutlet UIImageView *imgNextProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgMainProfile;
@property (strong, nonatomic) IBOutlet UIScrollView *sv_photos;
// for Mutual match popup
@property (weak, nonatomic) IBOutlet UIImageView *imgMatcher;
@property (weak, nonatomic) IBOutlet UIImageView *imgMyAvatar;
@property (strong, nonatomic) IBOutlet UIViewController *matchViewController;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchAlert;

@property (weak, nonatomic) IBOutlet UIImageView *imgMutualFriend;
@property (weak, nonatomic) IBOutlet UIImageView *imgMutualLike;

@property (weak, nonatomic) IBOutlet UIButton *buttonMAYBE;
@property (weak, nonatomic) IBOutlet UIButton *buttonYES;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAge;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotoCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UIButton *buttonNO;

-(void)onBackFromPopup;
@end
