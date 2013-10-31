//
//  VCSimpleSnapshotLoading.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshotLoading.h"
#import "AnimatedGif.h"
@interface VCSimpleSnapshotLoading (){
    int typeOfAlert; // 0-Finding, 1-DoneSearching , 2-Noresult
    UIImageView* loadingAnim;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgLoading;
@property (weak, nonatomic) IBOutlet UIButton *btnContentAlert;
@property (weak, nonatomic) IBOutlet UIImageView *imgNOPEDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgiDisable;
@property (weak, nonatomic) IBOutlet UIImageView *imgLIKEDisable;
@property (weak, nonatomic) IBOutlet UILabel *lblContentAlert;

@end

@implementation VCSimpleSnapshotLoading
@synthesize lblContentAlert, imgiDisable, imgLIKEDisable, imgLoading,imgNOPEDisable,btnContentAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Snapshot_gps_loading.gif" ofType:nil]];
        loadingAnim = 	[AnimatedGif getAnimationForGifAtUrl: fileURL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES];
     [self  loadViewbyType];
}
-(void)viewWillAppear:(BOOL)animated{
    [self  loadViewbyType];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Load view by typeOfAlert
-(void) setTypeOfAlert:(int)type andAnim:(UIImageView*)imgAnim{
    typeOfAlert = type;
    if(imgAnim != nil){
        [imgAnim setFrame:CGRectMake(48, 35, imgAnim.frame.size.width, imgAnim.frame.size.height)];
        [self.view  addSubview:imgAnim];
    }
    
}
-(void)loadViewbyType{
    switch (typeOfAlert) {
        case 0:
        {
            [imgNOPEDisable setHidden:NO];
            [imgLIKEDisable setHidden:NO]; 
            [imgiDisable setHidden:NO];
            [btnContentAlert setHidden:YES];
            [lblContentAlert setText:@"Finding nearby people..."];
//            imgLoading = loadingAnim;
//            [loadingAnim setFrame:imgLoading.frame];
//            [self.view  addSubview:loadingAnim];
            break;
        }
        case 1:
        {
            [imgNOPEDisable setHidden:YES];
            [imgLIKEDisable setHidden:YES];
            [imgiDisable setHidden:YES];
            [btnContentAlert setHidden:NO];
            [lblContentAlert setText:@"You've seen all the recommendation near you."];
            [imgLoading setImage:[UIImage imageNamed:@"SnapshotLoading_map_loaded.png"]];
            break;
        }
        default:
            break;
    }
}
@end
