
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

#import "WordWarpParse.h"
#import "ChatEmoticon.h"
#import "HistoryMessage+init.h"
#import "VCSimpleSnapshot.h"
#import "VCReportPopup.h"

@interface SMChatViewController() <ImageRequester>

@end

@implementation SMChatViewController
{
    __strong NSMutableDictionary *_requestsImage;
    NSMutableArray* a_messages;
    EmoticonString *textMsg;
    NSMutableArray *smileyLayers;
    AppDelegate* appDel;
}


@synthesize messageField, chatWithUser, tView, scrollView,lblTyping, avatar_me, avatar_friend, label_header, label_Age,btnMoreOption, btnShowProfile, imgLogo, btnBackToPrevious;


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

-(Profile*)getProfilebyID:(NSString*)profile_id
{
    appDel = [self appDelegate];
    
    Profile* profile;
    
    if(profile_id == nil)
    {
        profile = appDel.myProfile;
    }
    else
    {
        profile = [appDel.friendChatList objectForKey:profile_id];
    }
    
    return profile;
}

//-(void)getUserInfo:(NSString*)profile_id
//{
//    AppDelegate* appDel = [self appDelegate];
//    
//    Profile* profile;
//    
//    if(profile_id == nil)
//    {
//        profile = appDel.myProfile;
//    }
//    else
//    {
//        profile = [appDel.friendChatList objectForKey:profile_id];
//    }
//    
//    userAge = [NSString stringWithFormat:@", %@", profile.s_age];
//    userName = profile.s_Name;
//    
//    //return [NSString stringWithFormat:@"%@, %@", profile.s_Name, profile.s_age];
//}

-(void)initMessages:(NSString*)profile_id
{
    messages = [[MessageStorage alloc] initWithProfileID:profile_id];
    
    for(int i = 0; a_messages!=nil && i < [a_messages count]; i++)
    {
        HistoryMessage* item = [a_messages objectAtIndex:i];
        [messages addMessage:item];
    }
}

- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile withAvatar:(UIImage*)avatar withMessages:(NSMutableArray*) array
{
    if (self = [super init])
    {
        //[self getUserInfo:userName];
        
        userProfile = _profile;
		chatWithUser = _userName; // @ missing
		turnSockets = [[NSMutableArray alloc] init];
        
//        userAge = [NSString stringWithFormat:@", %@", _profile.s_age];
        userName = _profile.s_Name;
//        userName = [NSString formatStringWithName:_profile.s_Name andAge:_profile.s_age andNameLength:18];
        [self registerForKeyboardNotifications];
        
        NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
        NSString* hangout_id = [chunks objectAtIndex:0];
        
        a_messages = array;
        [self initMessages:hangout_id];
        
        avatar_friend = avatar;
        
        Profile* myProfile = [self getProfilebyID:nil];
        //Vanancy - change load avatar
        avatar_me = myProfile.img_Avatar;
//        avatar_me = [UIImage imageNamed:@"Default Avatar.png"];
//        [myProfile tryGetImageAsync:self];
        
	}
	
	return self;
}

-(void)setImage:(UIImage *)img
{
    avatar_me = img;
}

- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile 
{

	if (self = [super init])
    {
        messages = [[MessageStorage alloc ] initWithProfileID:_profile.s_ID];
        
        //[self getUserInfo:userName];
        userProfile = _profile;
        userAge = [NSString stringWithFormat:@", %@", _profile.s_age];
//        userName = _profile.s_Name;
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
        
        //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSString* link = _profile.s_Avatar;//[self getAvatarUrl:chatWithUser];
        if( ![link isEqualToString:@""] )
        {
            
            AFHTTPRequestOperation* operation = [Profile getAvatarSync:link callback:^(UIImage *avatar) {
                avatar_friend = avatar;
            }];
            [operation start];
            //[queue addOperation:operation];
            //[queue waitUntilAllOperationsAreFinished];
        }
        else
        {
            avatar_friend = [UIImage imageNamed:@"Default Avatar.png"];
        }
        
        link = [self getProfilebyID:nil];
        
        if( ![link isEqualToString:@""] )
        {
            
            AFHTTPRequestOperation* operation = [Profile getAvatarSync:link callback:^(UIImage *avatar) {
                avatar_me = avatar;
            }];
            [operation start];
            //[queue addOperation:operation];
        }
        else
        {
            avatar_me = [UIImage imageNamed:@"Default Avatar.png"];
        }

        //[queue waitUntilAllOperationsAreFinished];

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
    appDel._messageDelegate = self;
    //NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
    //NSString* hangout_id = [chunks objectAtIndex:0];
    
    //[self initMessages:hangout_id];
    
    [tView reloadData];

    [self scrollToLastAnimated:NO];
//    self.navigationItem.titleView = infoHeader;
    
    [self customNavigationHeader];
}
-(void)viewWillDisappear:(BOOL)animated{
    appDel._messageDelegate =nil;
}
-(void)customNavigationHeader{
    [self.navigationController.navigationBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *infoHeader= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [btnBackToPrevious setFrame:CGRectMake(8, 14, btnBackToPrevious.frame.size.width, btnBackToPrevious.frame.size.height)];
    [btnBackToPrevious addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    [infoHeader addSubview:btnBackToPrevious];
    label_header.frame = CGRectMake(60, 0, label_header.frame.size.width, 44);
    [infoHeader addSubview:label_header];
    
    [btnShowProfile setFrame:CGRectMake(244, 8, btnShowProfile.frame.size.width, btnShowProfile.frame.size.height)];
    [infoHeader addSubview:btnShowProfile];
    [btnMoreOption setFrame:CGRectMake(282, 8, btnMoreOption.frame.size.width, btnMoreOption.frame.size.height)];
    [infoHeader addSubview:btnMoreOption];
    [imgLogo setFrame:CGRectMake(22, 8, imgLogo.frame.size.width, imgLogo.frame.size.height)];
    [infoHeader addSubview:imgLogo];
    
    //    label_Age.frame = CGRectMake(label_header.frame.size.width , -2, label_Age.frame.size.width, 44);
    //    [infoHeader addSubview:label_Age];
    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        [subview removeFromSuperview];
    }
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:infoHeader];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tView.delegate = self;
	self.tView.dataSource = self;
	[self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//	[self customBackButtonBarItem];
    [self customNavigationHeader];
    
	appDel = [self appDelegate];
	appDel._messageDelegate = self;
	[self.messageField becomeFirstResponder];
    
    [label_header setText:userName];
//    [label_header setTitle:userName forState:UIControlStateNormal];
//    [label_Age setText:userAge];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
//	XMPPJID *jid = [XMPPJID jidWithString:@"cesare@doolik.com"];
//	XMPPJID *jid = del.xmppStream.myJID;
    
    /*
    XMPPJID *jid;
    if ([del.xmppStream.myJID.user isEqualToString :[XMPPJID jidWithString:@"1lxv6mi27c@doolik.com"].user]) {
        jid = [XMPPJID jidWithString:@"1lxv6k7f2d@doolik.com"];
    }
    else {
        jid = [XMPPJID jidWithString:@"1lxv6mi27c@doolik.com"];
    }
     */
    /*
    XMPPJID *jid = [XMPPJID jidWithString:chatWithUser];
    
	NSLog(@"Attempting TURN connection to %@", jid);
	
	TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
	
	[turnSockets addObject:turnSocket];
	
	[turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
     */
    [self.navigationController setNavigationBarHidden:NO];
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
//    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    UINavigationController* activeVC = [appDel activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if(![vc isKindOfClass:[VCSimpleSnapshot class]] )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        [appDel.rootVC setFrontViewController:activeVC focusAfterChange:NO completion:^(BOOL finished) {
        }];
        [appDel.rootVC showViewController:appDel.chat];
    }
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

- (IBAction)sendMessage {
	
    NSString *messageStr = self.messageField.text;
	
    if([messageStr length] > 0)
    {
        [appDel sendMessageContent:messageStr to:chatWithUser];
        
        NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
        NSString* hangout_id = [chunks objectAtIndex:0];
        [HistoryMessage postMessage:hangout_id messageContent:messageStr];
        
		self.messageField.text = @"";
        
		NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
		[m setObject:[messageStr substituteEmoticons] forKey:@"msg"];
		[m setObject:@"you" forKey:@"sender"];
        
        NSString* time = [NSString getCurrentTime];
		[m setObject:time forKey:@"time"];
		
        
		[messages addMessage:[[HistoryMessage alloc] initMessageFrom:@"you" atTime:time toHangout:hangout_id withContent:messageStr]];
        //[self addMessage:messageStr atTime:time fromUser:[self appDelegate].myProfile.s_ID toUser:hangout_id];
		[self.tView reloadData];
        
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:(messages.count - 1) inSection:0];
        
        [self.tView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		
    }
}
- (IBAction)onTouchMoreOption:(id)sender {
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    NSArray *chunks = [chatWithUser componentsSeparatedByString: @"@"];
    NSString* hangout_id = [chunks objectAtIndex:0];
    VCReportPopup* reportPopup= [[VCReportPopup alloc]initWithProfileID:hangout_id];
    [self dismissKeyboard:sender];
    [reportPopup.view setFrame:CGRectMake(0, 0, reportPopup.view.frame.size.width, reportPopup.view.frame.size.height)];
//    [self.view addSubview:reportPopup.view];
    [self.navigationController pushViewController:reportPopup animated:NO];
}

- (IBAction)onTapViewProfile:(id)sender {
//    UINavigationController* activeVC = [appDel activeViewController];
//    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
//    if([vc isKindOfClass:[VCSimpleSnapshot class]])
//    {
//        VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
//        [viewProfile loadProfile:userProfile andImage:avatar_friend];
//        
//        [vc.navigationController pushViewController:viewProfile animated:YES];
//    }
//    else
//        [vc.navigationController popViewControllerAnimated:YES];
    [userProfile getProfileInfo:^(void){
        VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
        [viewProfile loadProfile:userProfile andImage:avatar_friend];
        
#if ENABLE_DEMO
        //    [appDel.rootVC setFrontViewController:appDel.chat focusAfterChange:YES completion:^(BOOL finished) {
        //
        //    }];
#endif
        //vanancy ; bug crash on iOS7
        [viewProfile setShowNavigationBar:YES];
        [self.navigationController presentModalViewController:viewProfile animated:NO];
//        [self.navigationController setNavigationBarHidden:NO];
        
    }];
//    
    
    
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
        //cell = [[SMMessageViewTableCell alloc] initWithFrame:CGRectZero];
        cell = [[SMMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.avatarImageView.tag = indexPath.row;
        //[cell.avatarImageView addTarget:self action:@selector(onTapViewProfile:) forControlEvents:UIControlEventTouchUpInside];
	}

	NSString *sender = [s objectForKey:@"sender"];
//	NSString *message = [s objectForKey:@"msg"];
	NSString *time = [s objectForKey:@"time"];
    
    NSLog(@"sender:%@; row:%d; content:%@", sender, indexPath.row, [s valueForKey:@"msg"]);
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	UIImage *bgImage = nil;
    
    [[cell.messageContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.messageContentView.frame = [[messages.frames objectAtIndex:indexPath.row] CGRectValue];
    for (UIView *subView in [messages.messageContentViews objectAtIndex:indexPath.row])
    {
        [cell.messageContentView addSubview:subView];
    }
    
    NSDate* date = [NSString getDateWithString:time];
	cell.senderAndTimeLabel.text = dateToStringInterval(date);
    [cell.senderAndTimeLabel sizeToFit];
		
	if (![sender isEqualToString:@"you"])
    { // left aligned
		bgImage = [[UIImage imageNamed:@"ChatView_blue_speech.png"] stretchableImageWithLeftCapWidth:14  topCapHeight:14];
		
		[cell.messageContentView setFrame:CGRectMake(2*padding_left, padding_top, cell.messageContentView.frame.size.width, cell.messageContentView.frame.size.height)];
        
		[cell.bgImageView setFrame:CGRectMake(padding_left + defaultAvatarWidth,
											  padding_top,
											  cell.messageContentView.frame.size.width + 3 * padding_left,
											  cell.messageContentView.frame.size.height + padding_top)];
        
        [cell.avatarImageView setFrame:CGRectMake(padding_left, padding_top + cell.bgImageView.frame.size.height - defaultAvatarHeight, defaultAvatarWidth, defaultAvatarHeight)];
        [cell.avatarImageView setBackgroundImage:avatar_friend forState:UIControlStateNormal];
        //[UIImage imageNamed:@"action-people.png"];
        [cell.senderAndTimeLabel setFrame:CGRectMake(cell.bgImageView.frame.origin.x + cell.bgImageView.frame.size.width + padding_left,
                                                     cell.bgImageView.frame.origin.y + cell.bgImageView.frame.size.height - cell.senderAndTimeLabel.frame.size.height,
                                                     cell.senderAndTimeLabel.frame.size.width, cell.senderAndTimeLabel.frame.size.height)];

        cell.userInteractionEnabled = YES;
        
        cell.customView.frame = CGRectMake(0, 0, cell.senderAndTimeLabel.frame.origin.x + cell.senderAndTimeLabel.frame.size.width + padding_left,
                                cell.avatarImageView.frame.origin.y + cell.avatarImageView.frame.size.height + padding_top);
	}
    else
    {
        
		bgImage = [[UIImage imageNamed:@"ChatView_white_speech.png"] stretchableImageWithLeftCapWidth:14  topCapHeight:14];
		
		[cell.messageContentView setFrame:CGRectMake(padding_left, padding_top, cell.messageContentView.frame.size.width + padding_left, cell.messageContentView.frame.size.height)];
        
		[cell.bgImageView setFrame:CGRectMake(2*padding_left + cell.senderAndTimeLabel.frame.size.width,
											  padding_top,
											  cell.messageContentView.frame.size.width + 2 * padding_left,
											  cell.messageContentView.frame.size.height + padding_top)];
        
        [cell.avatarImageView setFrame:CGRectMake(padding_left + cell.bgImageView.frame.origin.x + cell.bgImageView.frame.size.width,
                                                  padding_top + cell.bgImageView.frame.size.height - defaultAvatarHeight, defaultAvatarWidth, defaultAvatarHeight)];
        [cell.avatarImageView setBackgroundImage:avatar_me forState:UIControlStateNormal];
        [cell.senderAndTimeLabel setFrame:CGRectMake(padding_left,
                                                     cell.bgImageView.frame.origin.y + cell.bgImageView.frame.size.height - cell.senderAndTimeLabel.frame.size.height,
                                                     cell.senderAndTimeLabel.frame.size.width, cell.senderAndTimeLabel.frame.size.height)];
        
        cell.userInteractionEnabled = YES;
        
        cell.customView.frame = CGRectMake(0, 0, cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + padding_left,
                                cell.avatarImageView.frame.origin.y + cell.avatarImageView.frame.size.height + padding_top);
        cell.customView.frame = CGRectMake(cellWidth - cell.customView.frame.size.width, cell.customView.frame.origin.y, cell.customView.frame.size.width, cell.customView.frame.size.height);
    }
    
	cell.bgImageView.image = bgImage;
    //double timeInterval = [time doubleValue];
    //NSTimeInterval intervalForTimer = timeInterval;
	
//    [cell.contentView sizeToFit];
    
    [cell.contentView bringSubviewToFront:cell.avatarImageView];
	return cell;
}

#define textMeasurePadding 15

NSMutableArray *cellHeight;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!cellHeight)
    {
        cellHeight = [[NSMutableArray alloc] init];
    }
    
    /*
	NSDictionary *dict = (NSDictionary *)[messages objectAtIndex:indexPath.row];
	NSString *msg = [dict objectForKey:@"msg"];
	
	CGSize  textSize = { 320.0/2, CGFLOAT_MAX };
	CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:14.0]
				  constrainedToSize:textSize 
					  lineBreakMode:UILineBreakModeWordWrap];
	
	size.height += padding_top*4;
    
	CGFloat height = size.height < 65 ? 65 : size.height;
     return height;*/
    
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
    
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setDateFormat:@"dd-MM-yyyfy HH:mm:ss"];
    //NSDate *date = [dateFormat dateFromString:item.timeStr];
    NSString* time = [NSString getCurrentTime];
    
	[messages addMessage:[[HistoryMessage alloc] initMessageFrom:[chunks objectAtIndex:0] atTime:time toHangout:appDel.myProfile.s_ID withContent:m]];
    [self addMessage:m atTime:time fromUser:hangout_id toUser:appDel.myProfile.s_ID ];
	[self.tView reloadData];

	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1 
												   inSection:0];
	
	[self.tView scrollToRowAtIndexPath:topIndexPath 
					  atScrollPosition:UITableViewScrollPositionMiddle 
							  animated:YES];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[self.messageField resignFirstResponder];
    
    [self sendMessage];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    scrollView.frame = CGRectMake(0, 5, screenWidth, screenHeight - 5);
    [self scrollToLastAnimated:YES];
    
    UITapGestureRecognizer *tap = [scrollView.gestureRecognizers objectAtIndex:0];
    [self.scrollView removeGestureRecognizer:tap];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    messageField = textField;
    
    messageField.returnKeyType = UIReturnKeySend;
    
    NSLog(@"textFieldDidBeginEditing ...");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //messageField = nil;
    
    NSLog(@"textFieldDidEndEditing ...");
}

- (BOOL)textField:(UITextField *)txtField shouldChangeCharactersInRange:(NSRange)rng replacementString:(NSString *)repString
{
    return true;
    
    if (!smileyLayers)
    {
        smileyLayers = [[NSMutableArray alloc] init];
    }
    
    if (!textMsg)
    {
        textMsg = [[EmoticonString alloc] init];
    }
    
    if ([repString isEqualToString:@""])    //backSpace
    {
        [textMsg removeCharactersInRange:rng];
    }
    else
    {
        [textMsg insertString:repString atIndex:rng.location];
    }
    
    NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[[[WordWarpParse alloc] init] parseEmoticonsForText:textMsg.textString withEmoticonData:[[ChatEmoticon instance] allKeys]] copyItems:false];
    
    [smileyLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [smileyLayers removeAllObjects];
    
    UIFont *font = txtField.font;
    float tabSize = 30;
    NSMutableString *text = [[NSMutableString alloc] init];
    float curPos = 0;
    
    for (NSString *component in components)
    {
        if ([[[ChatEmoticon instance] allKeys] containsObject:component])
        {
            CALayer *smiley = [[CALayer alloc] init];
            UIImage *smileyImg = [[ChatEmoticon instance] objectForKey:component];
            smiley.contents =  (id) [smileyImg CGImage];
            float scaleRatio = smileyImg.size.width / tabSize;
            smiley.frame = CGRectMake(curPos, 0, smileyImg.size.width / scaleRatio, smileyImg.size.height / scaleRatio);
            [text appendString:@"\t"];
            curPos += tabSize;
            
            [txtField.layer addSublayer:smiley];
            [smileyLayers addObject:smiley];
        }
        else
        {
            [text appendString:component];
            curPos += [component sizeWithFont:font].width;
        }
    }
    
    txtField.text = text;
    
    return false;
}


- (void)keyboardWasShown:(NSNotification*)aNotification {
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGRect bkgndRect = messageField.superview.frame;
//    bkgndRect.size.height += kbSize.height;
//    [messageField.superview setFrame:bkgndRect];
//    [scrollView setContentOffset:CGPointMake(0.0, 480-260) animated:YES];
//    scrollView.backgroundColor = [UIColor redColor];
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    NSLog(@"screen.height: %f, keyboard.height: %f", screenHeight, kbSize.height);
    scrollView.frame = CGRectMake(0, 5, screenWidth, screenHeight - kbSize.height - 5);
    
    [self scrollToLastAnimated:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.scrollView addGestureRecognizer:tap];
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
#if ENABLE_DEMO
//    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    UINavigationController* activeVC = [appDel activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if(![vc isKindOfClass:[VCSimpleSnapshot class]] )
    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else
//    {
        [self.navigationController popViewControllerAnimated:YES];
        [appDel.rootVC setFrontViewController:activeVC focusAfterChange:NO completion:^(BOOL finished) {
        }];
        [appDel.rootVC showViewController:appDel.chat];
    }
#else
    [self.navigationController popViewControllerAnimated:YES];
#endif
}

@end