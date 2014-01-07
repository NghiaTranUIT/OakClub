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

@interface MatchMaker () <PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout>
{
    int nCols, nRows;
    NSArray *friends;
    AppDelegate *appDel;
    
    Profile *match1, *match2;
    LoadingIndicator *loadingIndicator;
}
@property (weak, nonatomic) IBOutlet UIImageView *friend1Avatar;
@property (weak, nonatomic) IBOutlet UIImageView *friend2Avatar;
@property (weak, nonatomic) IBOutlet UIImageView *matchBorder;
@property (weak, nonatomic) IBOutlet UIView *friendListView;
@property (weak, nonatomic) IBOutlet UIView *descView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *matchButton;
@property (weak, nonatomic) IBOutlet UIView *dismissKeyboardView;
@end

@implementation MatchMaker
@synthesize CVFriendsList;

#define MOVE_ANIMATE_DURATION 0.3
#define ZOOM_ANIMATE_DURATION 0.3
#define ZOOM_RATIO 110.0/80

#define ANIMATE_DURATION 0.3

#define DEFAULT_DESC @"The two are match"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDel = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    loadingIndicator = [[LoadingIndicator alloc] initWithMainView:self.friendListView andDelegate:nil];
    [self loadFriendsData];
    
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
    self.CVFriendsList = [[PSUICollectionView alloc] initWithFrame:CGRectMake(10, 10, self.friendListView.frame.size.width - 20, self.friendListView.frame.size.height - 20) collectionViewLayout:layout];
    self.CVFriendsList.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.CVFriendsList.backgroundColor = [UIColor clearColor];
    [self.CVFriendsList registerClass:[MatchMakerFriendCell class] forCellWithReuseIdentifier:matchmakerFriendCellID];
    self.CVFriendsList.dataSource = self;
    self.CVFriendsList.delegate = self;
    
    [self.friendListView addSubview:self.CVFriendsList];
    
    nCols = self.CVFriendsList.frame.size.width / 80;
    nRows = 1 + friends.count / nCols;
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
        [appDel.imagePool getImageAtURL:friend.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *url) {
            if (isFirstLoad)
            {
                [collectionView reloadData];
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
        [self sendMatchNotificationToServerWithFristUserID:match1.s_FB_id andSecond:match2.s_FB_id withDesc:self.descTextView.text];
    }
}

-(void)sendMatchNotificationToServerWithFristUserID:(NSString *)fb_id1 andSecond:(NSString *)fb_id2 withDesc:(NSString *)desc
{
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
        
        UIAlertView *completedAlert = [[UIAlertView alloc] initWithTitle:[@"Match made" localize] message:nil delegate:nil cancelButtonTitle:[@"OK" localize] otherButtonTitles:nil];
        [completedAlert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Cannot send matchmaker, error %@", error.localizedDescription);
    }];
    [operation start];
}

#pragma mark utils
-(void)loadFriendsData
{
    [loadingIndicator lockViewAndDisplayIndicator];
    
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
                friend.s_FB_id = friendIDs[i];
                friend.s_Avatar = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", friend.s_FB_id];
                friend.s_Name = friendDatas[i][key_name];
                
                [friendlist addObject:friend];
            }
            
            friends = friendlist;
        }
        
        [self initFriendsListCollection];
        
        [loadingIndicator unlockViewAndStopIndicator];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get match friends list Error Code: %i - %@", [error code], error);
        [loadingIndicator unlockViewAndStopIndicator];
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
    
    [self.matchButton setHidden:NO];
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
    
    [self.matchButton setHidden:YES];
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
@end
