//
//  MatchMaker.m
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "MatchMaker.h"
#import "MatchMakerFriendCell.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"
#import "LoadingIndicator.h"
#import "SendMatchViewCell.h"
#import "MatchMakerItem.h"
#import "FacebookSDK/FacebookSDK.h"

enum MATCHMAKER_CHOOSE_STATE{
    MATCHMAKER_CHOOSE_NONE = 0,
    MATCHMAKER_CHOOSE_CHOOSING,
    MATCHMAKER_CHOOSE_WAITING,
    MATCHMAKER_CHOOSE_SUCCESS,
    MATCHMAKER_CHOOSE_FAIL
    };

enum MATCHMAKER_LOADFRIEND_STATE {
    MATCHMAKER_LOADFRIEND_NONE = 0,
    MATCHMAKER_LOADFRIEND_LOADING,
    MATCHMAKER_LOADFRIEND_SUCCESS,
    MATCHMAKER_LOADFRIEND_FAILED
    };

enum MATCHMAKER_TABPAGE
{
    MATCHMAKER_TABPAGE_MATCHFRIENDS = 0,
    MATCHMAKER_TABPAGE_SENDMATCHES
};

@interface MatchMaker () <PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>
{
    int nCols, nRows;
    NSArray *friends;
    NSMutableArray *matchMakerRequests;
    AppDelegate *appDel;
    enum MATCHMAKER_CHOOSE_STATE _chooseStatus;
    enum MATCHMAKER_LOADFRIEND_STATE _loadFriendStatus;
    enum MATCHMAKER_TABPAGE _tabPage;
    
    Profile *match1, *match2;
    ImagePool *imagePool;
    LoadingIndicator *loadingIndicator;
}
@property (strong, nonatomic) IBOutlet UIView *matchYourFriendsView;
@property (strong, nonatomic) IBOutlet UIView *sendMatchesView;
@property (weak, nonatomic) IBOutlet UIView *tabDisplayView;
@property (weak, nonatomic) IBOutlet UITableView *tbViewMatchMakerRequests;
@property (weak, nonatomic) IBOutlet UIImageView *friend1Avatar;
@property (weak, nonatomic) IBOutlet UIImageView *friend2Avatar;
@property (weak, nonatomic) IBOutlet UIView *friendListView;
@property (weak, nonatomic) IBOutlet UIView *descView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIView *viewSuccess;
@property (weak, nonatomic) IBOutlet UIView *viewWarning;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indWait;
@property (weak, nonatomic) IBOutlet UIView *matchButtonView;
@property (weak, nonatomic) IBOutlet UILabel *matchButtonDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *matchButton;
@property (weak, nonatomic) IBOutlet UIView *dismissKeyboardView;
@property (weak, nonatomic) IBOutlet UIView *loadFriendFailedView;
@property (weak, nonatomic) IBOutlet UIButton *matchYourFriendsTabButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMatchesTabButton;

@property enum MATCHMAKER_CHOOSE_STATE ChooseStatus;
@property enum MATCHMAKER_LOADFRIEND_STATE LoadFriendStatus;
@property enum MATCHMAKER_TABPAGE TabPage;
@end

@implementation MatchMaker
@synthesize CVFriendsList;

#define MOVE_ANIMATE_DURATION 0.3
#define ZOOM_ANIMATE_DURATION 0.3
#define ZOOM_RATIO 100.0/80

#define ANIMATE_DURATION 0.3

#define DEFAULT_DESC @"I want you to meet someone. I introduced you on OakClub\n\
www.oakclub.com"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDel = (id) [UIApplication sharedApplication].delegate;
        imagePool = [[ImagePool alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    loadingIndicator = [[LoadingIndicator alloc] initWithMainView:self.friendListView andDelegate:nil];
    [self initFriendsListCollection];
    
    [self updateViewByLoadFriendStatus];
    
    self.TabPage = MATCHMAKER_TABPAGE_MATCHFRIENDS;
    
    matchMakerRequests = [[NSMutableArray alloc] init];
    self.matchButton.enabled = NO;
    [self.matchButtonDescLabel setHidden:YES];
    self.ChooseStatus = MATCHMAKER_CHOOSE_CHOOSING;
    
    [self.tabDisplayView addSubview:self.matchYourFriendsView];
    
    UITapGestureRecognizer *friend1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friend1AvatarTouched:)];
    [self.friend1Avatar addGestureRecognizer:friend1Tap];
    [self.friend1Avatar.layer setCornerRadius:(self.friend1Avatar.layer.frame.size.width / 2)];
    [self.friend1Avatar.layer setMasksToBounds:YES];
    UITapGestureRecognizer *friend2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friend2AvatarTouched:)];
    [self.friend2Avatar addGestureRecognizer:friend2Tap];
    [self.friend2Avatar.layer setCornerRadius:(self.friend2Avatar.layer.frame.size.width / 2)];
    [self.friend2Avatar.layer setMasksToBounds:YES];
    
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.dismissKeyboardView addGestureRecognizer:dismissKeyboardTap];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.LoadFriendStatus == MATCHMAKER_LOADFRIEND_FAILED)
    {
        [self loadFriendsData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:NSStringFromClass([self class])
                           forKey:kGAIScreenName] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark collection view datasource / delegate
-(void)initFriendsListCollection
{
    static NSString *matchmakerFriendCellID = @"matchmakerFriendCellID";
    
    PSUICollectionViewFlowLayout *layout = [PSUICollectionViewFlowLayout new];
    layout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
    self.CVFriendsList = [[PSUICollectionView alloc] initWithFrame:CGRectMake(10, 30, self.friendListView.frame.size.width - 20, self.friendListView.frame.size.height - 40) collectionViewLayout:layout];
    self.CVFriendsList.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.CVFriendsList.backgroundColor = [UIColor clearColor];
    [self.CVFriendsList registerClass:[MatchMakerFriendCell class] forCellWithReuseIdentifier:matchmakerFriendCellID];
    self.CVFriendsList.dataSource = self;
    self.CVFriendsList.delegate = self;
    
    [self.friendListView addSubview:self.CVFriendsList];
    [self updateFriendList];
}

-(void)updateFriendList
{
    if (self.CVFriendsList)
    {
        nCols = self.CVFriendsList.frame.size.width / 80;
        nRows = 1 + friends.count / nCols;
        
        [self.CVFriendsList reloadData];
    }
}

-(int)indexPathToIndex:(NSIndexPath *)indexPath
{
    return indexPath.section * nCols + indexPath.row;
}

-(PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *matchmakerFriendCellID = @"matchmakerFriendCellID";
    
    MatchMakerFriendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:matchmakerFriendCellID forIndexPath:indexPath];
    
    if (cell)
    {
        int index = [self indexPathToIndex:indexPath];
        Profile *friend = friends[index];
        
        [cell.friendAvatar setImage:[UIImage imageNamed:@"Default Avatar"]];
        [cell.friendName setText:friend.firstName];
        [imagePool getImageAtURL:friend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *url) {
            if (isFirstLoad)
            {
                [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            }
            else
            {
                [cell.friendAvatar setImage:img];
                
                if (friend == match1 || friend == match2)
                {
                    // add disabled
                }
            }
        }];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return nRows;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return (section < nRows - 1)?nCols:(friends.count % nCols);
}

#define CELL_SOURCE_FRAME CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 80, 80)
-(void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [self indexPathToIndex:indexPath];
    Profile *friend = friends[index];
    
    if (friend == match1 || friend == match2)
    {
        return; // do nothing
    }
    
    UIImageView *destImgView = nil;
    if (!match1)
    {
        destImgView = self.friend1Avatar;
        match1 = friend;
    }
    else if (!match2)
    {
        destImgView = self.friend2Avatar;
        match2 = friend;
    }
    
    if (destImgView)
    {
        MatchMakerFriendCell *cell = (MatchMakerFriendCell *) [self collectionView:self.CVFriendsList cellForItemAtIndexPath:indexPath];
        if (cell)
        {
            [self.view setUserInteractionEnabled:NO];
            CGRect sourceFrame = [self.CVFriendsList convertRect:CELL_SOURCE_FRAME toView:self.view];
            CGRect destFrame = [destImgView.superview convertRect:destImgView.frame toView:self.view];
            
            UIImageView *tmpFriendAvatar = [self createCircleImageViewInFrame:sourceFrame andImage:cell.friendAvatar.image];
            [self.view addSubview:tmpFriendAvatar];
            
            [UIView animateWithDuration:ZOOM_ANIMATE_DURATION
                             animations:^{
                                 tmpFriendAvatar.transform = CGAffineTransformScale(tmpFriendAvatar.transform, ZOOM_RATIO, ZOOM_RATIO);
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:MOVE_ANIMATE_DURATION
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      tmpFriendAvatar.center = CGPointMake(destFrame.origin.x + destFrame.size.width / 2, destFrame.origin.y + destFrame.size.height / 2);
                                                  } completion:^(BOOL finished) {
                                                      [destImgView setImage:tmpFriendAvatar.image];
                                                      [tmpFriendAvatar removeFromSuperview];
                                                      [self.view setUserInteractionEnabled:YES];
                                                      
                                                      if (match1 && match2)
                                                      {
                                                          [self animatePrepareSendMatch];
                                                      }
                                                      
                                                      [self.CVFriendsList reloadData];
                                                  }];
                             }];
        }
    }
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 112);
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

#pragma mark friend avatar tap handle
-(void)friend1AvatarTouched:(id)sender
{
    [self dismissKeyboard:nil];
    if (self.friend1Avatar.image)
    {
        self.ChooseStatus = MATCHMAKER_CHOOSE_CHOOSING;
        [self.friend1Avatar setUserInteractionEnabled:NO];
        
        if (!self.friend2Avatar.image)
        {
            
            [UIView animateWithDuration:ANIMATE_DURATION animations:^{
                [self.friend1Avatar setAlpha:0];
                
            } completion:^(BOOL finished) {
                [self.friend1Avatar setAlpha:1];
                [self.friend1Avatar setImage:nil];
                match1 = nil;
                [self.friend1Avatar setUserInteractionEnabled:YES];
            }];
        }
        else
        {
            CGRect sourceFrame = [self.friend2Avatar.superview convertRect:self.friend2Avatar.frame toView:self.view];
            UIImageView *tmpFriendAvatar = [self createCircleImageViewInFrame:sourceFrame andImage:self.friend2Avatar.image];
            [self.view addSubview:tmpFriendAvatar];
            [self.friend2Avatar setImage:nil];
            
            [UIView animateWithDuration:ANIMATE_DURATION animations:^{
                [self.friend1Avatar setAlpha:0];
                
                [tmpFriendAvatar setFrame:[[self.friend1Avatar superview] convertRect:self.friend1Avatar.frame toView:self.view]];
            } completion:^(BOOL finished) {
                [self.friend1Avatar setAlpha:1];
                [self.friend1Avatar setImage:tmpFriendAvatar.image];
                match1 = match2;
                match2 = nil;
                [tmpFriendAvatar removeFromSuperview];
                
                [self animateWaitChooseFriend];
                [self.friend1Avatar setUserInteractionEnabled:YES];
            }];
        }
    }
}

-(void)friend2AvatarTouched:(id)sender
{
    [self dismissKeyboard:nil];
    if (self.friend2Avatar.image)
    {
        self.ChooseStatus = MATCHMAKER_CHOOSE_CHOOSING;
        [self.friend2Avatar setUserInteractionEnabled:NO];
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            [self.friend2Avatar setAlpha:0];
        } completion:^(BOOL finished) {
            [self.friend2Avatar setAlpha:1];
            [self.friend2Avatar setImage:nil];
            match2 = nil;
            
            [self animateWaitChooseFriend];
            [self.friend2Avatar setUserInteractionEnabled:YES];
        }];
    }
}

#pragma match button event
- (IBAction)matchButtonTouched:(id)sender
{
    if (match1 && match2)
    {
        //pop up Facebook Request dialog
        NSString *title = [NSString stringWithFormat:[@"%@ has matched you with %@ on OakClub" localize], match1.s_Name, match2.s_Name];
        NSString *message = [NSString stringWithFormat:[@"Hey %@, %@. You have been matched each other on www.oakclub.com. You will make a great couple. Love is in the air! Check out your match now!" localize], match1.s_Name, match2.s_Name];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@,%@", match1.s_FB_id, match2.s_FB_id], @"to",
                                       nil];
        
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:message title:title parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                // Error launching the dialog or sending the request.
                [self showMatchError];
            }
            else
            {
                if (result == FBWebDialogResultDialogNotCompleted)
                {
                    // User clicked the "x" icon
                }
                else
                {
                    // Handle the send request callback
                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                    if (![urlParams valueForKey:@"request"])
                    {
                        // User clicked the Cancel button
                    }
                    else
                    {
                        // User clicked the Send button
                        NSString *requestID = [urlParams valueForKey:@"request"];
                        NSLog(@"Request ID: %@", requestID);
                        
                        [self sendMatchNotificationToServerWithFristUserID:match1.s_FB_id andSecond:match2.s_FB_id withDesc:self.descTextView.text];
                    }
                }
            }
        }];
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)showMatchError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"Error" localize]
                                                        message:[@"Error in process matching" localize]
                                                       delegate:nil
                                              cancelButtonTitle:[@"Ok" localize]
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)sendMatchNotificationToServerWithFristUserID:(NSString *)fb_id1 andSecond:(NSString *)fb_id2 withDesc:(NSString *)desc
{
    self.ChooseStatus = MATCHMAKER_CHOOSE_WAITING;
    [self.view setUserInteractionEnabled:NO];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //NSDictionary *params = @{@"to":reciever_id, @"message":message};
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:fb_id1,@"maleId", fb_id2, @"femaleId", nil];
    
    NSMutableURLRequest *req = [httpClient requestWithMethod:@"POST"
                                            path:URL_sendMatchmaker
                                            parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"send matchmaker success with respond: %@", dict);
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:DATE_FORMAT];
        NSDate *now = [[NSDate alloc] init];
        
        [matchMakerRequests addObject:[[MatchMakerItem alloc] initWithFriend1:match1 friend2:match2 matchTime:[dateFormater stringFromDate:now] requestStatus:YES andSendStatus:NO]];
        
        self.ChooseStatus = MATCHMAKER_CHOOSE_SUCCESS;
        [self.view setUserInteractionEnabled:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Cannot send matchmaker, error %@", error.localizedDescription);
        self.ChooseStatus = MATCHMAKER_CHOOSE_FAIL;
        [self.view setUserInteractionEnabled:YES];
    }];
    [operation start];
}

#pragma mark utils
-(void)loadFriendsData
{
    self.LoadFriendStatus = MATCHMAKER_LOADFRIEND_LOADING;
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"GET" path:URL_getMatchmakerFriendList parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        
        if (dict && !e)
        {
            NSDictionary *data = dict[key_data];
            NSArray *friendDatas = data[@"friendData"];
            NSArray *friendIDs = data[@"friendIds"];
            
            NSMutableArray *friendlist = [[NSMutableArray alloc] init];
            for (int i = 0; i < friendIDs.count; ++i)
            {
                Profile *friend = [[Profile alloc] init];
                NSString *userId = friendIDs[i];
                friend.s_FB_id = userId;
                friend.s_Avatar = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", friend.s_FB_id];
                friend.s_Name = friendDatas[i][key_name];
                
                [friendlist addObject:friend];
            }
            
            friends = friendlist;
            
            self.LoadFriendStatus = MATCHMAKER_LOADFRIEND_SUCCESS;
        }
        else
        {
            self.LoadFriendStatus = MATCHMAKER_LOADFRIEND_FAILED;
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get match friends list Error Code: %i - %@", [error code], error);
        self.LoadFriendStatus = MATCHMAKER_LOADFRIEND_FAILED;
    }];
    [operation start];
}

-(UIImageView*)createCircleImageViewInFrame:(CGRect)frame andImage:(UIImage *)img
{
    UIImageView *resultImgView = [[UIImageView alloc] initWithFrame:frame];
    [resultImgView.layer setCornerRadius:(frame.size.width / 2)];
    [resultImgView.layer setMasksToBounds:YES];
    [resultImgView setImage:img];
    
    return resultImgView;
}

-(void)animatePrepareSendMatch
{
    [self.view setUserInteractionEnabled:NO];
    
    [self.matchButton setEnabled:YES];
    [self.matchButtonDescLabel setHidden:NO];
    [self.descView setHidden:NO];
    [self.descView setAlpha:0];
    [self.descTextView setText:DEFAULT_DESC];
    
    CGRect descViewFrame = self.descView.frame;
    CGRect newCVFriendListFrame = self.friendListView.frame;
    newCVFriendListFrame.origin.y = descViewFrame.origin.y + descViewFrame.size.height;
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.descView setAlpha:1];
        [self.friendListView setFrame:newCVFriendListFrame];
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
    }];
}

-(void)animateWaitChooseFriend
{
    [self.view setUserInteractionEnabled:NO];
    
    [self.matchButton setEnabled:NO];
    [self.descView setHidden:NO];
    
    CGRect descViewFrame = self.descView.frame;
    CGRect newCVFriendListFrame = self.friendListView.frame;
    newCVFriendListFrame.origin.y = descViewFrame.origin.y;
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.descView setAlpha:0];
        [self.friendListView setFrame:newCVFriendListFrame];
    } completion:^(BOOL finished) {
        [self.descView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
    }];
}

-(void)dismissKeyboard:(id)sender
{
    [self.descTextView resignFirstResponder];
}

#pragma mark tableView dataSource / delegate
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return matchMakerRequests.count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mmRequestID = @"MatchMakerRequest";
    
    SendMatchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mmRequestID];
    if (!cell)
    {
        cell = [[SendMatchViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mmRequestID];
    }
    
    MatchMakerItem *mmItem = [matchMakerRequests objectAtIndex:indexPath.row];
    [imagePool getImageAtURL:mmItem.friend1.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        cell.friend1Avatar.image = img;
    }];
    
    
    [imagePool getImageAtURL:mmItem.friend2.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        cell.friend2Avatar.image = img;
    }];
    
    cell.lblName.text = [NSString stringWithFormat:@"%@ & %@", mmItem.friend1.firstName, mmItem.friend2.firstName];
    
    cell.lblTime_Status.text = [NSString stringWithFormat:@"%@ %@ | %@: %@", [@"Matched on" localize], mmItem.matchTime, [@"Status" localize], mmItem.s_Status];
    
    cell.lblSendStatus.text = mmItem.isSent?([@"Send them a message" localize]):([@"Message sent" localize]);
    
    cell.btnSendMessage.enabled = !mmItem.isSent;
    cell.linkImage.highlighted = mmItem.status;
    
    return cell;
}

#pragma mark text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

#pragma mark matchmaker status
-(enum MATCHMAKER_CHOOSE_STATE)ChooseStatus
{
    return _chooseStatus;
}

-(void)setChooseStatus:(enum MATCHMAKER_CHOOSE_STATE)status
{
    
    switch (status) {
        case MATCHMAKER_CHOOSE_CHOOSING:
            [self.matchButtonView setHidden:NO];
            [self.viewSuccess setHidden:YES];
            [self.viewWarning setHidden:YES];
            [self.indWait stopAnimating];
            break;
        case MATCHMAKER_CHOOSE_WAITING:
            [self.matchButtonView setHidden:YES];
            [self.viewSuccess setHidden:YES];
            [self.viewWarning setHidden:YES];
            [self.indWait startAnimating];
            break;
        case MATCHMAKER_CHOOSE_SUCCESS:
            [self.matchButtonView setHidden:YES];
            [self.viewSuccess setHidden:NO];
            [self.viewWarning setHidden:YES];
            [self.indWait stopAnimating];
            break;
        case MATCHMAKER_CHOOSE_FAIL:
            [self.matchButtonView setHidden:YES];
            [self.viewSuccess setHidden:NO];
            [self.viewWarning setHidden:YES];
            [self.indWait stopAnimating];
            break;
        default:
            break;
    }
    
    status = _chooseStatus;
}

-(enum MATCHMAKER_LOADFRIEND_STATE)LoadFriendStatus
{
    return _loadFriendStatus;
}

-(void)setLoadFriendStatus:(enum MATCHMAKER_LOADFRIEND_STATE)LoadFriendStatus
{
    if (_loadFriendStatus != LoadFriendStatus)
    {
        _loadFriendStatus = LoadFriendStatus;
        [self updateViewByLoadFriendStatus];
    }
}

-(void)updateViewByLoadFriendStatus
{
    switch (_loadFriendStatus) {
        case MATCHMAKER_LOADFRIEND_LOADING:
            [loadingIndicator lockViewAndDisplayIndicator];
            [self.CVFriendsList setHidden:YES];
            [self.loadFriendFailedView setHidden:YES];
            break;
        case MATCHMAKER_LOADFRIEND_SUCCESS:
            [loadingIndicator unlockViewAndStopIndicator];
            [self.CVFriendsList setHidden:NO];
            [self updateFriendList];
            [self.loadFriendFailedView setHidden:YES];
            break;
        case MATCHMAKER_LOADFRIEND_FAILED:
            [loadingIndicator unlockViewAndStopIndicator];
            [self.CVFriendsList setHidden:YES];
            [self.loadFriendFailedView setHidden:NO];
            break;
        default:
            break;
    }
}
- (IBAction)reloadFriendListTouched:(id)sender {
    [self loadFriendsData];
}

#pragma mark tab page state
-(enum MATCHMAKER_TABPAGE)TabPage
{
    return _tabPage;
}

-(void)setTabPage:(enum MATCHMAKER_TABPAGE)TabPage
{
    if (_tabPage != TabPage)
    {
        _tabPage = TabPage;
        
        [self updateViewByTabPage];
    }
}

#define DEFAULT_COLOR [UIColor colorWithRed:121.0/255 green:1.0/255 blue:88.0/255 alpha:1]
#define HIGHLIGHT_COLOR [UIColor colorWithRed:88.0/255 green:1.0/255 blue:88.0/255 alpha:1]
-(void)updateViewByTabPage
{
    switch (self.TabPage) {
        case MATCHMAKER_TABPAGE_MATCHFRIENDS:
            [self.sendMatchesView removeFromSuperview];
            [self.sendMatchesTabButton setBackgroundColor:DEFAULT_COLOR];
            [self.tabDisplayView addSubview:self.matchYourFriendsView];
            [self.matchYourFriendsTabButton setBackgroundColor:HIGHLIGHT_COLOR];
            break;
        case MATCHMAKER_TABPAGE_SENDMATCHES:
            [self.matchYourFriendsView removeFromSuperview];
            [self.matchYourFriendsTabButton setBackgroundColor:DEFAULT_COLOR];
            [self.tabDisplayView addSubview:self.sendMatchesView];
            [self.sendMatchesTabButton setBackgroundColor:HIGHLIGHT_COLOR];
            [self.tbViewMatchMakerRequests reloadData];
            break;
        default:
            break;
    }
}
- (IBAction)tabButtonMatchYourFriendsTouched:(id)sender {
    self.TabPage = MATCHMAKER_TABPAGE_MATCHFRIENDS;
}
- (IBAction)tabButtonSendMatchesTouched:(id)sender {
    self.TabPage = MATCHMAKER_TABPAGE_SENDMATCHES;
}
@end
