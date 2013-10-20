//
//  VCHangOut.h
//  oakclubbuild
//
//  Created by hoangle on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"
#import "Profile.h"
#import "Define.h"
#import "AppDelegate.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "TapDetectingImageView.h"
#import "ThumbImageView.h"
#import "AFHTTPClient+OakClub.h"
#import "OverlayViewController.h"
@interface VCHangOut : UIViewController<UIGridViewDelegate, UIScrollViewDelegate, TapDetectingImageViewDelegate, ThumbImageViewDelegate,UIImagePickerControllerDelegate,OverlayViewControllerDelegate,UIGridViewDelegateMultipleSection>{
//    UIScrollView *imageScrollView;
    UIScrollView *thumbScrollView;
    UIView       *slideUpView; // Contains thumbScrollView and a label giving credit for the images.
//    BOOL thumbViewShowing;
    AFHTTPClient *request;
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
}
//@property (weak, nonatomic) IBOutlet UIScrollView *thumbScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *leftBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btn_addMeHere;
@property (weak, nonatomic) IBOutlet UIGridView *tb_NearBy;
@property (weak, nonatomic) IBOutlet UIGridViewMultipleSection *tb_Avatars;
- (IBAction)closeAddMeHerePopover:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview_addMeHere;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingHangout;
@property (strong, nonatomic) IBOutlet UIViewController *addmehereView;
- (IBAction)btn_addMeHere:(id)sender;
- (void) initDataNearByTableView;
@end
