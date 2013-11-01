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
@interface VCProfile (){
//    BOOL popoverShowing;
    AFHTTPClient *request;
}
@property (weak, nonatomic) IBOutlet UIView *mutualFriendsView;
@property (weak, nonatomic) IBOutlet UIView *interestsView;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation VCProfile
@synthesize lbl_name, imgView_avatar, scrollview,lblAboutMe,lblBirthdate,lblGender, lblInterested, lblLocation, lblProfileName, lblRelationShip, likePopoverView, reportPopoverView, lblEthnicity, lblAge, lblPopularity, lblWanttoMake, btnAddToFavorite, btnIwantToMeet, btnBlock, btnChat, tableViewProfile, svPhotos,infoView, photoPageControl, photoCount;

@synthesize labelInterests;
@synthesize mutualFriendsImageView;
@synthesize buttonAvatar;
@synthesize scrollViewInterest;

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

-(void)initMutualFriendsList
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID, key_profileID, nil];
    
    [request getPath:URL_getDetailMutualFriends parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSMutableArray* mutual_friends = [Profile parseMutualFriends:JSON];
         int friends_count = [mutual_friends count];
         
         if(friends_count == 0)
         {
             //[labelMutualFriends setHidden:NO];
             self.mutualFriendsView.hidden = YES;
             
             self.profileView.frame = [self moveToFrame:self.mutualFriendsView.frame from:self.profileView.frame];
             //update height of scrollview to fit screen.
             CGFloat offset  = self.profileView.frame.origin.y + ( ([tableSource count]+1) * tableViewProfile.rowHeight) + 22*2;
             [self.infoView setFrame:CGRectMake(0, 275, 320, offset)];
             
             //SCROLL SIZE
             //[self.scrollview setContentSize:CGSizeMake(320, self.interestsView.frame.size.height+ self.interestsView.frame.origin.y)];
             [self.scrollview setContentSize:CGSizeMake(320, 800)];
         }
         else
         {
             self.mutualFriendsView.hidden = NO;
             for(int i = 0 ; i < friends_count; i++)
             {
                 Profile* p = [mutual_friends objectAtIndex:i];
                 
                 NSString* link = p.s_Avatar;
                 
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
                          [name setFont:FONT_NOKIA(10.0)];
                          name.text = p.s_Name;
                          [mutualFriendsImageView addSubview:imageView];
                          [mutualFriendsImageView addSubview:name];
                      }];
                     [operation start];
                     //[queue addOperation:operation];
                     
                 }
                 
             }
             mutualFriendsImageView.contentSize = CGSizeMake( friends_count * (58 + 5), 58 + 5);
             [mutualFriendsImageView removeFromSuperview];
             
             mutualFriendsImageView.frame = [self addRelative:mutualFriendsImageView.frame addPoint:self.mutualFriendsView.frame.origin];
             [scrollview addSubview:mutualFriendsImageView];
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
     }];

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
            [label setFont:FONT_NOKIA(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.mutualFriendsView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_NOKIA(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.interestsView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_NOKIA(label.font.pointSize)];
        }
    }
    for (UIView *subview in self.profileView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label setFont:FONT_NOKIA(label.font.pointSize)];
        }
    }
}
- (void)viewDidLoad
{
    //show navigation bar
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:1.0f]; //Animation duration in seconds
//    
//    self.navigationController.navigationBar.alpha = 1.0f;
//    
//    [UIView commitAnimations];
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
    [self addTopLeftButtonWithAction:@selector(backToPreviousView)];
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    // Do any additional setup after loading the view from its nib.
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID,@"profile_id", nil];
    [request getPath:URL_getHangoutProfile parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        [currentProfile parseForGetHangOutProfile:JSON];
        lbl_name.text = currentProfile.s_Name;
        lblAge.text = [NSString stringWithFormat:@"%@ , %@ %@",currentProfile.s_age,[NSString localizeString:@"near"],currentProfile.s_location.name];
        lblWanttoMake.text = [NSString stringWithFormat:@"Want to %@",currentProfile.s_meetType];
        lblWanttoMake.text = [lblWanttoMake.text capitalizedString];
        lblWanttoMake.text = [lblWanttoMake.text stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        lblWanttoMake.text = [NSString localizeString:lblWanttoMake.text];
        if(currentProfile.s_Name.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_Name,@"value",@"Name",@"key", nil]];
        }
        if(currentProfile.s_birthdayDate.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_birthdayDate,@"value",@"Birthdate",@"key" ,nil]];
        }
        if(currentProfile.s_interested.text.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_interested.text,@"value",@"Interested In",@"key",nil]];
        }
        if(currentProfile.s_gender.text.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_gender.text,@"value",@"Gender",@"key",nil]];
        }
        if(currentProfile.s_relationShip.rel_text.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_relationShip.rel_text,@"value",@"Relationship",@"key",nil]];
        }
        if(currentProfile.i_height != 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",currentProfile.i_height],@"value",@"Height",@"key",nil]];
        }
        if(currentProfile.i_weight != 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",currentProfile.i_weight],@"value",@"Weight",@"key",nil]];
        }
        if(currentProfile.s_location.name.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_location.name,@"value",@"Location",@"key" ,nil]];
        }
        if(currentProfile.s_school.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_school,@"value",@"School",@"key" ,nil]];
        }
        if([currentProfile.a_language count] >0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:[currentProfile.a_language componentsJoinedByString:@","],@"value",@"Language",@"key" ,nil]];
        }
        if(!([currentProfile.c_ethnicity isKindOfClass:[NSNull class]] || currentProfile.c_ethnicity.text.length <= 0)){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.c_ethnicity.text,@"value",@"Ethnicity",@"key" ,nil]];
        }
        if(currentProfile.s_popularity.length > 0){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_popularity,@"value",@"Popularity",@"key" ,nil]];
        }
        if(! ([currentProfile.s_aboutMe isKindOfClass:[NSNull class]] || currentProfile.s_aboutMe.length <= 0)){
            [tableSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentProfile.s_aboutMe,@"value",@"About me",@"key",nil]];
        }
        [tableViewProfile reloadData];
        
        [buttonAvatar setContentMode:UIViewContentModeScaleAspectFit];
        [buttonAvatar setImage:img_avatar forState:UIControlStateNormal];
        
        // SCROOL SIZE
        [scrollview setContentSize:CGSizeMake(320, 800)];//:CGRectMake(0, 0, 320, 480)];

        // load interest List
        NSArray* a = currentProfile.a_favorites;
        
       
        if( a && [a count] > 0)
        {
            self.interestsView.hidden = NO;
            [self loadInterestedThumbnailList:a];
        }
        else
        {
            
            self.interestsView.hidden = YES;
            
            self.profileView.frame = [self moveToFrame:self.mutualFriendsView.frame from:self.profileView.frame];
            self.mutualFriendsView.frame = [self moveToFrame:self.interestsView.frame from:self.mutualFriendsView.frame];
        }
    
        [self initMutualFriendsList];
        [self checkAddedToFavorite];
        [self checkAddedToBlockList];
        [self checkAddedToWantToMeet];
        [self  disableControllerButtons:NO];
        
        loadingAvatar.hidden = YES;
        [loadingAvatar stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) \
    {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
        
        loadingAvatar.hidden = YES;
        [loadingAvatar stopAnimating];
    }];
    
    
    
}
-(void)loadInterestedThumbnailList:(NSArray*)list{
    for(int i = 0 ; i < [list count]; i++)
    {
//        Profile* p = [mutual_friends objectAtIndex:i];
         NSString* text = [list objectAtIndex:i];
//        NSString* link = @"";
//        if(![link isEqualToString:@""])
//        {
//            AFHTTPRequestOperation *operation =
//            [Profile getAvatarSync:link
//                          callback:^(UIImage *avatar)
//             {
                 UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Default Avatar"]];
                 
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
                 [name setFont:FONT_NOKIA(10.0)];
                 name.text = text;
                 [scrollViewInterest addSubview:imageView];
                 [scrollViewInterest addSubview:name];
//             }];
//            [operation start];
//            
//        }
//        
    }
    scrollViewInterest.contentSize = CGSizeMake( [list count] * (58 + 5), 58 + 5);
//    [scrollViewInterest removeFromSuperview];
    
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

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
//    popoverShowing = NO;
    [self.infoView localizeAllViews];
    [self.interestsView localizeAllViews];
    [self.mutualFriendsView localizeAllViews];
    [self.profileView localizeAllViews];
    [self.view localizeAllViews];
}
//- (void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:NO];
//}
-(void)checkAddedToFavorite{
    [btnAddToFavorite setSelected:NO];
    [request getPath:URL_getListMyFavorites parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        if(![data isKindOfClass:[NSNull class]]){
            for (int i = 0; i < [data count]; i++) {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                NSString * temp = [objectData valueForKey:key_profileID];
                if([currentProfile.s_ID isEqualToString: temp]){
                    [btnAddToFavorite setSelected:YES];
                    [self.btnLike setSelected:YES];
                    return;
                }
            }
        }
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

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
    
    [self setButtonAvatar:nil];
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
    [self loadPhotoForScrollview];
}
-(void) loadProfile:(Profile*) _profile{
    currentProfile = _profile;
    [self refreshScrollView];
    [self loadPhotoForScrollview];
//    [currentProfile loadPhotosByProfile:^(NSMutableArray* photoList){
//        [self loadPhotoDataForScrollView];
//    }];
}

-(void)refreshScrollView{
    for (UIImageView * view in self.svPhotos.subviews) {
        [view removeFromSuperview];
    }
    self.svPhotos.frame = CGRectMake(0, 0, 320, 275);
}
-(void)loadPhotoForScrollview{
//    for (UIImageView * view in self.svPhotos.subviews) {
//        [view removeFromSuperview];
//    }
//    self.svPhotos.frame = CGRectMake(0, 0, 320, 275);
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:currentProfile.s_ID, key_profileID, nil];
    
    [loadingAvatar startAnimating];
    
    [request getPath:URL_getListPhotos parameters:params
             success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSMutableArray* listPhotos = [Profile parseListPhotos:JSON];
         currentProfile.arr_photos = [[NSMutableArray alloc] init];
         NSArray* _imagesData;
         NSMutableDictionary* photos;
         if(listPhotos != nil)
         {
             _imagesData = [[NSArray alloc]initWithArray:listPhotos];
             photos = [[NSMutableDictionary alloc] init];
             self.svPhotos.contentSize =
             CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [_imagesData count], CGRectGetHeight(self.svPhotos.frame));

             
             if([_imagesData count] == 0)
             {
                 [loadingAvatar stopAnimating];
                 loadingAvatar.hidden = YES;
             }
             else
             {
                 for(int i = 0; i < [_imagesData count]; i++)
                 {
                     NSString* link = [_imagesData objectAtIndex:i];
                     
                     if( ![link isEqualToString:@""] )
                     {
                         AFHTTPRequestOperation *operation =
                         [Profile getAvatarSync:link
                                       callback:^(UIImage *image)
                          {
//                              [photos setObject:image forKey:link];
                              UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                              CGRect frame = self.svPhotos.frame;
                              frame.origin.x = CGRectGetWidth(frame) * i;
                              frame.origin.y = 0;
                              imageView.frame = frame;
                              [imageView setContentMode:UIViewContentModeScaleAspectFit];
                              [self.svPhotos addSubview:imageView];
                              [currentProfile.arr_photos addObject:imageView];
                              [photoCount setText:[NSString stringWithFormat:@"%i/%i",0,[currentProfile.arr_photos count]]];
//                              photoPageControl.numberOfPages = [currentProfile.arr_photos count];
                              if( i == 0)
                              {
//                                  [self initView];
                                  [loadingAvatar stopAnimating];
                              }
                          }];
                         [operation start];
                         
                     }
                 }
                 
             }
             
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
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
    }else{
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
    buttonBack.frame = CGRectMake(0, 0, 10, 17);
    [buttonBack addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_back.png"] forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"Navbar_btn_back_pressed.png"] forState:UIControlStateHighlighted];
    
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
}
#pragma mark Scrollview delegate
BOOL allowFullScreen = FALSE;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float scrollOffset = scrollView.contentOffset.y;
    if(scrollView.tag ==2){
        int index =scrollView.contentOffset.x/scrollView.frame.size.width;
        [photoCount setText:[NSString stringWithFormat:@"%i/%i",index + 1,[currentProfile.arr_photos count]]];
    }
    if(scrollView.tag == 1 && allowFullScreen){
        NSLog(@"content offset : %f",scrollOffset);
        if(self.svPhotos.frame.size.height < self.view.frame.size.height  && scrollOffset < 0){
            if(self.svPhotos.frame.size.height >= self.view.frame.size.height - 80){
                [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.view.frame.size.height, self.infoView.frame.size.width, self.infoView.frame.size.height)];

                CGRect interestFrame = scrollViewInterest.frame;
                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, self.view.frame.size.height , interestFrame.size.width, interestFrame.size.height)];
            }
            else{
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height +  fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y +fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(0, 0)];
                
                CGRect interestFrame = scrollViewInterest.frame;
                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, fabsf(scrollOffset) + interestFrame.origin.y, interestFrame.size.width, interestFrame.size.height)];
            }
        }
        else{
            if(self.svPhotos.frame.size.height > 275 && scrollOffset > 0){
                [self.svPhotos setFrame:CGRectMake(0, 0, 320, self.svPhotos.frame.size.height -  fabsf(scrollOffset))];
                self.svPhotos.contentSize =
                CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
                [self.infoView setFrame:CGRectMake(0, self.infoView.frame.origin.y -  fabsf(scrollOffset), self.infoView.frame.size.width, self.infoView.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(0, 0)];
                CGRect interestFrame = scrollViewInterest.frame;
                [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, interestFrame.origin.y - fabsf(scrollOffset), interestFrame.size.width, interestFrame.size.height)];
            }
        }
        [self updateSubviewsToCenterScrollView];
    }
 
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    float scrollOffset = scrollView.contentOffset.y;
    if(scrollOffset == 0)
        allowFullScreen = TRUE;
    NSLog(@"scrollViewWillBeginDragging - content offset : %f",scrollOffset);
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    allowFullScreen = FALSE;
//     float scrollOffset = scrollView.contentOffset.y;
//    NSLog(@"scrollViewDidEndDragging - content offset : %f",scrollOffset);
    if(self.svPhotos.frame.size.height < self.view.frame.size.height - 80){
        CGRect interestFrame = scrollViewInterest.frame;
        [scrollViewInterest setFrame:CGRectMake(interestFrame.origin.x, self.infoView.frame.origin.y +  self.interestsView.frame.origin.y + 29, interestFrame.size.width, interestFrame.size.height)];
        
        [self.svPhotos setFrame:CGRectMake(0, 0, self.view.frame.size.width, 275)];
        self.svPhotos.contentSize =
        CGSizeMake(CGRectGetWidth(self.svPhotos.frame) * [currentProfile.arr_photos count], CGRectGetHeight(self.svPhotos.frame));
        [self.infoView setFrame:CGRectMake(0, 275, self.infoView.frame.size.width, self.infoView.frame.size.height)];
        [self updateSubviewsToCenterScrollView];
    }
    
}

-(void)updateSubviewsToCenterScrollView{
    for(UIImageView* imageView in [self.svPhotos subviews]){
        imageView.center = CGPointMake(imageView.center.x, self.svPhotos.center.y);
    }
}
@end
