//
//  VCProfile.m
//  oakclubbuild
//
//  Created by VanLuu on 4/15/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCProfile.h"
#import "AFHTTPClient+OakClub.h"
#import <QuartzCore/QuartzCore.h>
#import "NavBarOakClub.h"
#import "SMChatViewController.h"

#import "AppDelegate.h"
#import "PhotoViewController.h"
#import "NSString+Utils.h"
#import "UIView+Localize.h"
#import <math.h>
#import "ImageInfo.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ProfileInfoCell.h"
#import "VCSimpleSnapshot.h"
#import "VCReportPopup.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface VCProfile (){
//    BOOL popoverShowing;
    AFHTTPClient *request;
    AppDelegate *appDel;
    ImagePool *userImagePool;
}

@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *nLikeViewsView;
@property (weak, nonatomic) IBOutlet UIView *mutualFriendsView;
@property (weak, nonatomic) IBOutlet UIView *interestsView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblActive;
@property (weak, nonatomic) IBOutlet UILabel *lblnViews;
@property (weak, nonatomic) IBOutlet UILabel *lblnLikes;
@property (weak, nonatomic) IBOutlet UIView *lblsPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *oakClubLogo;
@property (strong, nonatomic) IBOutlet UILabel *lblTabBarName;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblActiveTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnVIPChat;
@property BOOL showNavigationBar;

@property (strong, nonatomic) NSMutableArray *indicatorArray;
@property (strong, nonatomic) NSMutableArray *errorLabelArray;
@property (assign, nonatomic) int numOfPhotoAndVideo;

@end

@implementation VCProfile
@synthesize lbl_name, imgView_avatar, scrollview,lblAboutMe,lblBirthdate,lblGender, lblInterested, lblLocation, lblProfileName, lblRelationShip, likePopoverView, reportPopoverView, lblEthnicity, lblAge, lblPopularity, lblWanttoMake, btnAddToFavorite, btnIwantToMeet, btnBlock, btnChat, tableViewProfile, svPhotos,infoView, photoPageControl, photoCount,lblDistance, lblActive, lblActiveTitle,lblDistanceTitle;

@synthesize labelInterests;
@synthesize mutualFriendsImageView;
//@synthesize buttonAvatar;
@synthesize scrollViewInterest;
@synthesize showNavigationBar;
@synthesize loadingAvatar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        request= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
        tableSource = [[NSMutableArray alloc] init];
        appDel = (id) [UIApplication sharedApplication].delegate;
        
        self.indicatorArray = [NSMutableArray array];
        self.errorLabelArray = [NSMutableArray array];
    }
    return self;
}

static CGFloat padding_top = 5.0;
static CGFloat padding_left = 5.0;

-(UIImageView*)getInterestLabel:(NSString*)text
{
    UILabel* label = [[UILabel alloc]init];
    
    UIFont* font = [UIFont systemFontOfSize:14.0];
    CGSize  textSize = { 290, CGFLOAT_MAX };
    
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0]
					  constrainedToSize:textSize
						  lineBreakMode:NSLineBreakByWordWrapping];
    
    size.width += (padding_left/2);
    
    UIImage* bgImage = [[UIImage imageNamed:@"button blue.png"] stretchableImageWithLeftCapWidth:5  topCapHeight:5];
    
    //label.frame = CGRectMake(p.x, p.y, size.width, size.height);
    label.text = text;
    label.font = font;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    //[label sizeToFit];
    [label setFrame:CGRectMake(padding_left, padding_top - 2, size.width, size.height)];
    label.textColor = [UIColor colorWithRed:(52/255.f) green:(112/255.f) blue:(142/255.f) alpha:1.0];
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    
    
    CGRect rect = CGRectMake( 0,
                             0,
                             size.width+10,
                             label.frame.size.height + 4);
    
    [bgImageView setFrame:rect];

    [bgImageView addSubview:label];
    
    return bgImageView;
}

-(CGRect)moveToFrame:(CGRect)toFrame from:(CGRect)fromFrame
{
    CGPoint coord = toFrame.origin;
    CGSize size = fromFrame.size;
    
    return CGRectMake(coord.x, coord.y, size.width, size.height);
}

-(CGRect)addRelative:(CGRect)origin addPoint:(CGPoint)point
{
    CGPoint coord = origin.origin;
    CGSize size = origin.size;
    
    return CGRectMake(coord.x + point.x, coord.y + point.y, size.width, size.height);
    
}

-(void)disableControllerButtons:(BOOL)value{
    [self.btnLike setEnabled:!value];
    [self.btnReport setEnabled:!value];
    [self.btnChat setEnabled:!value];
}

-(void)changeFontStyle{
    for (UIView *subview in scrollview.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_HELVETICANEUE_LIGHT(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.aboutView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_HELVETICANEUE_LIGHT(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.mutualFriendsView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_HELVETICANEUE_LIGHT(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.interestsView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_HELVETICANEUE_LIGHT(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.profileView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_HELVETICANEUE_LIGHT(label.font.pointSize)];
        }
    }
}

-(void)LoadDistanceText{    
    [lblDistanceTitle setText:[@"Distance:" localize]];
    [lblDistanceTitle sizeToFit];
    lblDistance.frame = CGRectMake(lblDistanceTitle.frame.origin.x + lblDistanceTitle.frame.size.width + 5, lblDistanceTitle.frame.origin.y, lblDistance.frame.origin.x + (self.view.frame.size.width - lblDistanceTitle.frame.size.width), lblDistanceTitle.frame.size.height);
    if(currentProfile.distance < 1){
        [lblDistance setText:[@"Less than a km away" localize]];
        return;
    }
    
    NSString *formatString = [@"%i km away" localize];
    [lblDistance setText:[NSString stringWithFormat:formatString, currentProfile.distance]];
}

-(void)LoadActiveText{
    [lblActiveTitle setText:[@"Active:" localize]];
    [lblActiveTitle sizeToFit];
    lblActive.frame = CGRectMake(lblActiveTitle.frame.origin.x + lblActiveTitle.frame.size.width + 5, lblActiveTitle.frame.origin.y
                                   , lblActive.frame.size.width, lblActiveTitle.frame.size.height);
    if(currentProfile.active == -1){
        [lblActive setText:[@"Just now" localize]];
        return;
    }
    if(currentProfile.active==0){
        [lblActive setText:[@"Today" localize]];
        return;
    }
    if(currentProfile.active < 5){
        [lblActive setText:[NSString stringWithFormat:@"%i %@",currentProfile.active, [@"days ago" localize]]];
        return;
    }
    [lblActive setText:[@"More than 5 days ago" localize]];
}

#define ABOUTVIEW_PADDING 10
#define VIEW_PADDING 3
-(void)loadInfoView{
    lbl_name.text = currentProfile.s_Name;
    lblAge.text = [NSString stringWithFormat:@"%@",currentProfile.s_age];
//    [self.btnVIPChat setHidden:!appDel.myProfile.is_vip];
    [self.btnVIPChat setHidden:YES];
    
    self.lblnViews.text = [NSString stringWithFormat:@"%i", currentProfile.num_Viewed];
    self.lblnLikes.text = [NSString stringWithFormat:@"%i", currentProfile.num_Liked];
    [self LoadDistanceText];
    [self LoadActiveText];
    // SCROLL SIZE
    [scrollview setContentSize:CGSizeMake(320, scrollview.frame.size.height)];
    NSLog(@"Init Content size: %f - %f", scrollview.contentSize.width, infoView.frame.origin.y);
    
    CGPoint startPosition = CGPointMake(0, self.lblActiveTitle.frame.origin.y + self.lblActiveTitle.frame.size.height + VIEW_PADDING);
    if( currentProfile.arr_MutualInterests && [currentProfile.arr_MutualInterests count] > 0)
    {
        NSLog(@"Before Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
        self.interestsView.hidden = NO;
        CGRect interestsFrame = self.interestsView.frame;
        interestsFrame.origin = startPosition;
        [self.interestsView setFrame:interestsFrame];
        
        [self loadInterestedThumbnailList:currentProfile.arr_MutualInterests andContentView:self.interestsView andScrollView:self.scrollViewInterest];
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.interestsView.frame.size.height)];
        startPosition.y += interestsFrame.size.height;
        NSLog(@"Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    else
    {
        self.interestsView.hidden = YES;
    }
    
    
    if(currentProfile.arr_MutualFriends && [currentProfile.arr_MutualFriends count] > 0)
    {
        NSLog(@"Before Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
        self.mutualFriendsView.hidden = NO;
        CGRect mutualFriendsFrame = self.mutualFriendsView.frame;
        mutualFriendsFrame.origin = startPosition;
        [self.mutualFriendsView setFrame:mutualFriendsFrame];
        
        [self loadInterestedThumbnailList:currentProfile.arr_MutualFriends andContentView:self.mutualFriendsView andScrollView:self.mutualFriendsImageView];
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.mutualFriendsView.frame.size.height)];
        startPosition.y += self.mutualFriendsView.frame.size.height;
        NSLog(@"Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    else
    {
        self.mutualFriendsView.hidden = YES;
    }
    
    
    self.lblAboutMe.text = [[currentProfile s_aboutMe] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (lblAboutMe.text.length > 0)
    {
        self.aboutView.hidden = NO;
        lblAboutMe.numberOfLines = 0;
        [lblAboutMe sizeToFit];
        CGRect newAboutFrame = CGRectMake(self.aboutView.frame.origin.x,
                                          self.aboutView.frame.origin.y,
                                          self.aboutView.frame.size.width,
                                          self.lblAboutMe.frame.size.height + self.lblAboutMe.frame.origin.y + ABOUTVIEW_PADDING);
//        NSInteger deltaPosition = (self.aboutView.frame.size.height - newAboutFrame.size.height);

        newAboutFrame.origin = startPosition;
        [self.aboutView setFrame:newAboutFrame];
        
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.aboutView.frame.size.height)];
        startPosition.y += self.aboutView.frame.size.height;
    }
    else
    {
        self.aboutView.hidden = YES;
    }
    
    // UPDATE FRAME FOR PROFILE VIEW
    CGRect profileViewFrame = self.profileView.frame;
    profileViewFrame.origin = startPosition;
    profileViewFrame.size.height = 30 * [tableSource count];
    [self.profileView setFrame:profileViewFrame];
    [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.profileView.frame.size.height)];
    startPosition.y += self.profileView.frame.size.height;
    
    [self  disableControllerButtons:NO];
    
    loadingAvatar.hidden = YES;
    [loadingAvatar stopAnimating];
    
}
-(void)loadInterestedThumbnailList:(NSArray*)favList andContentView:(UIView*)contentView andScrollView:(UIScrollView*)contentScroll
{
    for(int i = 0 ; i < [favList count]; i++)
    {
        ImageInfo *fav = [favList objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"viewprofile_avatarBorder"]];
        
        // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
        CGRect rect = imageView.frame;
        rect.size.height = 58;
        rect.size.width = 58;
        
        imageView.tag = i;	// tag our images for later use when we place them in serial fashion
        
        rect.origin.y = (contentScroll.frame.size.height - rect.size.height - 15) / 2;
        rect.origin.x = i * (58 + 5);
        
        imageView.frame = rect;
        
        UIImageView *favIcon = [[UIImageView alloc] initWithFrame:imageView.frame];
        [favIcon setImage:[UIImage imageNamed:@"Default Avatar"]];
        [userImagePool getImageAtURL:fav.avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
            [favIcon setImage:img];
        }];
        
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, 58, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setFont:FONT_HELVETICANEUE_LIGHT(10.0)];
        [name setTextAlignment:NSTextAlignmentCenter];
        name.text = fav.name;
        [contentScroll addSubview:favIcon];
        [contentScroll addSubview:imageView];
        [contentScroll addSubview:name];
    }
    
    contentScroll.contentSize = CGSizeMake( [favList count] * (58 + 5), 58 + 5);
}
    
    
-(void)loadInterestedList:(NSArray*)array{
    int x = 0;
    int y = 0;
    int prev_line_height = 0;
    CGSize scrollSize = self.scrollViewInterest.frame.size;
    CGSize maxsize = CGSizeMake(0, 0);
    for(int i = 0; i < [array count]; i++)
    {
        
        NSString* text = [array objectAtIndex:i];
        UIImageView* labelView = [self getInterestLabel:text];
        
        CGRect rect = labelView.frame;
        
        if(x + rect.size.width > scrollSize.width)
        {
            x = 0;
            y += prev_line_height;
        }
        
        rect.origin.x = x;
        rect.origin.y = y;
        
        [labelView setFrame:rect];
        
        [scrollViewInterest addSubview:labelView];
        x += rect.size.width + 5;
        
        if( maxsize.width < x - 5)
            maxsize.width = x - 5;
        
        if( maxsize.height < y + rect.size.height)
            maxsize.height = y + rect.size.height;
        
        prev_line_height = rect.size.height + 5;
    }
    
    [scrollViewInterest setContentSize:maxsize];
    [scrollViewInterest removeFromSuperview];
    
    scrollViewInterest.frame = [self addRelative:scrollViewInterest.frame addPoint:self.interestsView.frame.origin];
    [scrollview addSubview:scrollViewInterest];
}

- (IBAction)onTap_Avatar:(id)sender
{
    PhotoViewController *view = [[PhotoViewController alloc] initWithProfileID:currentProfile.s_ID];

    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark view delegate
- (void)viewDidLoad
{
    [self changeFontStyle];
    loadingAvatar.hidden = NO;
    [loadingAvatar startAnimating];
    [self  disableControllerButtons:YES];
    
    [super viewDidLoad];
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOnPhotos:)];
    [photoTap setNumberOfTapsRequired:1];
    [photoTap setNumberOfTouchesRequired:1];
    [self.svPhotos addGestureRecognizer:photoTap];
    
    // Do any additional setup after loading the view from its nib.
    userImagePool = [[ImagePool alloc] init];
    [self loadInfoView];
    
    [self refreshScrollView];
    [self useSnapshotAvatar];
    [self loadPhotoForScrollview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishPlayVideoClick:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view localizeAllViews];
    [self.infoView localizeAllViews];
    [self.interestsView localizeAllViews];
    [self.mutualFriendsView localizeAllViews];
    [self.profileView localizeAllViews];
    [self.view localizeAllViews];
    
//    [self customNavHeader];
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidUnload {
    [self setLbl_name:nil];
    [self setImgView_avatar:nil];
    [self setScrollview:nil];
    [self setLblProfileName:nil];
    [self setLblBirthdate:nil];
    [self setLblInterested:nil];
    [self setLblGender:nil];
    [self setLblRelationShip:nil];
    [self setLblLocation:nil];
    [self setLblAboutMe:nil];
    [self setBtnLike:nil];
    [self setLikePopoverView:nil];
    [self setBtnReport:nil];
    [self setReportPopoverView:nil];
    [self setLblEthnicity:nil];
    [self setLblAge:nil];
    [self setLblPopularity:nil];
    [self setLblWanttoMake:nil];
    [self setLabelInterests:nil];
    [self setMutualFriendsImageView:nil];
    
    [self setScrollViewInterest:nil];
    [self setLoadingAvatar:nil];
    [self setBtnAddToFavorite:nil];
    [self setBtnIwantToMeet:nil];
    [self setBtnBlock:nil];
    [self setBtnChat:nil];
    [self setTableViewProfile:nil];
    [self setMutualFriendsView:nil];
    [self setInterestsView:nil];
    [self setProfileView:nil];
    userImagePool = nil;
    [super viewDidUnload];
}

#pragma mark Custom view
-(void)customNavHeader
{
    if(!IS_OS_7_OR_LATER)
        [self.navigationController.navigationBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self customBackButtonBarItem];
    self.lblTabBarName.frame = CGRectMake(60, 0, self.lblTabBarName.frame.size.width, 44);
    self.lblTabBarName.text = currentProfile.firstName;
    [self.navigationController.navigationBar addSubview:self.lblTabBarName];

}

-(void)checkAddedToBlockList{
    [btnBlock setSelected:NO];
    [request getPath:URL_getListBlocking parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        if(![data isKindOfClass:[NSNull class]])
        {
            for (int i = 0; i < [data count]; i++) {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                NSString * temp = [objectData valueForKey:key_profileID];
                if([currentProfile.s_ID isEqualToString: temp]){
                    [btnBlock setSelected:YES];
                    [self.btnReport setSelected:YES];
                    return;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_getListBlocking - Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

-(void)checkAddedToWantToMeet{
    [btnIwantToMeet setSelected:NO];
    [request getPath:URL_getListIWantToMeet parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        if(![data isKindOfClass:[NSNull class]]){
            for (int i = 0;i < [data count]; i++) {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                NSString * temp = [objectData valueForKey:key_profileID];
                if([currentProfile.s_ID isEqualToString: temp]){
                    [btnIwantToMeet setSelected:YES];
                    [self.btnLike setSelected:YES];
                    return;
                }
            }
        }
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_getListIWantToMeet - Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showLikePopover:(id)sender {
    [self showPopover:likePopoverView andSender:self.btnLike ];
    [reportPopoverView.view removeFromSuperview];
}

- (IBAction)showReportPopover:(id)sender {
    [self showPopover:reportPopoverView andSender:self.btnReport ];
    [likePopoverView.view removeFromSuperview];
}

-(void)showPopover:(UIViewController *) controller andSender:(UIButton *)button {
        [self.view addSubview:controller.view];}

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(IBAction)gotoChat:(id)sender
{
    UINavigationController* activeVC = [[self appDelegate] activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if( ![vc isKindOfClass:[VCChat class]] )
    {
        
        NSString *userName = [NSString stringWithFormat:@"%@%@",currentProfile.s_ID ,DOMAIN_AT];//user.jidStr;
        [appDel.friendChatList setObject:currentProfile forKey:userName];
        
        SMChatViewController *chatController = [[SMChatViewController alloc] initWithUser:userName
                                                                              withProfile:currentProfile];
        
        [self.navigationController pushViewController:chatController animated:YES];
        //[self.navigationController presentModalViewController:chatController animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
- (IBAction)onDoneClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark loadProfile functions
-(void) useImage:(UIImage*)_avatar{
    img_avatar = _avatar;
    [self useSnapshotAvatar];
}

-(void) loadProfile:(Profile*) _profile{
    currentProfile = _profile;
    
    NSLog(@"Set VCProfile profile avatar: %@", currentProfile.s_Avatar);
    
    // fill data to table source
    if (currentProfile.s_location.name && [currentProfile.s_location.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_location_icon" andValue:currentProfile.s_location.name];
    }
    if (currentProfile.hometown && [currentProfile.hometown stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_hometown_icon" andValue:currentProfile.hometown];
    }
    if (currentProfile.s_birthdayDate && [currentProfile.s_birthdayDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_birthdate_icon" andValue:currentProfile.s_birthdayDate];
    }
    if (currentProfile.s_school && currentProfile.s_school.length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_school_icon" andValue:[currentProfile.s_school stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    if (currentProfile.i_work.cate_name && [currentProfile.i_work.cate_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_work_icon" andValue:currentProfile.i_work.cate_name];
    }
    if (currentProfile.s_interested.text && [currentProfile.s_interested.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self addToTableSourceWithKey:@"viewprofile_interested_in_icon" andValue:currentProfile.s_interested.text];
    }
    
    [self addToTableSourceWithKey:@"viewprofile_viewicon" andValue:[NSString stringWithFormat:@"%d", currentProfile.num_Viewed]];
    
    [self addToTableSourceWithKey:@"viewprofile_likeicon" andValue:[NSString stringWithFormat:@"%d", currentProfile.num_Liked]];
}

-(void)addToTableSourceWithKey:(NSString *)key andValue:(NSString *)value
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", value, @"value", nil];
    
    [tableSource addObject:dict];
}

-(void)refreshScrollView{
    for (UIImageView * view in self.svPhotos.subviews) {
        [view removeFromSuperview];
    }
    
    [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    self.svPhotos.frame = CGRectMake(0, 0, 320, 320);
    
    
    self.numOfPhotoAndVideo = [currentProfile.arr_photos count];
    
    //error on navigation bar when play video finish
    if (currentProfile.s_video && ![@"" isEqualToString:currentProfile.s_video])
    {
        self.numOfPhotoAndVideo += 1;
    }
    
    self.svPhotos.contentSize = CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, CGRectGetHeight(self.svPhotos.frame));

    for(int i = 0; i < self.numOfPhotoAndVideo; i++)
    {
        [self addIndicatorAtIndex:i];
        [self hideIndicatorAtIndex:i];
        [self addErrorLabelAtIndex:i];
        [self hideErrorLabelAtIndex:i];
    }
}

- (void)useSnapshotAvatar {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:img_avatar];
    CGRect frame = self.svPhotos.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    imageView.frame = frame;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.svPhotos addSubview:imageView];
}

-(void)loadPhotoForScrollview{
    if(currentProfile.arr_photos != nil && [currentProfile.arr_photos count]>0)
    {
        [photoCount setText:[NSString stringWithFormat:@"%i/%i",1,[currentProfile.arr_photos count]]];
        
        if (currentProfile.s_video && ![@"" isEqualToString:currentProfile.s_video])
        {
            [self.videoCount setText:@"1"];
            self.btnPlayVideo.hidden = NO;
        } else {
            [self.videoCount setText:@"0"];
            self.btnPlayVideo.hidden = YES;
        }
        
        if([currentProfile.arr_photos count] == 0)
        {
            [loadingAvatar stopAnimating];
            loadingAvatar.hidden = YES;
        }
        else
        {
            const int videoIndex = 1;
            for(int i = 0; i < self.numOfPhotoAndVideo; i++)
            {
                [self showIndicatorAtIndex:i];
                
                int photoIndex = i;
                if (photoIndex > videoIndex)
                {
                    --photoIndex;
                }
                
                NSString* link = @"";
                if (currentProfile.s_video && ![@"" isEqualToString:currentProfile.s_video] && i == videoIndex){
                    link = [currentProfile.s_video stringByReplacingOccurrencesOfString:@".mov" withString:@".jpg"];
                } else {
                    link = [[currentProfile.arr_photos objectAtIndex:photoIndex] objectForKey:key_photoLink];
                }
                
                if(![link isEqualToString:@""] )
                {
                    [userImagePool getImageAtURL:link withSize:PHOTO_SIZE_LARGE asycn:^(UIImage *image, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
                        if (error) {
                            [self hideIndicatorAtIndex:i];
                            [self showErrorLabelAtIndex:i];
                        }
                        else if (image)
                        {
                            UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                            CGRect frame = CGRectMake(0, 0, 320, 320);
                            frame.origin.x = CGRectGetWidth(frame) * i ;
                            frame.origin.y = 0;
                            imageView.frame = frame;
                            [imageView setContentMode:UIViewContentModeScaleAspectFit];
                            [self.svPhotos addSubview:imageView];
                            
                            if (i == videoIndex) {
                                if (currentProfile.s_video && ![@"" isEqualToString:currentProfile.s_video]){
                                    [self addVideoButtonAtIndex:videoIndex];
                                }
                            }
                        }
                    }];
                }
            }
        }
        
    }
}

- (void)addErrorLabelAtIndex:(int)i
{
    CGRect frame = CGRectMake(0, 0, 320, 320);
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) * i + CGRectGetWidth(frame)/2 - 50/2, CGRectGetHeight(frame)/2,200,20)];
    errorLabel.text = [NSString stringWithFormat:@"%@!", [@"Error" localize]];
    errorLabel.textColor = [UIColor whiteColor];
    
    //bug: insert
    [self.errorLabelArray addObject:errorLabel];
    [self.svPhotos addSubview:errorLabel];
}

- (void)showErrorLabelAtIndex:(int)i
{
    UILabel *label = [self.errorLabelArray objectAtIndex:i];
    if (label) {
        label.hidden = NO;
    }
}

- (void)hideErrorLabelAtIndex:(int)i
{
    UILabel *label = [self.errorLabelArray objectAtIndex:i];
    if (label) {
        label.hidden = YES;
    }
}

- (void)addIndicatorAtIndex:(int)i
{
    CGRect frame = CGRectMake(0, 0, 320, 320);
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) * i + CGRectGetWidth(frame)/2 - 50/2, CGRectGetHeight(frame)/2,50,50)];
    [indicator startAnimating];
    
    //bug: insert
    [self.indicatorArray addObject:indicator];
    [self.svPhotos addSubview:indicator];
}

- (void)showIndicatorAtIndex:(int)i
{
    UIActivityIndicatorView *indicator = [self.indicatorArray objectAtIndex:i];
    if (indicator) {
        indicator.hidden = NO;
    }
}

- (void)hideIndicatorAtIndex:(int)i
{
    UIActivityIndicatorView *indicator = [self.indicatorArray objectAtIndex:i];
    if (indicator) {
        indicator.hidden = YES;
    }
}

- (void)addVideoButtonAtIndex:(int)i
{
    CGRect frame = CGRectMake(0, 0, 320, 320);
    self.btnPlayVideo.frame = CGRectMake(CGRectGetWidth(frame) * i + CGRectGetWidth(frame)/2 - 68/2, CGRectGetHeight(frame)/2,68,76);
    [self.svPhotos addSubview:self.btnPlayVideo];
}

-(IBAction)onTouchAddToFavorite:(id)sender{
    // add to favorite list
    UIButton *btnpop= sender;
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id", nil];
    if(btnpop.selected){
        [request getPath:URL_removeMyFavorite parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
         {
             NSError *e=nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
             int status= (int)[dict valueForKey:key_status];
             if(status)
                 NSLog(@"URL_removeMyFavorite Success!");
             else
                 NSLog(@"URL_removeMyFavorite Faild!");
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"URL_addToMyFavorite Error Code: %i - %@",[error code], [error localizedDescription]);
         }];
    }else{
        [request getPath:URL_addToMyFavorite parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
         {
             NSError *e=nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
             int status= (int)[dict valueForKey:key_status];
             if(status)
                 NSLog(@"URL_addToMyFavorite Success!");
             else
                 NSLog(@"URL_addToMyFavorite Faild!");
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"URL_addToMyFavorite Error Code: %i - %@",[error code], [error localizedDescription]);
         }];
    }
    
    [btnpop setSelected:!btnpop.selected];
    if(btnAddToFavorite.selected || btnIwantToMeet.selected)
       [self.btnLike setSelected:YES];
    else
       [self.btnLike setSelected:NO];
}

-(IBAction)onTouchWantToMeet:(id)sender{
    // add to want to meet list
    UIButton *btnpop= sender;
    NSString *setValue;
    if(btnpop.selected){
        setValue = @"2";
    }
    else
    {
        setValue =@"1";
    }
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id",setValue,@"set", nil];
    
    [request getPath:URL_setIWantToMeet parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         int status= (int)[dict valueForKey:key_status];
         if(status)
             NSLog(@"URL_setIWantToMeet Success!");
         else
             NSLog(@"URL_setIWantToMeet Faild!");
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"URL_setIWantToMeet Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
    [btnpop setSelected:!btnpop.selected];
    if(btnAddToFavorite.selected || btnIwantToMeet.selected)
        [self.btnLike setSelected:YES];
    else
        [self.btnLike setSelected:NO];
}
- (IBAction)onTouchBlock:(id)sender {
    UIButton *btnpop= sender;
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id", nil];
    if(btnpop.selected){
        [request getPath:URL_unBlockHangoutProfile parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
         {
             NSError *e=nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
             int status= (int)[dict valueForKey:key_status];
             if(status)
                 NSLog(@"URL_unBlockHangoutProfile Success!");
             else
                 NSLog(@"URL_unBlockHangoutProfile Faild!");
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"URL_unBlockHangoutProfile Error Code: %i - %@",[error code], [error localizedDescription]);
         }];
    }
    else
    {
        [request getPath:URL_blockHangoutProfile parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
         {
             NSError *e=nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
             int status= (int)[dict valueForKey:key_status];
             if(status)
                 NSLog(@"URL_blockHangoutProfile Success!");
             else
                 NSLog(@"URL_blockHangoutProfile Faild!");
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"URL_blockHangoutProfile Error Code: %i - %@",[error code], [error localizedDescription]);
         }];
    }
    
    [btnpop setSelected:!btnpop.selected];
    [self.btnReport setSelected:btnpop.selected];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesBegan");
    [likePopoverView.view removeFromSuperview];
    [reportPopoverView.view removeFromSuperview];
}

// tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableSource count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"ProfileCellIdentifier";
    
	ProfileInfoCell *cell = (ProfileInfoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        [cell.imgViewTitle setContentMode:UIViewContentModeScaleAspectFit];
	}
    cell.imgViewTitle.image = [UIImage imageNamed:[[tableSource objectAtIndex:indexPath.row] valueForKey:@"key"]];
    cell.lblDetail.text = [[tableSource objectAtIndex:indexPath.row] valueForKey:@"value"];
    return cell;
}

#pragma mark left item bar
-(void) addDoneItemController{
    UIImageView* controlBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, IS_OS_7_OR_LATER?20:0, 320, 46)];
    [controlBG setImage:[UIImage imageNamed:@"viewprofile_Bar_BG.png"]];
    [self.view addSubview:controlBG];
    UIButton* btnDone = [[UIButton alloc]initWithFrame:CGRectMake(8,IS_OS_7_OR_LATER?26:6, 51, 34)];
    [btnDone setTitle:[@"Done" localize] forState:UIControlStateNormal];
    [btnDone.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15)];
    [btnDone.titleLabel setTextColor:[UIColor whiteColor]];
    btnDone.titleLabel.adjustsFontSizeToFitWidth = YES;
//    [btnDone.titleLabel setText:@"Done"];
    [btnDone setBackgroundImage:[UIImage imageNamed:@"viewprofile_done.png"] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];

    //update position of view for iOS7
    if (IS_OS_7_OR_LATER) {
        scrollview.frame = CGRectMake(0, scrollview.frame.origin.y+20, scrollview.frame.size.width, scrollview.frame.size.height);
    }
}

-(void)backToPreviousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addTopLeftButtonWithAction:(SEL)action
{
    UIButton* buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(0, 0, 57, 40);
    [buttonBack addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_back.png"] forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_back_pressed.png"] forState:UIControlStateHighlighted];
    
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
}
#pragma mark Scrollview delegate
BOOL allowFullScreen = FALSE;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollOffset = scrollView.contentOffset.y;
    if(scrollView.tag ==2)
    {
        int index =scrollView.contentOffset.x/scrollView.frame.size.width;
        if (index + 1 <= [currentProfile.arr_photos count]) {
            [photoCount setText:[NSString stringWithFormat:@"%i/%i",index + 1,[currentProfile.arr_photos count]]];
        }
    }
    
    if(scrollView.tag == 1 && allowFullScreen)
    {
        NSLog(@"content offset : %f",scrollOffset);
        float screenHeight = self.view.frame.size.height;
        if (!IS_OS_7_OR_LATER)
        {
            screenHeight += 26;
        }
        
        if(self.svPhotos.frame.size.height < screenHeight  && scrollOffset < 0)
        {
            if(self.svPhotos.frame.size.height >= screenHeight - 80){
                [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight)];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, screenHeight, self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [self snapPhotoBarToBottomOfView];
            }
            else
            {
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height + fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y +fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(0, 0)];
                [self snapPhotoBarToBottomOfView];
            }
        }
        else
        {
            if(self.svPhotos.frame.size.height > 320 && scrollOffset > 0){
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height -  fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y - fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [self snapPhotoBarToBottomOfView];
                [scrollView setContentOffset:CGPointMake(0, 0)];
            }
        }
        [self updateSubviewsToCenterScrollView];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    float scrollOffset = scrollView.contentOffset.y;
    if(scrollOffset == 0)
        allowFullScreen = TRUE;
    NSLog(@"scrollViewWillBeginDragging - content offset : %f", scrollOffset);
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    allowFullScreen = FALSE;
    float screenHeight = self.view.frame.size.height;
    if (!IS_OS_7_OR_LATER)
    {
        screenHeight += 26;
    }
    if(self.svPhotos.frame.size.height < screenHeight - 80){
        
        [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, 320/*294*/)];
        self.svPhotos.contentSize =
        CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, CGRectGetHeight(self.svPhotos.frame));
        [self.infoView setFrame:CGRectMake(0, self.svPhotos.frame.size.height, self.infoView.frame.size.width, self.infoView.frame.size.height)];
        [self updateSubviewsToCenterScrollView];
        [self snapPhotoBarToBottomOfView];
    }
}

-(void)updateSubviewsToCenterScrollView
{
    for(UIImageView* imageView in [self.svPhotos subviews])
    {
        imageView.center = CGPointMake(imageView.center.x, self.svPhotos.center.y);
    }
}

-(void)snapPhotoBarToBottomOfView{
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear )
                     animations:^{
                        [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width, self.lblsPhoto.frame.size.height)];
                     }
                     completion:^(BOOL finished) {

                     }
     ];
    
}
- (IBAction)nextPhotoButtonTouched:(id)sender
{
    int index = svPhotos.contentOffset.x/svPhotos.frame.size.width;
    if (index < svPhotos.subviews.count - 2)
    {
        [self.svPhotos setContentOffset:CGPointMake(svPhotos.frame.size.width * (++index), svPhotos.contentOffset.y) animated:YES];
    }
}

- (IBAction)previousPhotoButtonTouched:(id)sender {
    
    int index = svPhotos.contentOffset.x/svPhotos.frame.size.width;
    if (index > 0)
    {
        [self.svPhotos setContentOffset:CGPointMake(svPhotos.frame.size.width * (--index), svPhotos.contentOffset.y) animated:YES];
    }
}

-(void)onTapOnPhotos:(UITapGestureRecognizer *)photos
{
    float screenHeight = [[UIScreen mainScreen]applicationFrame].size.height;//self.view.frame.size.height;
    if (!IS_OS_7_OR_LATER)
    {
        screenHeight += 26;
    }
    if (self.svPhotos.frame.size.height != screenHeight)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: (UIViewAnimationOptionCurveLinear)
                         animations:^{
                             [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight)];
                             self.svPhotos.contentSize =
                             CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * self.numOfPhotoAndVideo, screenHeight);
                             [self.infoView setFrame:CGRectMake(0, screenHeight, self.infoView.frame.size.width, self.infoView.frame.size.height)];
                             [self updateSubviewsToCenterScrollView];
                         }
                         completion:^(BOOL finished) {
                             [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
                         }
         ];
        
        [self snapPhotoBarToBottomOfView];
    }
    else
    {
        VCSimpleSnapshot *VCSSnapshot = appDel.simpleSnapShot.viewControllers[0];
        [VCSSnapshot backToSnapshotViewWithAnswer:-1];
    }
}

- (IBAction)playVideoTouched:(id)sender {
    VCSimpleSnapshot *VCSSnapshot = appDel.simpleSnapShot.viewControllers[0];
    VCSSnapshot.controlView.hidden = YES;
    
    NSURL *videoURL = [NSURL URLWithString:currentProfile.s_video];
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    
    [moviePlayer.moviePlayer play];
}

- (void)finishPlayVideoClick:(NSNotification*)aNotification{
    VCSimpleSnapshot *VCSSnapshot = appDel.simpleSnapShot.viewControllers[0];
    if (VCSSnapshot && [VCSSnapshot isKindOfClass:[VCSimpleSnapshot class]]) {
        VCSSnapshot.controlView.hidden = NO;
    }
}

-(void)ontouchViewVideo:(id)button
{
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", DOMAIN_DATA, currentProfile.s_video]];
    MPMoviePlayerController *theMoviPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    theMoviPlayer.controlStyle = MPMovieControlStyleFullscreen;
    theMoviPlayer.view.transform = CGAffineTransformConcat(theMoviPlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    [theMoviPlayer.view setFrame:backgroundWindow.frame];
    [backgroundWindow addSubview:theMoviPlayer.view];
    [theMoviPlayer play];
}

- (IBAction)onTouchMoreOption:(id)sender {
    VCSimpleSnapshot *VCSSnapshot = appDel.simpleSnapShot.viewControllers[0];
    
    VCReportPopup* reportPopup= [[VCReportPopup alloc] initWithProfileID:currentProfile andChat:VCSSnapshot];
    [reportPopup.view setFrame:CGRectMake(0, 0, reportPopup.view.frame.size.width, reportPopup.view.frame.size.height)];
    
    [VCSSnapshot.navigationController pushViewController:reportPopup animated:YES];
}

- (IBAction)onTouchVipChat:(id)sender {
    VCSimpleSnapshot *VCSSnapshot = appDel.simpleSnapShot.viewControllers[0];
    [VCSSnapshot openVipChat];
}
@end
