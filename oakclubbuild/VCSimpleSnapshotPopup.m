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

@interface VCSimpleSnapshotPopup ()
@property (weak, nonatomic) IBOutlet UIView *likePopupView;
@property (weak, nonatomic) IBOutlet UIView *notInterestedPopupView;
@property (weak, nonatomic) IBOutlet APLMoveMeView *moveMeView;
@property (weak, nonatomic) IBOutlet VCSimpleSnapshot *snapshotView;


@end

@implementation VCSimpleSnapshotPopup
@synthesize likePopupView,notInterestedPopupView,moveMeView, snapshotView;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark handle on touch
- (IBAction)onTouchCancel:(id)sender {
    [moveMeView setAnswer:-1];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchLike:(id)sender {
    [moveMeView setAnswer:interestedStatusYES];
    [snapshotView loadCurrentProfile];
    [snapshotView loadNextProfileByCurrentIndex];
    [self.view removeFromSuperview];
}
- (IBAction)onTouchReject:(id)sender {
    [moveMeView setAnswer:interestedStatusNO];
    [snapshotView loadCurrentProfile];
    [snapshotView loadNextProfileByCurrentIndex];
    [self.view removeFromSuperview];
}


#pragma mark load view
-(void) enableViewbyType:(int)type{
    //type: 0-like, 1-not interested
    switch (type) {
        case interestedStatusNO:
            [likePopupView setHidden:YES];
            [notInterestedPopupView setHidden:NO];
            break;
        case interestedStatusYES:
            [likePopupView setHidden:NO];
            [notInterestedPopupView setHidden:YES];
            break;
        default:
            break;
    }
}
@end
