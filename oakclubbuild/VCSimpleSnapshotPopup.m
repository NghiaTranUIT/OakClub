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
@property (weak, nonatomic) IBOutlet UILabel *lblNopeTurotial;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeTurotial;


@end

@implementation VCSimpleSnapshotPopup
@synthesize likePopupView,notInterestedPopupView,moveMeView, snapshotView, lblLikeTurotial,lblNopeTurotial;
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
-(void) enableViewbyType:(int)type andFriendName:(NSString*)name{
    //type: 0-like, 1-not interested
    switch (type) {
        case interestedStatusNO:
            [lblNopeTurotial setText:[NSString stringWithFormat:@"Dragging a picture to the left indicates you are not interested in %@.",name]];
            [likePopupView setHidden:YES];
            [notInterestedPopupView setHidden:NO];
            break;
        case interestedStatusYES:
            [lblNopeTurotial setText:[NSString stringWithFormat:@"Dragging a picture to the right indicates you liked %@.",name]];
            [likePopupView setHidden:NO];
            [notInterestedPopupView setHidden:YES];
            break;
        default:
            break;
    }
}
@end
