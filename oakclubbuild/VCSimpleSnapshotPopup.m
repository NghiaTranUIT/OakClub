//
//  VCSimpleSnapshotPopup.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshotPopup.h"
#import "Define.h"
#import "APLMoveMeView.h"
#import "VCSimpleSnapshot.h"
#import "UIView+Localize.h"

@interface VCSimpleSnapshotPopup ()
@property (weak, nonatomic) IBOutlet UIView *likePopupView;
@property (weak, nonatomic) IBOutlet UIView *notInterestedPopupView;
@property (weak, nonatomic) IBOutlet APLMoveMeView *moveMeView;
@property (weak, nonatomic) IBOutlet VCSimpleSnapshot *snapshotView;
@property (strong, nonatomic) IBOutlet UILabel *lblNopeTurotial;
@property (strong, nonatomic) IBOutlet UILabel *lblLikeTurotial;

@property (weak, nonatomic) IBOutlet UIButton *btnPass;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelPass;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelLike;

@end

@implementation VCSimpleSnapshotPopup
@synthesize likePopupView,notInterestedPopupView,moveMeView, snapshotView, lblLikeTurotial,lblNopeTurotial, btnCancelLike, btnCancelPass, btnLike, btnPass;
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
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view localizeAllViews];
}
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}
#pragma mark handle on touch
- (IBAction)onTouchCancel:(id)sender {
    [moveMeView setAnswer:-1];
    [snapshotView onBackFromPopup];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchLike:(id)sender {
    [moveMeView setAnswer:interestedStatusYES];
    [snapshotView setLikedSnapshot:[NSString stringWithFormat:@"%i",interestedStatusYES]];
    [snapshotView loadCurrentProfile];
    [snapshotView loadNextProfileByCurrentIndex];
    [snapshotView onBackFromPopup];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchReject:(id)sender {
    [moveMeView setAnswer:interestedStatusNO];
    [snapshotView setLikedSnapshot:[NSString stringWithFormat:@"%i",interestedStatusNO]];
    [snapshotView loadCurrentProfile];
    [snapshotView loadNextProfileByCurrentIndex];
    [snapshotView onBackFromPopup];
    [self.view removeFromSuperview];
}


#pragma mark load view
-(void) enableViewbyType:(int)type andFriendName:(NSString*)name{
    //type: 0-like, 1-not interested
    NSString *pref;
    switch (type) {
        case interestedStatusNO:
            pref = [@"Dragging a picture to the left indicates you are not interested in" localize];
            [lblNopeTurotial setText:[NSString stringWithFormat:[pref stringByAppendingString:@" %@."],name]];
            [btnPass.titleLabel setText: @"Pass"];
            [btnCancelPass.titleLabel setText: @"Cancel"];
            [likePopupView setHidden:YES];
            [notInterestedPopupView setHidden:NO];
            break;
        case interestedStatusYES:
            pref = [@"Dragging a picture to the right indicates you liked" localize];
            [lblLikeTurotial setText:[NSString stringWithFormat:[pref stringByAppendingString:@" %@."],name]];
            [btnLike.titleLabel setText: @"Like" ];
            [btnCancelLike.titleLabel setText: @"Cancel"];
            [likePopupView setHidden:NO];
            [notInterestedPopupView setHidden:YES];
            break;
        default:
            break;
    }
}
@end
