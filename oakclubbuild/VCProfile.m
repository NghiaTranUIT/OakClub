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

@interface VCProfile (){
//    BOOL popoverShowing;
    AFHTTPClient *request;
}
@property (weak, nonatomic) IBOutlet UIView *aboutView;
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
@property BOOL showNavigationBar;
@end

@implementation VCProfile
@synthesize lbl_name, imgView_avatar, scrollview,lblAboutMe,lblBirthdate,lblGender, lblInterested, lblLocation, lblProfileName, lblRelationShip, likePopoverView, reportPopoverView, lblEthnicity, lblAge, lblPopularity, lblWanttoMake, btnAddToFavorite, btnIwantToMeet, btnBlock, btnChat, tableViewProfile, svPhotos,infoView, photoPageControl, photoCount,lblDistance, lblActive;

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
//        self.svPhotos = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 275)];
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
						  lineBreakMode:UILineBreakModeWordWrap];
    
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
/*
-(void)initMutualFriendsList
{
    if(currentProfile.num_MutualFriends == 0)
    {
        //[labelMutualFriends setHidden:NO];
        self.mutualFriendsView.hidden = YES;
        
        self.profileView.frame = [self moveToFrame:self.mutualFriendsView.frame from:self.profileView.frame];
        //update height of scrollview to fit screen.
        CGFloat offset  = self.profileView.frame.origin.y + ( ([tableSource count]+1) * tableViewProfile.rowHeight) + 22*2;
        [self.infoView setFrame:CGRectMake(0, 320, 320, offset)];
    }
    else
    {
        self.mutualFriendsView.hidden = NO;
        for(int i = 0 ; i < currentProfile.num_MutualFriends; i++)
        {
            ImageInfo* p = [currentProfile.arr_MutualFriends objectAtIndex:i];
            
            NSString* link = p.avatar;
            
            //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            if(![link isEqualToString:@""])
            {
                AFHTTPRequestOperation *operation =
                [Profile getAvatarSync:link
                              callback:^(UIImage *avatar)
                 {
                     UIImageView *imageView = [[UIImageView alloc] initWithImage:avatar];
                     
                     // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
                     CGRect rect = imageView.frame;
                     rect.size.height = 58;
                     rect.size.width = 58;
                     
                     imageView.tag = i;	// tag our images for later use when we place them in serial fashion
                     
                     rect.origin.y = ( mutualFriendsImageView.frame.size.height - rect.size.height - 15) / 2;
                     rect.origin.x = i * (58 + 5);
                     
                     imageView.frame = rect;
                     
                     UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, 58, 15)];
                     [name setBackgroundColor:[UIColor clearColor]];
                     [name setFont:FONT_HELVETICANEUE_LIGHT(10.0)];
                     name.text = p.name;
                     [mutualFriendsImageView addSubview:imageView];
                     [mutualFriendsImageView addSubview:name];
                 }];
                [operation start];
                //[queue addOperation:operation];
                
            }
            
        }
        mutualFriendsImageView.contentSize = CGSizeMake( currentProfile.num_MutualFriends * (58 + 5), 58 + 5);
        [mutualFriendsImageView removeFromSuperview];
        
        mutualFriendsImageView.frame = [self addRelative:mutualFriendsImageView.frame addPoint:self.mutualFriendsView.frame.origin];
        [scrollview addSubview:mutualFriendsImageView];
        [scrollview setContentSize:CGSizeMake(scrollview.frame.size.width, scrollview.contentSize.height + self.mutualFriendsView.frame.size.height)];
        NSLog(@"Mutual Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    
}

-(void)initMutualInterestsList
{
    if([currentProfile.arr_MutualInterests count] == 0)
    {
        //[labelMutualFriends setHidden:NO];
        self.interestsView.hidden = YES;
        
        self.profileView.frame = [self moveToFrame:self.interestsView.frame from:self.profileView.frame];
        //update height of scrollview to fit screen.
        CGFloat offset  = self.profileView.frame.origin.y + ( ([tableSource count]+1) * tableViewProfile.rowHeight) + 22*2;
        [self.infoView setFrame:CGRectMake(0, 320, 320, offset)];
    }
    else
    {
        self.interestsView.hidden = NO;
        for(int i = 0 ; i < [currentProfile.arr_MutualInterests count]; i++)
        {
            ImageInfo* p = [currentProfile.arr_MutualInterests objectAtIndex:i];
            
            NSString* link = p.avatar;
            
            //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            if(![link isEqualToString:@""])
            {
                AFHTTPRequestOperation *operation =
                [Profile getAvatarSync:link
                              callback:^(UIImage *avatar)
                 {
                     UIImageView *imageView = [[UIImageView alloc] initWithImage:avatar];
                     
                     // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
                     CGRect rect = imageView.frame;
                     rect.size.height = 58;
                     rect.size.width = 58;
                     
                     imageView.tag = i;	// tag our images for later use when we place them in serial fashion
                     
                     rect.origin.y = ( scrollViewInterest.frame.size.height - rect.size.height - 15) / 2;
                     rect.origin.x = i * (58 + 5);
                     
                     imageView.frame = rect;
                     
                     UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, 58, 15)];
                     [name setBackgroundColor:[UIColor clearColor]];
                     [name setFont:FONT_HELVETICANEUE_LIGHT(10.0)];
                     name.text = p.name;
                     [scrollViewInterest addSubview:imageView];
                     [scrollViewInterest addSubview:name];
                 }];
                [operation start];
                //[queue addOperation:operation];
                
            }
            
        }
        scrollViewInterest.contentSize = CGSizeMake( [currentProfile.arr_MutualInterests count] * (58 + 5), 58 + 5);
        [scrollViewInterest removeFromSuperview];
        
        scrollViewInterest.frame = [self addRelative:scrollViewInterest.frame addPoint:self.interestsView.frame.origin];
        [scrollview addSubview:scrollViewInterest];
        [scrollview setContentSize:CGSizeMake(scrollview.frame.size.width, scrollview.contentSize.height + self.interestsView.frame.size.height)];
        NSLog(@"Mutual Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    
}
*/
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
    if(currentProfile.distance < 1){
        [lblDistance setText:[@"Less than a km away" localize]];
        return;
    }
    if(currentProfile.distance < 40){
        [lblDistance setText:[NSString stringWithFormat:@"%i km away", currentProfile.distance]];
        return;
    }
    [lblDistance setText:[@"more than 40 km away" localize]];
}

-(void)LoadActiveText{
    if(currentProfile.active == -1){
        [lblActive setText:[@"Online" localize]];
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
    [lblActive setText:[@"more than 5 days ago" localize]];
}

-(void)loadInfoView{
    lbl_name.text = currentProfile.s_Name;
    lblAge.text = [NSString stringWithFormat:@"%@",currentProfile.s_age];
    self.lblnViews.text = [NSString stringWithFormat:@"%i", currentProfile.num_Viewed];
    self.lblnLikes.text = [NSString stringWithFormat:@"%i", currentProfile.num_Liked];
    [self LoadDistanceText];
    [self LoadActiveText];
    // SCROLL SIZE
    [scrollview setContentSize:CGSizeMake(320, 790)];
    NSLog(@"Init Content size: %f - %f", scrollview.contentSize.width, infoView.frame.origin.y);
    
    self.lblAboutMe.text = [currentProfile s_aboutMe];
    if ([lblAboutMe.text length] <= 0) {
        self.aboutView.hidden = YES;
        self.mutualFriendsView.frame = [self moveToFrame:self.interestsView.frame from:self.mutualFriendsView.frame];
        self.interestsView.frame = [self moveToFrame:self.aboutView.frame from:self.interestsView.frame];
    }
    else{
        self.aboutView.hidden = NO;
        lblAboutMe.numberOfLines = 0;
        [lblAboutMe sizeToFit];
        CGRect newAboutFrame = CGRectMake(self.aboutView.frame.origin.x,
                                          self.aboutView.frame.origin.y,
                                          self.aboutView.frame.size.width,
                                          self.lblAboutMe.frame.size.height + self.lblAboutMe.frame.origin.x);
        NSInteger deltaPosition = abs(self.aboutView.frame.size.height - newAboutFrame.size.height);
        self.mutualFriendsView.frame = CGRectMake(self.mutualFriendsView.frame.origin.x, self.mutualFriendsView.frame.origin.y + deltaPosition, self.mutualFriendsView.frame.size.width, self.mutualFriendsView.frame.size.height);
        self.interestsView.frame = CGRectMake(self.interestsView.frame.origin.x, self.interestsView.frame.origin.y + deltaPosition, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.aboutView.frame.size.height)];
    }
    if( currentProfile.arr_MutualInterests && [currentProfile.arr_MutualInterests count] > 0)
    {
        NSLog(@"Before Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
        self.interestsView.hidden = NO;
        [self loadInterestedThumbnailList:currentProfile.arr_MutualInterests andContentView:self.interestsView andScrollView:self.scrollViewInterest];
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.interestsView.frame.size.height)];
        NSLog(@"Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    else
    {
        self.interestsView.hidden = YES;
//        self.profileView.frame = [self moveToFrame:self.mutualFriendsView.frame from:self.profileView.frame];
        self.mutualFriendsView.frame = [self moveToFrame:self.interestsView.frame from:self.mutualFriendsView.frame];
    }
    
    if( currentProfile.arr_MutualFriends && [currentProfile.arr_MutualFriends count] > 0)
    {
        NSLog(@"Before Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
        self.mutualFriendsView.hidden = NO;
        [self loadInterestedThumbnailList:currentProfile.arr_MutualFriends andContentView:self.mutualFriendsView andScrollView:self.mutualFriendsImageView];
        [scrollview setContentSize:CGSizeMake(scrollview.contentSize.width, scrollview.contentSize.height + self.mutualFriendsView.frame.size.height)];
        NSLog(@"Interest Content size: %f - %f", scrollview.contentSize.width, scrollview.contentSize.height);
    }
    else
    {
        
        self.mutualFriendsView.hidden = YES;
//        self.profileView.frame = [self moveToFrame:self.mutualFriendsView.frame from:self.profileView.frame];
//        self.mutualFriendsView.frame = [self moveToFrame:self.interestsView.frame from:self.mutualFriendsView.frame];
    }
//    [self initMutualInterestsList];
//    [self initMutualFriendsList];
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
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:((int) rect.size.width)], @"width",
                                [NSNumber numberWithInt:((int) rect.size.height)], @"height", nil];
        AFHTTPClient *downloadFAVIcon = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fav.avatar]];
        [downloadFAVIcon registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        NSMutableURLRequest *iconRequest = [downloadFAVIcon requestWithMethod:@"GET"
                                                                path:nil
                                            parameters:params];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:iconRequest];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             UIImage *img = [UIImage imageWithData:responseObject];
             
             [favIcon setImage:img];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Download image Error: %@", error);
         }];
        
        [operation start];
        
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, 58, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setFont:FONT_HELVETICANEUE_LIGHT(10.0)];
        name.text = fav.name;
        [contentScroll addSubview:favIcon];
        [contentScroll addSubview:imageView];
        [contentScroll addSubview:name];
    }
    
    contentScroll.contentSize = CGSizeMake( [favList count] * (58 + 5), 58 + 5);
    
    contentScroll.frame = [self addRelative:contentScroll.frame addPoint:CGPointMake(self.infoView.frame.origin.x, self.infoView.frame.origin.y + contentView.frame.origin.y) ];
    [scrollview addSubview:contentScroll];
    if (currentProfile.s_video != nil && ![@"" isEqualToString:currentProfile.s_video])
    {
        CGRect rect;;
        rect.size.height = 58;
        rect.size.width = 58;
        
        rect.origin.y = (scrollViewInterest.frame.size.height - rect.size.height - 15) / 2;
        rect.origin.x = scrollViewInterest.contentSize.width;
        
        UIButton *viewVideo = [[UIButton alloc] initWithFrame:rect];
        [viewVideo setBackgroundImage:[UIImage imageNamed:@"viewprofile_videoicon"] forState:UIControlStateNormal];
        [viewVideo addTarget:self action:@selector(ontouchViewVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollViewInterest addSubview:viewVideo];
    }
    
    scrollViewInterest.frame = [self addRelative:scrollViewInterest.frame addPoint:CGPointMake(self.infoView.frame.origin.x, self.infoView.frame.origin.y + self.interestsView.frame.origin.y) ];
    [scrollview addSubview:scrollViewInterest];
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
    UIImageView *imageView = [[UIImageView alloc]initWithImage:img_avatar];
    CGRect frame = self.svPhotos.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    imageView.frame = frame;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.svPhotos addSubview:imageView];
    
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
    [self loadInfoView];
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
    
    [self customNavHeader];
    
    [self refreshScrollView];
    [self loadPhotoForScrollview];
}

-(void) viewWillAppear:(BOOL)animated{
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
    [super viewDidUnload];
}

#pragma mark Custom view
-(void)customNavHeader
{
    if(!IS_HEIGHT_GTE_568)
        [self.navigationController.navigationBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self customBackButtonBarItem];
    self.lblTabBarName.frame = CGRectMake(60, 0, self.lblTabBarName.frame.size.width, 44);
    self.lblTabBarName.text = currentProfile.s_Name;
    [self.navigationController.navigationBar addSubview:self.lblTabBarName];

}


//- (void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:NO];
//}

//-(void)checkAddedToFavorite{
//    [btnAddToFavorite setSelected:NO];
//    [request getPath:URL_getListMyFavorites parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
//        NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
//        NSError *e=nil;
//        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//        NSMutableArray * data= [dict valueForKey:key_data];
//        if(![data isKindOfClass:[NSNull class]]){
//            for (int i = 0; i < [data count]; i++) {
//                NSMutableDictionary *objectData = [data objectAtIndex:i];
//                NSString * temp = [objectData valueForKey:key_profileID];
//                if([currentProfile.s_ID isEqualToString: temp]){
//                    [btnAddToFavorite setSelected:YES];
//                    [self.btnLike setSelected:YES];
//                    return;
//                }
//            }
//        }
//       
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//    }];
//}

-(void)checkAddedToBlockList{
    [btnBlock setSelected:NO];
    [request getPath:URL_getListBlocking parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
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
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

-(void)checkAddedToWantToMeet{
    [btnIwantToMeet setSelected:NO];
    [request getPath:URL_getListIWantToMeet parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
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
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
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
//    if(popoverShowing){
//        [controller.view removeFromSuperview];//:controller.view];
//    }else{
        [self.view addSubview:controller.view];
//    }
//    popoverShowing = !popoverShowing;
    
//    [controller setContentSizeForViewInPopover:CGSizeMake(380, 200)];
//    pop= [[UIPopoverController alloc] initWithContentViewController:controller];
//    [pop setPopoverContentSize:CGSizeMake(400, 148)];
//    [pop setDelegate:self];
//    CGRect popFrame = button.frame;
//    popFrame.origin.x = 0;
//    popFrame.origin.y = 0;
//    popFrame.size.width = 1;
//    popFrame.size.height = 1;
//    NSLog(@"widht view : %f",self.view.frame.size.width);
//    [pop presentPopoverFromRect:popFrame inView:self.view permittedArrowDirections:nil animated:YES];
//    UIView * border = [[controller.view.superview.superview.superview subviews] objectAtIndex:0];
////    border.frame = CGRectMake(0, 0, 0, 0);
//    border.hidden = YES;
}

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
        AppDelegate* appDel = [self appDelegate];
        
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

    
//    else
//    {
//        [self dismissViewControllerAnimated:YES completion:^{
//            
//        }];
        
//        [self dismissViewControllerAnimated:YES completion:^
//         {
//             [self.navigationController popViewControllerAnimated:NO];
//         }];
//    }
}
- (IBAction)onDoneClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark loadProfile functions
//-(void) loadProfile:(Profile*) _profile andImage:(UIImage*)_avatar{
//    img_avatar = _avatar;
//    currentProfile = _profile;
//}
-(void) loadProfile:(Profile*) _profile andImage:(UIImage*)_avatar{
    currentProfile = _profile;
    img_avatar = _avatar;
    
    NSLog(@"Set VCProfile profile avatar: %@", currentProfile.s_Avatar);
//    [self refreshScrollView];
//    [self loadPhotoForScrollview];
}

-(void) loadProfile:(Profile*) _profile{
    currentProfile = _profile;
//    [self refreshScrollView];
//    [self loadPhotoForScrollview];
}

-(void)refreshScrollView{
    for (UIImageView * view in self.svPhotos.subviews) {
        [view removeFromSuperview];
    }
//    self.svPhotos= [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    self.svPhotos.frame = CGRectMake(0, 0, 320, 320);
}
-(void)loadPhotoForScrollview{
         NSArray* _imagesData;
         if(currentProfile.arr_photos != nil && [currentProfile.arr_photos count]>0)
         {
             _imagesData = [[NSArray alloc]initWithArray: currentProfile.arr_photos];
             
             if([_imagesData count] == 0)
             {
                 [loadingAvatar stopAnimating];
                 loadingAvatar.hidden = YES;
             }
             else
             {
                 for(int i = 0; i < [currentProfile.arr_photos count]; i++)
                 {
                     if(![[currentProfile.arr_photos objectAtIndex:i] isKindOfClass:[UIImage class]]){
                         NSString* link = [currentProfile.arr_photos objectAtIndex:i];
                         NSLog(@"VCProfile load avatar index: %d, link: %@", i, link);
                         if(![link isEqualToString:@""] )
                         {
                             AFHTTPRequestOperation *operation =
                             [Profile getAvatarSync:link
                                           callback:^(UIImage *image)
                              {
                                  UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                                  CGRect frame = self.svPhotos.frame;
                                  frame.origin.x = CGRectGetWidth(frame) * i ;
                                  frame.origin.y = 0;
                                  imageView.frame = frame;
                                  [imageView setContentMode:UIViewContentModeScaleAspectFit];
                                  [self.svPhotos addSubview:imageView];
                                  self.svPhotos.contentSize =
                                  CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * (i+1), CGRectGetHeight(self.svPhotos.frame));
                                  [currentProfile.arr_photos replaceObjectAtIndex:i withObject:image];
                                  [photoCount setText:[NSString stringWithFormat:@"%i/%i",1,(i+1)]];
                              }];
                             [operation start];
                         }
                     }
                     else{
                         UIImageView *imageView = [[UIImageView alloc]initWithImage:[currentProfile.arr_photos objectAtIndex:i]];
                         CGRect frame = self.svPhotos.frame;
                         frame.origin.x = CGRectGetWidth(frame)*i;
                         frame.origin.y = 0;
                         imageView.frame = frame;
                         [imageView setContentMode:UIViewContentModeScaleAspectFit];
                         [self.svPhotos addSubview:imageView];
                         self.svPhotos.contentSize =
                         CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * (i+1), CGRectGetHeight(self.svPhotos.frame));
                         [photoCount setText:[NSString stringWithFormat:@"%i/%i",1,(i+1)]];
                     }
                 }
                 
             }
             
         }
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
    return 21;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"ProfileCellIdentifier";
    
	ProfileCell *cell = (ProfileCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
	}
    NSString* cellKeyName = [[tableSource objectAtIndex:indexPath.row] valueForKey:@"key"];
    [cell setNames:[[tableSource objectAtIndex:indexPath.row] valueForKey:@"value"] AndKeyName:[NSString localizeString:cellKeyName]];
    return cell;
}

#pragma mark left item bar
-(void)backToPreviousView
{
    UINavigationController* activeVC = [[self appDelegate] activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if([vc isKindOfClass:[VCSnapshoot class]] )
    {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
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
        [photoCount setText:[NSString stringWithFormat:@"%i/%i",index + 1,[currentProfile.arr_photos count]]];
    }
    
    if(scrollView.tag == 1 && allowFullScreen)
    {
        NSLog(@"content offset : %f",scrollOffset);
        float screenHeight = self.view.frame.size.height;
        if (IS_OS_7_OR_LATER)
        {
            screenHeight += 100;
        }
        
        if(self.svPhotos.frame.size.height < screenHeight  && scrollOffset < 0)
        {
            if(self.svPhotos.frame.size.height >= screenHeight - 80){
                [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight)];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, screenHeight, self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - 2*self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width,  self.lblsPhoto.frame.size.height)];

//                CGRect interestFrame = scrollViewInterest.frame;
//                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, screenHeight , interestFrame.size.width, interestFrame.size.height)];
            }
            else
            {
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height +  fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y +fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(0, 0)];
                
                [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width, self.lblsPhoto.frame.size.height)];
                
//                CGRect interestFrame = scrollViewInterest.frame;
//                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, fabsf(scrollOffset) + interestFrame.origin.y, interestFrame.size.width, interestFrame.size.height)];
            }
        }
        else
        {
            if(self.svPhotos.frame.size.height > 320 && scrollOffset > 0){
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height -  fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y - fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width, self.lblsPhoto.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(0, 0)];
//                CGRect interestFrame = scrollViewInterest.frame;
//                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, interestFrame.origin.y - fabsf(scrollOffset), interestFrame.size.width, interestFrame.size.height)];
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
    if (IS_OS_7_OR_LATER)
    {
        screenHeight += 100;
    }
    if(self.svPhotos.frame.size.height < screenHeight - 80){
        
        [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, 320)];
        self.svPhotos.contentSize =
        CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
        [self.infoView setFrame:CGRectMake(0, 320, self.infoView.frame.size.width, self.infoView.frame.size.height)];
        [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width, self.lblsPhoto.frame.size.height)];
        [self updateSubviewsToCenterScrollView];
    }
}

-(void)updateSubviewsToCenterScrollView
{
    for(UIImageView* imageView in [self.svPhotos subviews])
    {
        imageView.center = CGPointMake(imageView.center.x, self.svPhotos.center.y);
    }
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
    float screenHeight = self.view.frame.size.height;
    if (IS_OS_7_OR_LATER)
    {
        screenHeight += 100;
    }
    if (self.svPhotos.frame.size.height < screenHeight)
    {
        [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight)];
        self.svPhotos.contentSize =
        CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
        [self.infoView setFrame:CGRectMake(0, screenHeight, self.infoView.frame.size.width, self.infoView.frame.size.height)];
        [self.lblsPhoto setFrame:CGRectMake(0, self.svPhotos.frame.origin.y + self.svPhotos.frame.size.height - 2*self.lblsPhoto.frame.size.height, self.lblsPhoto.frame.size.width,  self.lblsPhoto.frame.size.height)];
        
        [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
        [self updateSubviewsToCenterScrollView];
    }
    else
    {
        
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
@end
