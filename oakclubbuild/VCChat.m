//
//  VCChat.m
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCChat.h"
#import "AppDelegate.h"

#import "XMPPFramework.h"
#import "DDLog.h"

#import "ChatHistoryViewCell.h"

#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"
#import "HistoryMessage+init.h"
#import "Profile.h"

#import "NSString+Utils.h"
#import "UIView+Localize.h"

#import "LoadingIndicator.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface VCChat () <LoadingIndicatorDelegate>{
    AppDelegate *appDel;
    NSIndexPath* selectedIndex;
    NSMutableArray *friendChatIDs;
    LoadingIndicator *indicator;
}

@property UIButton* buttonEditNormal;
@property UIButton* buttonEditPressed;
@property NSString* searchResult;
@property BOOL scopeButtonPressedIndexNumber;
@property (weak, nonatomic) IBOutlet UIView *dismissSearchView;
@end

@implementation VCChat
//@synthesize tbVC_ChatList;

@synthesize loadingFriendList, tableView;
@synthesize isChatLoaded, buttonEditNormal, buttonEditPressed;

int cellCountinSection=0;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:[appDel languageBundle]];
    if (self) {
        // Custom initialization
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
        a_messages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)loadFriendsInfo{
    NSLog(@"***** loadFriendsInfo begin!");
    double current = CFAbsoluteTimeGetCurrent();
    NSLog(@"Start %lf", current);
    
//    NSMutableArray* a_profile_id = [[NSMutableArray alloc] init];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if (!(appDel.friendChatList == NULL || appDel.friendChatList.count <= 0))
    {
//        [indicator lockViewAndDisplayIndicator];
        
        [loadingFriendList startAnimating];
        [self.view bringSubviewToFront:loadingFriendList];
        loadingFriendList.hidden = NO;
        __block int i = [appDel.friendChatList count];
        
        NSOperationQueue *getHistoryQueue = [[NSOperationQueue alloc] init];
        for(NSString* key in [appDel.friendChatList allKeys])
        {
            Profile* profile = [appDel.friendChatList objectForKey:key];
            NSLog(@"Loading information for %@", profile.s_Name);
            
            if(profile.status > MatchViewed && ![a_messages valueForKey:profile.s_ID])
            {
                NSOperation *op = [HistoryMessage getHistoryMessages:profile.s_ID callback:^(NSMutableArray* array)
                 {
                     if (array)
                     {
                         if([[appDel.friendChatList allKeys] lastObject]== key){
                             [loadingFriendList stopAnimating];
                             loadingFriendList.hidden = YES;
                         }
                         [a_messages setObject:array forKey:profile.s_ID];
                         [self.searchDisplayController.searchResultsTableView reloadData];
                         [[self tableView] reloadData];
                         NSLog(@"Get History Msg of %@ completed",profile.s_ID);
                     }
                     
                     --i;
                     if (!i)
                     {
//                         [indicator unlockViewAndStopIndicator];
                         fetchedResultsController = nil;
                         [self reloadFriendChatIDs];
                     }
                 }];
                
                [getHistoryQueue addOperation:op];
            }
            else
            {
                --i;
                if (!i)
                {
//                    [indicator unlockViewAndStopIndicator];
                    fetchedResultsController = nil;
                    [self reloadFriendChatIDs];
                }
            }
        }
    }
    
    double end = CFAbsoluteTimeGetCurrent();
    NSLog(@"End %lf", end);
    NSLog(@"Delta %lf", end - current);
    NSLog(@"***** loadFriendsInfo end!");
}

-(void)addTopRightButtonWithAction:(SEL)action
{
    buttonEditNormal = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonEditNormal.frame = CGRectMake(0, 0, 35, 30);
    [buttonEditNormal addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonEditNormal setBackgroundImage:[UIImage imageNamed:@"header_btn_setting.png"] forState:UIControlStateNormal];
    [buttonEditNormal setBackgroundImage:[UIImage imageNamed:@"header_btn_setting_pressed.png"] forState:UIControlStateHighlighted];
    
    buttonEditPressed = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonEditPressed.frame = CGRectMake(0, 0, 35, 30);
    [buttonEditPressed addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonEditPressed setBackgroundImage:[UIImage imageNamed:@"header_btn_setting_pressed.png"] forState:UIControlStateNormal];
    [buttonEditPressed setBackgroundImage:[UIImage imageNamed:@"header_btn_setting.png"] forState:UIControlStateHighlighted];

    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditNormal];
    
    self.navigationItem.rightBarButtonItem = buttonItem;
}

-(void)enterEditing
{
    [self.tableView setEditing:!tableView.editing animated:YES];
    //[buttonEdit setSelected:!buttonEdit.selected];
    //[tableView reloadData];
    
    NSLog(@"enterEditing");
    
    UIBarButtonItem *buttonItem;
    
    if(tableView.editing == YES)
    {
        buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditPressed];
    }
    else
    {
        buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditNormal];
    }
    
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushTest:(id)sender {
//    
//    VCMyLink *myLink = [[VCMyLink alloc] initWithNibName:@"VCMyLink" bundle:nil];
//    [self.navigationController pushViewController:myLink animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)showNotifications
{
    int totalNotifications = [appDel countTotalNotifications];
    
    [[self navBarOakClub] setNotifications:totalNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    double current = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewWillAppear Start %lf", current);
//    fetchedResultsController = nil;
    [self.navigationController setNavigationBarHidden:YES];
    NSString* title_1 = [NSString localizeString:@"Matches"];
    NSString* title_2 = [NSString localizeString:@"VIPs"];
    NSString* title_3 = [NSString localizeString:@"All"];
    NSString* searchText =[NSString localizeString:@"Search your matches ..."];
    NSString* searchPleaceholder= [@"Search your matches ..." localize];
    [self.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:title_1,title_2,title_3,nil]];
    [self.searchBar setText:searchText];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:FONT_HELVETICANEUE_LIGHT(12.0)];
    [self.searchBar setPlaceholder: searchPleaceholder];
    self.searchResult = nil;
    [self.searchBar setShowsCancelButton:NO];
    [self.searchBar setShowsSearchResultsButton:NO];
    [self.searchBar setSelectedScopeButtonIndex:2];
    /*
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = UITextAlignmentCenter;
    
	if ([[self appDelegate] connect])
	{
		titleLabel.text = [[[[self appDelegate] xmppStream] myJID] bare];
	} else
	{
		titleLabel.text = @"No JID";
	}
	
	[titleLabel sizeToFit];
    
	self.navigationItem.titleView = titleLabel;
     */

//    if(isChatLoaded == TRUE)
//    {
//        [self loadChatView:selectedProfile animated:YES];
//    }
#if ENABLE_DEMO
#else
    [self showNotifications];
#endif
    
    //	[super viewWillAppear:animated];
    
    double end = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewWillAppear End %lf", end);
    NSLog(@"viewWillAppear Delta %lf", end - current);
}

- (void)viewWillDisappear:(BOOL)animated
{
    //	[[self appDelegate] disconnect];
    //	[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
	
	[super viewWillDisappear:animated];
    
//    fetchedResultsController = nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    double current = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewDidAppear Start %lf", current);
    
    fetchedResultsController = nil;
    [self.tableView reloadData];
    
    double end = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewDidAppear End %lf", end);
    NSLog(@"viewDidAppear Delta %lf", end - current);
    
    [super viewDidAppear:animated];
//    [self addTopRightButtonWithAction:@selector(enterEditing)];
//    fetchedResultsController = nil;
//    [appDel.myProfile getRosterListIDSync:^(void){
//        [self loadFriendsInfo:nil];
//        [self.searchDisplayController.searchResultsTableView reloadData];
//    }];
    
    appDel._messageDelegate = self;
}
- (void)viewDidUnload {
    //    [self setTbVC_ChatList:nil];
    [self setLoadingFriendList:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    
    a_messages = nil;
}
- (void)viewDidLoad
{
    double current = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewDidLoad Start %lf", current);
    [super viewDidLoad];
//    appDel._messageDelegate = self;
    // Do any additional setup after loading the view from its nib.
    //    [self.view addSubview:tbVC_ChatList.view];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-edit.png"]];
    
    indicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:self];
    
    [self.searchDisplayController.searchResultsTableView removeFromSuperview];
    
    isChatLoaded = FALSE;
    
    [self customSearchBar];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(dismissKeyboard)];
    
    [self.dismissSearchView addGestureRecognizer:tap];
    
    double end = CFAbsoluteTimeGetCurrent();
    NSLog(@"viewDidLoad End %lf", end);
    NSLog(@"viewDidLoad Delta %lf", end - current);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)fetchedResultsController
{
//    if ([[self appDelegate] connect])
//    {
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        __block NSError *contexterror = nil;
        [moc performBlockAndWait:^{
            [moc save:&contexterror];
        }];
        
        if (contexterror)
        {
            // handle the error.
            NSLog(@"Error on NSManagedObjectContext");
        }

		if(moc == nil){
             NSLog(@"Error on NSManagedObjectContext");
            return nil;
        }

		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		//NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
        //searchResult is a NSString
        //[fetchRequest setPredicate:[[NSPredicate alloc] init]];
        if(self.searchResult != nil && [self.searchResult length] > 0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName CONTAINS[cd] %@",self.searchResult];
            [fetchRequest setPredicate:predicate];
        }
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
        [self reloadFriendChatIDs];
    }

	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[self.searchDisplayController.searchResultsTableView reloadData];
	[[self tableView] reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	}
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#if ENABLE_DEMO
    return 0.0f;
#else
	return 30.0f;
#endif
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
#if ENABLE_DEMO
   return nil;
#else
    NSString *headerName= @"";
    NSArray *sections = [[self fetchedResultsController] sections];
	
    //NSLog(@"Sections count: %d", [sections count]);
    
	if (section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
		int section = [sectionInfo.name intValue];
        
        //NSLog(@"sectionIndex: %d, in section: %d", sectionIndex, section);
        
		switch (section)
		{
			case 0  :
                headerName =  @"Available";
                break;
			case 1  :
                headerName =  @"Away";
                break;
			default :
                headerName =  @"Offline";
		}
	}
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(40, 0, 280, 30)];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bar.png"]]];
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, 280, 30)];
    [name setText:headerName];
    [name setTextColor:[UIColor whiteColor]];
    [name setBackgroundColor:[UIColor clearColor]];
    [name setFont:FONT_NOKIA(20.0)];
    [headerView addSubview:name];
    return headerView;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;//[[[self fetchedResultsController] sections] count];
}

//- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
//{
//	NSArray *sections = [[self fetchedResultsController] sections];
//	
//    //NSLog(@"Sections count: %d", [sections count]);
//    
//	if (sectionIndex < [sections count])
//	{
//		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
//        
//		int section = [sectionInfo.name intValue];
//        
//        //NSLog(@"sectionIndex: %d, in section: %d", sectionIndex, section);
//        
//		switch (section)
//		{
//			case 0  : return @"Available";
//			case 1  : return @"Away";
//			default : return @"Offline";
//		}
//	}
//	
//	return @"";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (!fetchedResultsController)
    {
        [self reloadFriendChatIDs];
    }
    
    return friendChatIDs.count;
}

-(void)reloadFriendChatIDs
{
    friendChatIDs = [[NSMutableArray alloc] init];
    
    NSArray *sections = [[self fetchedResultsController] sections];
    for (int i = 0; i < [sections count]; ++i)
    {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
        
        NSLog(@"Number of objects: %d in section %d", sectionInfo.numberOfObjects, i);
        
        for (int j = 0; j < sectionInfo.numberOfObjects; j++)
        {
            //            NSLog(@"sectioninfo object ai index : %i",j);
            XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            XMPPJID* xmpp_jid = [user jid];
            NSString* jid = [xmpp_jid user];//[NSString stringWithFormat:@"%@@%@", [xmpp_jid user], [xmpp_jid domain]];
            //NSLog(@"User %d: %@", j + 1, user);
            //            NSLog(@"XMPPUserCoreDataStorageObject - jid :%i , %@",j,jid);
            Profile* profile =[appDel.myProfile.dic_Roster valueForKey:jid];
            if(profile == nil)
                continue;
            if ([self isValidFriendWithMatch:profile])
            {
                bool isContained = NO;
                for (NSString *_jid in friendChatIDs)
                {
                    if ([_jid isEqualToString:jid] || ([jid isEqualToString:appDel.myProfile.s_ID]))
                    {
                        isContained = YES;
                        break;
                    }
                }
                if (!isContained)
                {
                    [friendChatIDs addObject:jid];
                }
            }
        }
    }
    
    NSLog(@"Number of friends %i", friendChatIDs.count);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATETIME_FORMAT];
    [friendChatIDs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Profile *p1, *p2;
        p1 = [appDel.myProfile.dic_Roster objectForKey:obj1];
        p2 = [appDel.myProfile.dic_Roster objectForKey:obj2];
        
        //            MatchUnViewed,
        //            MatchViewed,
        //            ChatUnviewed,
        //            ChatViewed,
        //            NSLog(@"p1.s_Name: %@, p1.status: %d", p1.s_Name, p1.status);
        //            NSLog(@"p2.s_Name: %@, p2.status: %d", p2.s_Name, p2.status);
        
        if (p1.status != p2.status)
        {
            switch (p1.status) {
                case 0:
                case 2:
                    switch (p2.status) {
                        case 1:
                        case 3:
                            return NSOrderedAscending;
                        default:
                            return [self compareDateWithProfile1:p1 andProfile2:p2];
                            break;
                    }
                    break;
                case 1:
                case 3:
                    switch (p2.status) {
                        case 0:
                        case 2:
                            return NSOrderedDescending;
                        default:
                            return [self compareDateWithProfile1:p1 andProfile2:p2];
                            break;
                    }
                default:
                    return [self compareDateWithProfile1:p1 andProfile2:p2];
                    break;
            }
        }
        
        return [self compareDateWithProfile1:p1 andProfile2:p2];
    }];
    
    [tableView reloadData];
}

- (NSComparisonResult)compareDateWithProfile1:(Profile *)profile1 andProfile2:(Profile *)profile2
{
    NSDate *d1, *d2;
    d1 = [self getLastTimeMessageFromProfile:profile1];
    d2 = [self getLastTimeMessageFromProfile:profile2];
    
    return ([d2 compare:d1]);
}

- (NSDate *)getLastTimeMessageFromProfile:(Profile *)profile
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATETIME_FORMAT];
    
    if(profile.status > MatchViewed){
        NSMutableArray* messages = [a_messages objectForKey:profile.s_ID];
        
        if(messages != nil)
        {
            HistoryMessage* m = (HistoryMessage*)[messages lastObject];
            
            if(m != nil && m.timeStr)
            {
                return [dateFormatter dateFromString:m.timeStr];
            }
        }
    }
    else{
        return [dateFormatter dateFromString:[profile match_time]];
    }
    
    return nil;
}

- (BOOL) isValidFriendWithMatch:(Profile *)friend
{
    if (self.searchBar.selectedScopeButtonIndex == 0)
    {
        return friend.is_match;
    }
    else if (self.searchBar.selectedScopeButtonIndex == 1)
    {
        return friend.is_vip;
    }
    
    return  true;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES or NO
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0)
    {
//        lblResult.text = @" Your selected NO.";
    }else if(buttonIndex == 1)
    {
//        lblResult.text = @" Your selected YES.";
        
        Profile* profile = [appDel.friendChatList objectForKey:[NSString stringWithFormat:DOMAIN_AT_FMT, [friendChatIDs objectAtIndex:selectedIndex.row]]];
        NSLog(@"Removed user %@", profile.s_ID);
        
        XMPPJID* xmpp_jid = (XMPPJID*) profile.s_usenameXMPP;
        
        [appDel.xmppRoster removeUser:xmpp_jid];
        
        
        [HistoryMessage deleteChatHistory:profile.s_ID];
    }
    
}

-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete your data
        // Delete the table cell
        
        selectedIndex = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[@"Confirm!" localize]
                              message:@"Do you want to delete this conversation?"
                              delegate: self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil];
        [alert localizeAllViews];
        [alert show];
        
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tbView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ChatHistoryViewCell";
	
    
	__block ChatHistoryViewCell *cell = (ChatHistoryViewCell*)[tbView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ChatHistoryViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

	}
	/*XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    XMPPJID* xmpp_jid = [user jid];
    
    NSString* jid = [xmpp_jid bare];//[NSString stringWithFormat:@"%@@%@", [xmpp_jid user], [xmpp_jid domain]];*/
    Profile* profile = [appDel.friendChatList objectForKey:[NSString stringWithFormat:DOMAIN_AT_FMT, [friendChatIDs objectAtIndex:indexPath.row]]];
		
    if(profile)
    {
        cell.name.text = profile.firstName;
//        [cell setMatched:profile.is_match];
        [cell setStatus:profile.status];
//        UIImage* avatar = [a_avatar objectForKey:profile.s_ID];
//        
//        if(avatar != nil)
//        {
//            [cell.avatar setImage:avatar];
        //        }
        [cell.avatar setImage:[UIImage imageNamed:@"Default Avatar"]];
        [appDel.imagePool getImageAtURL:profile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize)
         {
             if (img && isFirstLoad)
             {
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
             }
             else if (img)
             {
                 [cell.avatar setImage:img];
             }
         }];
//        [cell setMutualFriends:profile.num_MutualFriends];
        
        cell.last_message.text = @"";
        cell.date_history.text = @"";
        cell.lblMatched.text = @"";
        
        if(profile.status > MatchViewed){
            NSMutableArray* messages = [a_messages objectForKey:profile.s_ID];
            
            if(messages != nil)
            {
                HistoryMessage* m = (HistoryMessage*)[messages lastObject];
                
                if(m != nil)
                {
                    cell.last_message.text = m.body;
                    cell.date_history.text = m.timeStr;
                    cell.lblMatched.text = [NSString stringWithFormat:@"%@ %@", [@"Last messages on" localize],m.timeStr];
                }
            }
        }
        else{
            //profile.s_status_time = [profile.s_status_time stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            cell.lblMatched.text = [NSString stringWithFormat:@"%@ %@", [@"Matched on" localize],profile.match_time];
        }
        
    }
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Profile* profile = [appDel.friendChatList objectForKey:[NSString stringWithFormat:DOMAIN_AT_FMT, [friendChatIDs objectAtIndex:indexPath.row]]];
    
    if(profile == nil)
        return;
    
    selectedProfile = profile;
    // Vanancy - reset count of Notification of new chat unread
    [self loadChatView:profile animated:YES];
    //isChatLoaded = TRUE;
}

-(void)loadChatView:(Profile*)profile animated:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    //SMChatViewController *chatController = [[SMChatViewController alloc] initWithUser:userName];
    [appDel.imagePool getImageAtURL:profile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad, NSString *urlWithSize) {
        NSMutableArray* array = [a_messages valueForKey:profile.s_ID];
        if (!array)
        {
            array = [[NSMutableArray alloc] init];
            [a_messages setObject:array forKey:profile.s_ID];
        }
        
        if (array  || profile.status <= MatchViewed)
        {
            SMChatViewController *chatController =
            [[SMChatViewController alloc] initWithUser:[NSString stringWithFormat:DOMAIN_AT_FMT, profile.s_ID]
                                           withProfile:profile
                                            withAvatar:img
                                          withMessages:array];
#if ENABLE_DEMO
            [appDel.rootVC setFrontViewController:appDel.chat focusAfterChange:YES completion:^(BOOL finished) {
                
            }];
#endif
            //        if(IS_OS_7_OR_LATER){
            //            [self.navigationController setNavigationBarHidden:NO];
            //            [self.navigationController presentModalViewController:chatController animated:animated];
            //        }
            //        else{
            [appDel.chat pushViewController:chatController animated:animated];
            //        }
        }
    }];
}

-(void)reloadFriendList
{
    [self.tableView reloadData];
}

#pragma mark SearchBar delegate

-(void) customSearchBar{
    [self.searchBar setTintColor:COLOR_PURPLE];
//    self.searchBar.scopeBar.segmentedControlStyle = UISegmentedControlStyleBar; //required for color change
    for (id subview in self.searchDisplayController.searchBar.subviews )
    {
        if([subview isMemberOfClass:[UISegmentedControl class]])
        {
            UISegmentedControl *scopeBar=(UISegmentedControl *) subview;
            scopeBar.tintColor =  COLOR_PURPLE;
//            scopeBar.segmentedControlStyle = UISegmentedControlStyleBar;
        }
    }
}
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    self.searchBar.showsScopeBar = YES;
//    [self.searchBar sizeToFit];
////    self.tableView.tableHeaderView = self.searchBar;
//    fetchedResultsController = nil;
//    [self.searchDisplayController.searchResultsTableView reloadData];
//    //∂[self reloadFriendList];
//    return YES;
//}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self dismissKeyboard];
}

- (void) dismissKeyboard
{
    // add self
    [self.searchBar resignFirstResponder];
    [self.dismissSearchView setHidden:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    if(searchText.length == 0)
//        return;
//   
    self.searchResult = searchText;
    fetchedResultsController = nil;
    //[self.searchDisplayController.searchResultsTableView reloadData];
	[[self tableView] reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    fetchedResultsController = nil;
    [searchBar endEditing:YES];
    [self.searchDisplayController.searchResultsTableView reloadData];
	[[self tableView] reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchResult = @"";
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //self.searchResult = nil;
    fetchedResultsController = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
	[[self tableView] reloadData];
    self.scopeButtonPressedIndexNumber = [[NSNumber numberWithInt:selectedScope] boolValue];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    if (self.searchResult == nil || [@"" isEqualToString:self.searchResult])
    {
        searchBar.text = @"";
    }
    
    [self.dismissSearchView setHidden:NO];
    return YES;
}
#pragma mark Chat delegates

- (void)newMessageReceived:(NSDictionary *)messageContent {
    NSString* sender = [messageContent objectForKey:@"sender"];
    NSString *msg = [messageContent objectForKey:@"msg"];
    NSArray *chunks = [sender componentsSeparatedByString: @"@"];
    NSString* hangout_id = [chunks objectAtIndex:0];
    NSString* time = [NSString getCurrentTime];
    HistoryMessage* newHistory =[[HistoryMessage alloc] initMessageFrom:hangout_id atTime:time toHangout:appDel.myProfile.s_ID withContent:msg];
    
    NSMutableArray *messages = [a_messages objectForKey:hangout_id];
    if (!messages)  // new people
    {
        messages = [[NSMutableArray alloc] init];
        [a_messages setObject:messages forKey:hangout_id];
    }
    
    [messages addObject:newHistory];
    
    Profile *friend = [appDel.friendChatList objectForKey:sender];
    if (!friend)
    {
        if(friend.status == MatchUnViewed)
            appDel.myProfile.new_mutual_attractions--;
    }
    friend.status = ChatUnviewed;
    [appDel.friendChatList setObject:friend forKey:sender];
    
    fetchedResultsController = nil;
    [self.tableView reloadData];
}

-(void)lockViewForIndicator:(LoadingIndicator *)indicator
{
    [appDel.rootVC.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}

-(void)unlockViewForIndicator:(LoadingIndicator *)indicator
{
    [appDel.rootVC.view setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}

-(void)customizeIndicator:(UIActivityIndicatorView *)_indicator ofLoadingIndicator:(LoadingIndicator *)loadingIndicator
{
    [_indicator setFrame:CGRectMake((320 - _indicator.frame.size.width) / 2,
                                    240,
                                    _indicator.frame.size.width, _indicator.frame.size.height)];
}
@end
