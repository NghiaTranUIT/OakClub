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
//    [self.view localizeAllViews];
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
-(void)cancelByAnswer:(int)answer{
    [moveMeView setAnswer:-1];
    [moveMeView animatePlacardViewByReverseAnswer:answer WithDuration:0.3f];
    [snapshotView onBackFromPopup];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchCancelLike:(id)sender {
    [self cancelByAnswer:interestedStatusYES];
}
- (IBAction)onTouchCancelPass:(id)sender {
    [self cancelByAnswer:interestedStatusNO];
}

-(void)doByAnswer:(int)answer{
    [moveMeView setAnswer:answer];
    [moveMeView animatePlacardViewByReverseAnswer:-1 WithDuration:0.3f];
    [snapshotView setLikedSnapshot:[NSString stringWithFormat:@"%i",answer]];
    [snapshotView loadCurrentProfile];
    [snapshotView loadNextProfileByCurrentIndex];
    [snapshotView onBackFromPopup];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchLike:(id)sender {
    [self doByAnswer:interestedStatusYES];
}
- (IBAction)onTouchReject:(id)sender {
    [self doByAnswer:interestedStatusNO];
}


#pragma mark load view
-(void) enableViewbyType:(int)type andFriendName:(NSString*)name{
    //type: 0-like, 1-not interested
    NSString *pref;
    switch (type) {
        case interestedStatusNO:
            pref = @"Dragging a picture to the left indicates you are not interested";
            lblNopeTurotial.text = [pref localize];
            [btnPass.titleLabel setText: [@"Pass" localize]];
            [btnCancelPass.titleLabel setText: [@"Cancel" localize]];
            [likePopupView setHidden:YES];
            [notInterestedPopupView setHidden:NO];
            break;
        case interestedStatusYES:
            pref = @"Dragging a picture to the right indicates you liked";
            lblLikeTurotial.text = [pref localize];
            [btnLike.titleLabel setText: [@"Like" localize]];
            [btnCancelLike.titleLabel setText: [@"Cancel" localize]];
            [likePopupView setHidden:NO];
            [notInterestedPopupView setHidden:YES];
            break;
        default:
            break;
    }
}
@end
