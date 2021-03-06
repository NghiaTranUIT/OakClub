
//  SMChatViewController.m
//  jabberClient
//
//  Created by cesarerocchi on 7/16/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "SMChatViewController.h"
#import "XMPP.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"

#import "HistoryMessage.h"

#import "Profile.h"
#import "VCProfile.h"
#import "WordWarpParse.h"
#import "ChatEmoticon.h"
#import "HistoryMessage+init.h"
#import "VCSimpleSnapshot.h"
#import "VCReportPopup.h"
#import "ChatNavigationView.h"
#import "SmileyChooseCell.h"
#import "UIView+Localize.h"
#import "LoadingIndicator.h"
#import "OakClubChatEmoticon.h"
#import "StickerChooseTabs.h"

@interface EmoticonDisplayData : NSObject
@property CGSize cellSize;
@property float cellPadding;
@property int numberOfRows, numberOfColumns, numberOfItems;
@property (weak, nonatomic) ChatEmoticon *chatEmoticon;
@property SEL onTouched;
@end

@interface SMChatViewController() <StickerChooseTabsDelegate>
@property UIImageView* headerLogo;
@property (strong, nonatomic) StickerChooseTabs *stickerChooseTabs;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (strong, nonatomic) IBOutlet SMChat_FirstViewMatchView *firstViewMatchView;
@end

@implementation SMChatViewController
{
    __strong NSMutableDictionary *_requestsImage;
    NSMutableArray* a_messages;
    NSMutableArray *smileyLayers;
    AppDelegate* appDel;
    NSMutableArray *cellHeight;
    
    UITapGestureRecognizer *dismissKeyboardGesture;
    UITapGestureRecognizer *dismissSmileyCollectionGesture;
    
    NSString *userChangedNotificationName;
    
    NSArray *chatEmoticons;
}

@synthesize messageField, chatWithUser, tView, scrollView, lblTyping, label_header, label_Age,btnMoreOption, btnShowProfile, btnBackToPrevious;

@synthesize stickerChooseTabs;

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
	return [[self appDelegate] xmppStream];
}


-(void)showIsType:(BOOL)show
{
    lblTyping.hidden=!show;
}

-(void)initMessages:(NSString*)profile_id
{
    messages = [[MessageStorage alloc] initWithProfileID:profile_id];
    
    for(int i = 0; a_messages!=nil && i < [a_messages count]; i++)
    {
        HistoryMessage* item = [a_messages objectAtIndex:i];
        [messages addMessage:item];
    }
}

- (id) initWithUser:(NSString *)_userName withProfile:(Profile*)_profile withMessages:(NSMutableArray*) array
{
    if (self = [super init])
    {
        userProfile = _profile;
		chatWithUser = _userName; // @ missing
		turnSockets = [[NSMutableArray alloc] init];
        
        userName = _profile.s_Name;
        [self registerForKeyboardNotifications];
        
        a_messages = array;
        
        //register for chat friend changed notification
        userChangedNotificationName = [NSString stringWithFormat:Notification_ChatFriendChanged_Format, _userName];
        [appDel.notificationCenter addObserver:self selector:@selector(onChatUserChanged:) name:userChangedNotificationName object:nil];
	}
	
	return self;
}

- (id) initWithUser:(NSString *)_userName withProfile:(Profile*)_profile 
{
	if (self = [super init])
    {
        messages = [[MessageStorage alloc ] initWithProfileID:_profile.s_ID];
        
        userProfile = _profile;
        userAge = [NSString stringWithFormat:@", %@", _profile.s_age];
        userName = [NSString formatStringWithName:_profile.s_Name andAge:_profile.s_age andNameLength:18];
		chatWithUser = _userName; // @ missing
		turnSockets = [[NSMutableArray alloc] init];
        [self registerForKeyboardNotifications];
        
        NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
        NSString* hangout_id = [chunks objectAtIndex:0];
        
        [HistoryMessage getHistoryMessages:hangout_id callback:^(NSMutableArray* array)
         {
             a_messages = array;
             
             [self initMessages:hangout_id];
             [tView reloadData];
             [self scrollToLastAnimated:NO];
         }];
	}
	
	return self;

}

-(void)scrollToLastAnimated:(BOOL)animated
{
    int lastRowNumber = [tView numberOfRowsInSection:0] - 1;
    
    if(lastRowNumber > 0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [tView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [appDel.messageDelegates addObject:self];
    
    [tView reloadData];
    [self scrollToLastAnimated:NO];
    [self customNavigationHeader];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:NSStringFromClass([self class])
                           forKey:kGAIScreenName] build]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [appDel.messageDelegates removeObject:self];
    [self clearCustomNavigationHeader];
    
    [super viewWillDisappear:animated];
}

-(void)clearCustomNavigationHeader{
    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        if([subview isKindOfClass:[ChatNavigationView class]] )
            [subview removeFromSuperview];
    }
    [self loadHeaderLogo];
}

-(void)loadHeaderLogo{
    UIImage* logo = [UIImage imageNamed:@"Snapshot_logo.png"];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(98, 10, 125, 26)];
    [logoView setImage:logo];
    logoView.tag = 101;
    [self.navigationController.navigationBar  addSubview:logoView];
}

-(void)customNavigationHeader{
    [btnBackToPrevious setFrame:CGRectMake(2, 2, btnBackToPrevious.frame.size.width, btnBackToPrevious.frame.size.height)];
    [btnBackToPrevious addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    
    label_header.frame = CGRectMake(70, 0, label_header.frame.size.width, 44);
    
    [btnShowProfile setFrame:CGRectMake(230, 0, btnShowProfile.frame.size.width, btnShowProfile.frame.size.height)];
    
    [btnMoreOption setFrame:CGRectMake(276, 0, btnMoreOption.frame.size.width, btnMoreOption.frame.size.height)];


    ChatNavigationView *headerView = [[ChatNavigationView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [headerView addSubview:btnBackToPrevious];
    [headerView addSubview:label_header];
    [headerView addSubview:btnShowProfile];
    [headerView addSubview:btnMoreOption];

    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        if([subview isKindOfClass:[ChatNavigationView class]] || [subview isKindOfClass:[UILabel class]] || [subview isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
        if([subview isKindOfClass:[UIImageView class]] && subview.tag == 101){
            [subview removeFromSuperview];
        }
    }
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:headerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initEmoticons];
    [self initStickerChooseTabs];
    
	self.tView.delegate = self;
	self.tView.dataSource = self;
	[self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.navigationController setNavigationBarHidden:NO];
    
	appDel = [self appDelegate];
    
    [label_header setText:userName];
    
    if (userProfile.status == MatchUnViewed)
    {
        userProfile.status = MatchViewed;
        [appDel.myProfile setViewedMatchMutualWithFriend:userProfile];
        
        [self.tView removeFromSuperview];
        [[self firstViewMatchView] setMatchedProfile:userProfile andImagepool:appDel.imagePool];
        [self.scrollView addSubview:self.firstViewMatchView];
        
        [self.view setUserInteractionEnabled:NO];
        [self.firstViewMatchView animateWithCompletion:^{
            [self.view setUserInteractionEnabled:YES];
        }];
    }
    else if (userProfile.status == ChatUnviewed)
    {
        userProfile.status = ChatViewed;
        [appDel.myProfile resetUnreadMessageWithFriend:userProfile];
    }
    
    if (!a_messages.count)  //didn't load history messages
    {
        LoadingIndicator *loadHistoryIndicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:nil];
        [loadHistoryIndicator lockViewAndDisplayIndicator];
        NSOperation *getHistoryOp = [HistoryMessage getHistoryMessages:userProfile.s_ID callback:^(NSMutableArray *hMsgs) {
            [a_messages removeAllObjects];
            [a_messages addObjectsFromArray:hMsgs];
            
            [self initMessages:userProfile.s_ID];
            [loadHistoryIndicator unlockViewAndStopIndicator];
            
            [self.tView reloadData];
            [self scrollToLastAnimated:NO];
        }];
        
        [getHistoryOp start];
    }
    else
    {
        [self initMessages:userProfile.s_ID];
        [self.tView reloadData];
        [self scrollToLastAnimated:NO];
    }
    
}

-(void)dismissKeyboard:(id)sender {
    [messageField resignFirstResponder];
}

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
	
	NSLog(@"TURN Connection succeeded!");
	NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
		
	[turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
	
	NSLog(@"TURN Connection failed!");
	[turnSockets removeObject:sender];
}



#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {
    UINavigationController* activeVC = [appDel activeViewController];
    [self.navigationController popViewControllerAnimated:YES];
    [appDel.rootVC setFrontViewController:activeVC];
    [appDel.rootVC showViewController:appDel.chat];
}

- (void)addMessage:(NSString*)body atTime:(NSString*)time fromUser:(NSString*)from toUser:(NSString*)to
{
    HistoryMessage* item = [ [HistoryMessage alloc] init];
    
    item.body = body;
    item.timeStr = time;
    item.from = from;
    item.to = to; 
    
    [a_messages addObject:item];
}

- (void)sendMessage:(NSString *)messageStr
{
    if([messageStr length] > 0)
    {
        [appDel sendMessageContent:messageStr to:chatWithUser];
        
        NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
        NSString* hangout_id = [chunks objectAtIndex:0];
        [HistoryMessage postMessage:hangout_id messageContent:messageStr];
        
		NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
		[m setObject:[messageStr formatForChatMessage] forKey:@"msg"];
		[m setObject:@"you" forKey:@"sender"];
        
        NSString* time = [NSString getCurrentTime];
		[m setObject:time forKey:@"time"];
        
		[messages addMessage:[[HistoryMessage alloc] initMessageFrom:@"you" atTime:time toHangout:hangout_id withContent:messageStr]];
        [self addMessage:messageStr atTime:time fromUser:[self appDelegate].myProfile.s_ID toUser:hangout_id];
        userProfile.status = ChatViewed;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:DATETIME_FORMAT];
        userProfile.s_status_time = [dateFormat stringFromDate:[[NSDate alloc] init]];
        
		[self.tView reloadData];
        
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:(messages.count - 1) inSection:0];
        [self.tView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (IBAction)onTouchMoreOption:(id)sender {
    VCReportPopup* reportPopup= [[VCReportPopup alloc]initWithProfileID:userProfile andChat:self];
    [self dismissKeyboard:sender];
    [reportPopup.view setFrame:CGRectMake(0, 0, reportPopup.view.frame.size.width, reportPopup.view.frame.size.height)];

    [self.navigationController pushViewController:reportPopup animated:YES];
    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        if([subview isKindOfClass:[ChatNavigationView class]])
            subview.userInteractionEnabled = NO;
    }
   
}

- (IBAction)onTapViewProfile:(id)sender {
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [userProfile getProfileInfo:^(void){
        for(UIView* subview in [self.navigationController.navigationBar subviews]){
            if([subview isKindOfClass:[ChatNavigationView class]])
                [subview removeFromSuperview];
        }
        VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
        [viewProfile loadProfile:userProfile];
        [viewProfile addDoneItemController];
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:viewProfile animated:YES];
    }];
}
#pragma mark -
#pragma mark Table view delegates

static CGFloat padding_top = 10.0;
static CGFloat padding_left = 10.0;
static float defaultAvatarWidth = 40;
static float defaultAvatarHeight = 40;
static float cellWidth = 320;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *s = [messages getMessageAtIndex:indexPath.row];
	static NSString *CellIdentifier = @"MessageCellIdentifier";
	
	SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
    {
        cell = [[SMMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.avatarImageView.tag = indexPath.row;
	}

	NSString *sender = [s objectForKey:@"sender"];
	NSString *time = [s objectForKey:@"time"];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	UIImage *bgImage = nil;
    
    [[cell.messageContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.messageContentView.frame = [[messages.frames objectAtIndex:indexPath.row] CGRectValue];
    NSArray *messageSubViews = messages.messageContentViews[indexPath.row];
    for (UIView *subView in messageSubViews)
    {
        [cell.messageContentView addSubview:subView];
    }
    
    NSDate* date = [NSString getDateWithString:time];
	cell.senderAndTimeLabel.text = dateToStringInterval(date);
    [cell.senderAndTimeLabel sizeToFit];
		
	if (![sender isEqualToString:@"you"])
    { // left aligned
        // message from friend
		bgImage = [[UIImage imageNamed:@"ChatView_white_speech.png"] stretchableImageWithLeftCapWidth:14  topCapHeight:14];
		
		[cell.messageContentView setFrame:CGRectMake(2*padding_left, padding_top, cell.messageContentView.frame.size.width, cell.messageContentView.frame.size.height)];
        
		[cell.bgImageView setFrame:CGRectMake(padding_left + defaultAvatarWidth,
											  padding_top,
											  cell.messageContentView.frame.size.width + 3 * padding_left,
											  cell.messageContentView.frame.size.height + padding_top)];
        
        [cell.avatarImageView setHidden:NO];
        [cell.avatarImageView setFrame:CGRectMake(padding_left, padding_top + cell.bgImageView.frame.size.height - defaultAvatarHeight, defaultAvatarWidth, defaultAvatarHeight)];
        [cell.avatarImageView setBackgroundImage:[UIImage imageNamed:@"Default Avatar"] forState:UIControlStateNormal];
        [appDel.imagePool getImageAtURL:userProfile.s_Avatar asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize)
         {
             if (img && isFirstLoad)
             {
                 [self.tView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
             }
             else if (img)
             {
                 [cell.avatarImageView setBackgroundImage:img forState:UIControlStateNormal];
             }
         }];
        [cell.senderAndTimeLabel setFrame:CGRectMake(cell.bgImageView.frame.origin.x + cell.bgImageView.frame.size.width + padding_left,
                                                     cell.bgImageView.frame.origin.y + cell.bgImageView.frame.size.height - cell.senderAndTimeLabel.frame.size.height,
                                                     cell.senderAndTimeLabel.frame.size.width, cell.senderAndTimeLabel.frame.size.height)];

        cell.userInteractionEnabled = YES;
        
        cell.customView.frame = CGRectMake(0, 0, cell.senderAndTimeLabel.frame.origin.x + cell.senderAndTimeLabel.frame.size.width + padding_left,
                                cell.avatarImageView.frame.origin.y + cell.avatarImageView.frame.size.height + padding_top);
	}
    else
    {
        //message from my own
		bgImage = [[UIImage imageNamed:@"ChatView_blue_speech.png"] stretchableImageWithLeftCapWidth:14  topCapHeight:14];
		
		[cell.messageContentView setFrame:CGRectMake(padding_left, padding_top, cell.messageContentView.frame.size.width + padding_left, cell.messageContentView.frame.size.height)];
        
		[cell.bgImageView setFrame:CGRectMake(2*padding_left + cell.senderAndTimeLabel.frame.size.width,
											  padding_top,
											  cell.messageContentView.frame.size.width + 2 * padding_left,
											  cell.messageContentView.frame.size.height + padding_top)];
        
        [cell.avatarImageView setHidden:YES];
//        [cell.avatarImageView setFrame:CGRectMake(padding_left + cell.bgImageView.frame.origin.x + cell.bgImageView.frame.size.width,
//                                                  padding_top + cell.bgImageView.frame.size.height - defaultAvatarHeight, defaultAvatarWidth, defaultAvatarHeight)];
//        [cell.avatarImageView setBackgroundImage:avatar_me forState:UIControlStateNormal];
        [cell.senderAndTimeLabel setFrame:CGRectMake(padding_left,
                                                     cell.bgImageView.frame.origin.y + cell.bgImageView.frame.size.height - cell.senderAndTimeLabel.frame.size.height,
                                                     cell.senderAndTimeLabel.frame.size.width, cell.senderAndTimeLabel.frame.size.height)];
        
        cell.userInteractionEnabled = YES;
        
        cell.customView.frame = CGRectMake(0, 0, cell.bgImageView.frame.origin.x + cell.bgImageView.frame.size.width + padding_left,
                                cell.bgImageView.frame.origin.y + cell.bgImageView.frame.size.height + padding_top);
        cell.customView.frame = CGRectMake(cellWidth - cell.customView.frame.size.width, cell.customView.frame.origin.y, cell.customView.frame.size.width, cell.customView.frame.size.height);
    }
    
	cell.bgImageView.image = bgImage;
    
    [cell.contentView bringSubviewToFront:cell.avatarImageView];
	return cell;
}

#define textMeasurePadding 15

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!cellHeight)
    {
        cellHeight = [[NSMutableArray alloc] init];
    }
    
    if (cellHeight.count <= indexPath.row)
    {
        SMMessageViewTableCell* cell = (SMMessageViewTableCell*) [self tableView:self.tView cellForRowAtIndexPath:indexPath];
        
        [cellHeight addObject:[NSNumber numberWithFloat:(cell.customView.frame.size.height + padding_top)]];
    }
    
    return [[cellHeight objectAtIndex:indexPath.row] floatValue];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [messages count];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


#pragma mark -
#pragma mark Chat delegates


- (void)newMessageReceived:(NSDictionary *)messageContent {
    // Vanancy - reset count of Notification of new chat unread
    appDel.myProfile.unread_message = 0;
	NSString* sender = [messageContent objectForKey:@"sender"];
    if(![sender isEqualToString:chatWithUser])
        return;
    
    NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
    NSString* hangout_id = [chunks objectAtIndex:0];
	NSString *m = [messageContent objectForKey:@"msg"];
    NSString* time = [NSString getCurrentTime];
	[messages addMessage:[[HistoryMessage alloc] initMessageFrom:hangout_id atTime:time toHangout:appDel.myProfile.s_ID withContent:m]];
    
	[self.tView reloadData];
    NSLog(@"messages.count:%d",messages.count);
    
    int topIndex = 0;
    if (messages && (messages.count > 0)) {
        topIndex = messages.count - 1;
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:topIndex inSection:0];
        
        NSLog(@"topIndexPath: %@",topIndexPath);
        NSLog(@"self.tView: %@",self.tView);
        
        [self.tView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    }
    
    [appDel.myProfile resetUnreadMessageWithFriend:userProfile];
    userProfile.status = ChatViewed;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setLblTyping:nil];
    [self setLabel_header:nil];
    [self setLabel_Age:nil];
    [appDel.notificationCenter removeObserver:self forKeyPath:userChangedNotificationName];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMessage:messageField.text];
    self.messageField.text = @"";
    return false;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    scrollView.frame = CGRectMake(0, 5, screenWidth, screenHeight - 5);
    [self scrollToLastAnimated:YES];
    
    [self.scrollView removeGestureRecognizer:dismissKeyboardGesture];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    messageField = textField;
    messageField.returnKeyType = UIReturnKeySend;
    
    NSLog(@"textFieldDidBeginEditing ...");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing ...");
}

- (void)keyboardWillShown:(NSNotification*)aNotification {
    [self dismissStickerChooseTabs:nil];
    
    if (![self.scrollView.subviews containsObject:self.tView])
    {
        [self.scrollView addSubview:self.tView];
        [self.tView setAlpha:0];
        [UIView animateWithDuration:0.5 animations:^{
            [self.firstViewMatchView setAlpha:0];
            [self.tView setAlpha:1];
        } completion:^(BOOL finished) {
            [self.firstViewMatchView removeFromSuperview];
        }];
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    NSLog(@"screen.height: %f, keyboard.height: %f", screenHeight, kbSize.height);
    scrollView.frame = CGRectMake(0, 5, screenWidth, screenHeight - kbSize.height - 5);
    
    [self scrollToLastAnimated:NO];
    
    if (!dismissKeyboardGesture)
    {
        dismissKeyboardGesture = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(dismissKeyboard:)];
    }
    
    [self.scrollView addGestureRecognizer:dismissKeyboardGesture];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(void)backToPreviousView{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark smiley collection datasource / delegate
#define SMILEY_SIZE 32
#define SMILEY_PADDING 6

#define STICKER_SIZE 50
#define STICKER_PADDING 80.0/3

-(void)initEmoticons
{
    static float collectionWidth = 280;
    
    EmoticonDisplayData *smileys = [[EmoticonDisplayData alloc] init];
    smileys.cellSize = CGSizeMake(SMILEY_SIZE, SMILEY_SIZE);
    smileys.cellPadding = SMILEY_PADDING;
    smileys.chatEmoticon = [[OakClubChatEmoticon instance] chatEmoticonForName:key_emoticon_smileys];
    smileys.numberOfItems = smileys.chatEmoticon.emoticonKeys.count;
    smileys.numberOfColumns = (collectionWidth  + SMILEY_PADDING) / (SMILEY_SIZE + SMILEY_PADDING);
    smileys.numberOfRows = 1 + smileys.numberOfItems / smileys.numberOfColumns;
    smileys.onTouched = @selector(smileyTouched:);
    
    EmoticonDisplayData *stickers1 = [[EmoticonDisplayData alloc] init];
    stickers1.cellSize = CGSizeMake(STICKER_SIZE, STICKER_SIZE);
    stickers1.cellPadding = STICKER_PADDING;
    stickers1.chatEmoticon = [[OakClubChatEmoticon instance] chatEmoticonForName:key_emoticon_sticker_1];
    stickers1.numberOfItems = stickers1.chatEmoticon.emoticonKeys.count;
    stickers1.numberOfColumns = (collectionWidth + STICKER_PADDING) / (STICKER_SIZE + STICKER_PADDING);
    stickers1.numberOfRows = 1 + stickers1.numberOfItems / stickers1.numberOfColumns;
    stickers1.onTouched = @selector(stiker1Touched:);
    
    chatEmoticons = @[smileys, stickers1];
}

-(PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *smileyChooseCellID = @"smileyChooseCellID";
    
    SmileyChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:smileyChooseCellID forIndexPath:indexPath];
    
    if (cell)
    {
        int stickerGroupIndex = collectionView.tag;
        EmoticonDisplayData *emotDisplayData = chatEmoticons[stickerGroupIndex];
        
        int smileyIndex = indexPath.section * emotDisplayData.numberOfColumns + indexPath.row;
        ChatEmoticon *chatEmoticon = emotDisplayData.chatEmoticon;
        NSString *smileyText = [chatEmoticon.emoticonKeys objectAtIndex:smileyIndex];
        
        [cell setEmoticon:[chatEmoticon getEmoticonData:smileyText]];
        [cell.smileyButton addTarget:self action:emotDisplayData.onTouched forControlEvents:UIControlEventTouchUpInside];
        cell.smileyButton.tag = smileyIndex;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    int stickerGroupIndex = collectionView.tag;
    EmoticonDisplayData *emotDisplayData = chatEmoticons[stickerGroupIndex];
    
    return emotDisplayData.numberOfRows;
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    int stickerGroupIndex = collectionView.tag;
    EmoticonDisplayData *emotDisplayData = chatEmoticons[stickerGroupIndex];
    
    return (section < emotDisplayData.numberOfRows - 1)?emotDisplayData.numberOfColumns:(emotDisplayData.numberOfItems % emotDisplayData.numberOfColumns);
}

-(void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmoticonDisplayData *emotsDData = [chatEmoticons objectAtIndex:self.stickerChooseTabs.tabsView.tag];
    ChatEmoticon *emots = emotsDData.chatEmoticon;
    
    int smileyIndex = (indexPath.section * emotsDData.numberOfColumns + indexPath.row);
    NSString *stickerText = [emots.emoticonKeys objectAtIndex:smileyIndex];
    
    self.messageField.text = [self.messageField.text stringByAppendingString:stickerText];
    [self dismissStickerChooseTabs:self];
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmoticonDisplayData *emotsDData = [chatEmoticons objectAtIndex:collectionView.tag];
    
    return emotsDData.cellSize;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    EmoticonDisplayData *emotsDData = [chatEmoticons objectAtIndex:collectionView.tag];
    
    return emotsDData.cellPadding;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    EmoticonDisplayData *emotsDData = [chatEmoticons objectAtIndex:collectionView.tag];
    
    return emotsDData.cellPadding;
}

#pragma mark sticker choose tab delegate

-(void)initStickerChooseTabs
{
    float bottom = 410;
    if (IS_HEIGHT_GTE_568)
    {
        bottom += 88;
    }
    self.stickerChooseTabs = [[StickerChooseTabs alloc] initWithFrame:CGRectMake(20, bottom, 280, 150)];
    self.stickerChooseTabs.delegate = self;
    
    [self.stickerChooseTabs reloadData];
    
    [self.stickerChooseTabs setHidden:YES];
    [self.scrollView addSubview:self.stickerChooseTabs];
}

-(void)stickerChooseTabs:(StickerChooseTabs *)stChooseTabs customizeStickerView:(UIView *)contentView atIndex:(int)index
{
    CGRect stickerCollectionFrame = CGRectMake(0, 10, contentView.frame.size.width, contentView.frame.size.height - 20);
    
    PSUICollectionView *stickerCollection = [self createSmileyCollectionWithFrame:stickerCollectionFrame];
    stickerCollection.tag = contentView.tag;
    [stickerCollection reloadData];
    
    [contentView addSubview:stickerCollection];
}

-(PSUICollectionView *)createSmileyCollectionWithFrame:(CGRect)frame
{
    static NSString *smileyChooseCellID = @"smileyChooseCellID";
    
    PSUICollectionViewFlowLayout *layout = [PSUICollectionViewFlowLayout new];
    layout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
    PSUICollectionView *smileyCollection = [[PSUICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    smileyCollection.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    smileyCollection.backgroundColor = [UIColor clearColor];
    smileyCollection.pagingEnabled = false;
    
    [smileyCollection registerClass:[SmileyChooseCell class] forCellWithReuseIdentifier:smileyChooseCellID];
    smileyCollection.dataSource = self;
    smileyCollection.delegate = self;
    
    return smileyCollection;
}


#define DEFAULT_COLOR [UIColor colorWithRed:121.0/255 green:1.0/255 blue:88.0/255 alpha:1]
#define HIGHLIGHT_COLOR [UIColor colorWithRed:88.0/255 green:1.0/255 blue:88.0/255 alpha:1]
-(void)stickerChooseTabs:(StickerChooseTabs *)stChooseTabs customizeTabButton:(UIButton *)button atIndex:(int)index
{
    NSString *title = nil;
    switch (index) {
        case 0:
            title = [@"Smileys" localize];
            break;
        case 1:
            title = [@"Stickers" localize];
            break;
        default:
            title = @"???";
            break;
    }
    
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:DEFAULT_COLOR];
}

-(float)stickerChooseTabsHeightOfTabsView:(StickerChooseTabs *)stChooseTabs
{
    return 30;
}

-(int)stickerChooseTabsNumberOfTab:(StickerChooseTabs *)stChooseTabs
{
    return chatEmoticons.count;
}

-(void)stickerChooseTabs:(StickerChooseTabs *)stChooseTabs selectedTab:(int)oldIndex isChangedTo:(int)newIndex
{
    UIButton *oldButton = stChooseTabs.tabButtons[oldIndex];
    [oldButton setBackgroundColor:DEFAULT_COLOR];
    
    UIButton *newSelectedButton = stChooseTabs.tabButtons[newIndex];
    [newSelectedButton setBackgroundColor:HIGHLIGHT_COLOR];
}

-(void)dismissStickerChooseTabs:(id)sender
{
    if (!self.stickerChooseTabs.hidden)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self.stickerChooseTabs setFrame:CGRectMake(self.stickerChooseTabs.frame.origin.x,
                                                        self.stickerChooseTabs.frame.origin.y + self.stickerChooseTabs.frame.size.height,
                                                        self.stickerChooseTabs.frame.size.width,
                                                        self.stickerChooseTabs.frame.size.height)];
            [self.tView setFrame:CGRectMake(self.tView.frame.origin.x,
                                            self.tView.frame.origin.y,
                                            self.tView.frame.size.width,
                                            self.tView.frame.size.height + self.stickerChooseTabs.frame.size.height)];
            [self.textInputView setFrame:CGRectMake(self.textInputView.frame.origin.x,
                                                    self.textInputView.frame.origin.y + self.stickerChooseTabs.frame.size.height,
                                                    self.textInputView.frame.size.width,
                                                    self.textInputView.frame.size.height)];
            
            [self scrollToLastAnimated:YES];
            [self.tView reloadData];
        } completion:^(BOOL finished) {
            [self.stickerChooseTabs setHidden:YES];
            
            // remove gesture
            [self.tView removeGestureRecognizer:dismissSmileyCollectionGesture];
            [self.messageField becomeFirstResponder];
        }];
    }
}

#pragma mark smiley button
- (IBAction)smileyButtonTouched:(id)sender {
    if (self.stickerChooseTabs.hidden)
    {
        [self dismissKeyboard:sender];
        [self.stickerChooseTabs setHidden:NO];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.stickerChooseTabs setFrame:CGRectMake(self.stickerChooseTabs.frame.origin.x,
                                                        self.stickerChooseTabs.frame.origin.y - self.stickerChooseTabs.frame.size.height,
                                                        self.stickerChooseTabs.frame.size.width,
                                                        self.stickerChooseTabs.frame.size.height)];
            [self.tView setFrame:CGRectMake(self.tView.frame.origin.x,
                                            self.tView.frame.origin.y,
                                            self.tView.frame.size.width,
                                            self.tView.frame.size.height - self.stickerChooseTabs.frame.size.height)];
            [self.textInputView setFrame:CGRectMake(self.textInputView.frame.origin.x,
                                                    self.textInputView.frame.origin.y - self.stickerChooseTabs.frame.size.height,
                                                    self.textInputView.frame.size.width,
                                                    self.textInputView.frame.size.height)];
            
            [self scrollToLastAnimated:YES];
            [self.tView reloadData];
        } completion:^(BOOL finished) {
            if (!dismissSmileyCollectionGesture)
            {
                dismissSmileyCollectionGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(dismissStickerChooseTabs:)];
            }
            
            [self.tView addGestureRecognizer:dismissSmileyCollectionGesture];
        }];
    }
}

-(void)smileyTouched:(UIButton *)sender
{
    EmoticonDisplayData *smileysDD = [chatEmoticons objectAtIndex:self.stickerChooseTabs.selectedIndex];
    ChatEmoticon *smileys = smileysDD.chatEmoticon;
    NSString *smileyText = [smileys.emoticonKeys objectAtIndex:sender.tag];
    
    self.messageField.text = [self.messageField.text stringByAppendingString:smileyText];
}

-(void)stiker1Touched:(UIButton *)sender
{
    EmoticonDisplayData *stDD = [chatEmoticons objectAtIndex:self.stickerChooseTabs.selectedIndex];
    ChatEmoticon *stickers = stDD.chatEmoticon;
    NSString *stickerKey = [stickers.emoticonKeys objectAtIndex:sender.tag];
    NSString *stickerDomain = [OakClubChatEmoticon instance].stickerDomainLink;
    CGSize stickerSize = [OakClubChatEmoticon instance].stickerSize;
    
    NSString *stickerText = [NSString stringWithFormat:@"<img src=\"%@%@.png\" width=\"%d\" height=\"%d\" type=\"%@\"/>",
                             stickerDomain, stickerKey, (int)stickerSize.width, (int)stickerSize.height, key_sticker];
    
    [self sendMessage:stickerText];
    
    [self dismissStickerChooseTabs:self];
}

#pragma mark NOTIFICATION
-(void)onChatUserChanged:(id)sender
{
    Profile *newProfile = [sender object];
    userProfile = newProfile;
    
    [self.tView reloadData];
}
@end



@implementation SMChat_FirstViewMatchView
{
    Profile *matchedProfile;
    AppDelegate *appDel;
}

#define FIRSTMATCH_TEXTS [NSArray arrayWithObjects:@"Cupid shot both of you!",\
@"This must be fate!",\
@"You are mean to be together.",\
@"What a lovely couple!",\
@" You have found the way to love.",\
@"Love is in the air now.",\
@"Seems like %@ likes you too!",\
@"Let's make a romantic story now!",\
@"%@ also has a crush on you!",\
@"Find out more about %@ now!",\
@"Don't hesitate to chat with %@ now!",\
@"Don't be shy! Say \"Hi\" to %@ now!",\
@"Did you see any couple start without a chat?",\
@"Show your confidence! %@ will love it.",\
@"Your kids would be beautiful!",\
@"%@ is still shy. Chat with %@ now",\
@"Why not inviting %@ to a drink?",\
@"Miracle cannot start without a chat",\
@"Say something sweet!",\
@"Show %@ how awesome you are!", nil];

NSArray *randomTexts;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        appDel = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setMatchedProfile:(Profile *)profile andImagepool:(ImagePool *)imgPool
{
    if (!randomTexts)
    {
        randomTexts = FIRSTMATCH_TEXTS;
    }
    
    matchedProfile = profile;
    
    [self updateLabels];
    
    [self circlizeAvatar];
    [imgPool getImageAtURL:profile.s_Avatar asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        if (!self.imgAvatar.image)
        {
            [self.imgAvatar setImage:img];
        }
    }];
}

-(void)updateLabels
{
    NSString *matchedName = matchedProfile.firstName;
    self.lblMatchedWith.text = [NSString stringWithFormat:@"%@ %@", [@"You matched with " localize], matchedName];
    
    NSString *matchTime = matchedProfile.match_time;
    NSDate* date = [NSString getDateWithString:matchTime];
    NSString *timeInterval = dateToStringInterval(date);
    self.lblMatchedTime.text = timeInterval;
    
    int randomTextIndex = random() % (randomTexts.count);
    NSString *randomedText = randomTexts[randomTextIndex];
    randomedText = [randomedText localize];
    if (randomedText)
    {
        self.lblMatchText.text = [NSString stringWithFormat:randomedText, matchedName, matchedName];
    }
}

-(void)circlizeAvatar
{
    [self.imgAvatar.layer setCornerRadius:(self.imgAvatar.layer.frame.size.width / 2)];
    [self.imgAvatar.layer setMasksToBounds:YES];
}

-(void)localizeAllViews
{
    [super localizeAllViews];
    
    [self updateLabels];
}

-(void)animateWithCompletion:(void(^)(void))completion
{
    CGAffineTransform idTransform = self.transform;
    CGAffineTransform transform1 = CGAffineTransformScale(idTransform, 0.1, 0.1);
    CGAffineTransform transform2 = CGAffineTransformScale(idTransform, 1.1, 1.1);
    CGAffineTransform transform3 = CGAffineTransformScale(idTransform, 0.9, 0.9);
    
    self.transform = transform1;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = transform2;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = transform3;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.transform = idTransform;
            } completion:^(BOOL finished) {
                if (completion)
                {
                    completion();
                }
            }];
        }];
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
@end

@implementation EmoticonDisplayData
@synthesize cellSize, cellPadding, numberOfItems, numberOfColumns, numberOfRows, chatEmoticon, onTouched;
@end
