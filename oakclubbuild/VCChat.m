//
//  VCChat.m
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCChat.h"
#import "VCMyLink.h"
#import "AppDelegate.h"

#import "XMPPFramework.h"
#import "DDLog.h"

#import "ChatHistoryViewCell.h"

#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"
#import "HistoryMessage.h"
#import "Profile.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface VCChat (){
    AppDelegate *appDel;
    NSIndexPath* selectedIndex;
    NSMutableArray *friendChatIDs;
}

@property UIButton* buttonEditNormal;
@property UIButton* buttonEditPressed;
@property NSString* searchResult;
@property BOOL scopeButtonPressedIndexNumber;
@end

@implementation VCChat
//@synthesize tbVC_ChatList;

@synthesize loadingFriendList, tableView;
@synthesize isChatLoaded, buttonEditNormal, buttonEditPressed;

int cellCountinSection=0;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString* path= [[NSBundle mainBundle] pathForResource:@"vi" ofType:@"lproj"];
    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    self = [super initWithNibName:nibNameOrNil bundle:languageBundle];
    if (self) {
        // Custom initialization
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    }
    return self;
}

-(void)loadFriendsInfo:(id)_arg {

    a_avatar = [[NSMutableDictionary alloc] init];
    a_messages = [[NSMutableDictionary alloc] init];
    
    NSLog(@"***** loadFriendsInfo begin!");
    
    NSMutableArray* a_profile_id = [[NSMutableArray alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if(appDel.friendChatList == NULL)
        return;
    for(NSString* key in [appDel.friendChatList allKeys])
    {
        Profile* profile = [appDel.friendChatList objectForKey:key];
        
        NSLog(@"Loading information for %@", profile.s_Name);
        
        [a_profile_id addObject:profile.s_ID];
        
        AFHTTPRequestOperation *operation =
        [HistoryMessage getHistoryMessagesSync:profile.s_ID
                                      callback:^(NSMutableArray * array)
         {
             [a_messages setObject:array forKey:profile.s_ID];
             NSLog(@"Get H Msg completed");
         }];
        //[operation start];
        [queue addOperation:operation];
        NSString* link = profile.s_Avatar;
        
        if(![link isEqualToString:@""])
        {
            AFHTTPRequestOperation *operation =
            [Profile getAvatarSync:link
                          callback:^(UIImage *image)
             {
                 
                 [a_avatar setObject:image forKey:profile.s_ID];
                 
                 NSLog(@"Download avatar done for %@", profile.s_Name);
             }];
            //[operation start];
            [queue addOperation:operation];
        }
    }
    
    [queue waitUntilAllOperationsAreFinished];
    
    NSString* s_profile_id = [a_profile_id componentsJoinedByString:@"|"];
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:s_profile_id,@"str_profile_id", nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    NSMutableURLRequest *url_request = [httpClient requestWithMethod:@"GET"
                                                            path:URL_getMutualInfo
                                                      parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:url_request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
     
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&e];
        NSMutableDictionary * data= [dict valueForKey:key_data];
        if(data != nil && [data count]>0)
        {
            for(NSString* key in [data allKeys])
            {
                Profile* profile = [appDel.friendChatList objectForKey:[NSString stringWithFormat:DOMAIN_AT_FMT, key]];
                NSMutableDictionary * friendData= [data objectForKey:key];
                
                if(friendData != nil)
                {
                    NSNumber* numberMutualFriends = [friendData valueForKey:@"mutualFriend"];
                    profile.numberMutualFriends = [numberMutualFriends intValue];
                }
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadMutualFriends ... Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
    
    [queue addOperation:operation];
    
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"***** loadFriendsInfo end!");
    
    [[self tableView] reloadData];
    
    [loadingFriendList stopAnimating];
    loadingFriendList.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.view addSubview:tbVC_ChatList.view];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-edit.png"]];
    
    [loadingFriendList startAnimating];
    [self.view bringSubviewToFront:loadingFriendList];
    loadingFriendList.hidden = NO;
    
    [NSThread detachNewThreadSelector:@selector(loadFriendsInfo:) toTarget:self withObject:nil];
    
    isChatLoaded = FALSE;
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
    
    VCMyLink *myLink = [[VCMyLink alloc] initWithNibName:@"VCMyLink" bundle:nil];
    [self.navigationController pushViewController:myLink animated:YES];
}

- (void)viewDidUnload {
//    [self setTbVC_ChatList:nil];
    [self setLoadingFriendList:nil];
    [self setTableView:nil];
    [super viewDidUnload];
   
    a_avatar = nil;
    a_messages = nil;
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
    AppDelegate* appDel = [UIApplication sharedApplication].delegate;
    int totalNotifications = [appDel countTotalNotifications];
    
    [[self navBarOakClub] setNotifications:totalNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    fetchedResultsController = nil;
    [self.navigationController setNavigationBarHidden:YES];
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
    [super viewDidAppear:animated];
    [self addTopRightButtonWithAction:@selector(enterEditing)];
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
        
        if (contexterror) {
            // handle the error.
            NSLog(@"Error on NSManagedObjectContext");
        }

		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
        //searchResult is a NSString
        if(self.searchResult != nil){
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
    }

	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
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
    return 70;
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
    friendChatIDs = [[NSMutableArray alloc] init];
    NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
        for (int i = 0; i < sectionInfo.numberOfObjects; ++i)
        {
            XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            XMPPJID* xmpp_jid = [user jid];
            NSString* jid = [xmpp_jid user];//[NSString stringWithFormat:@"%@@%@", [xmpp_jid user], [xmpp_jid domain]];
            NSLog(@"%@", appDel.myProfile.dic_Roster);
            bool v_isMatch = [[appDel.myProfile.dic_Roster valueForKey:jid] boolValue];
            if ([self isValidFriendWithMatch:v_isMatch])
            {
                [friendChatIDs addObject:jid];
            }
        }
        
		return friendChatIDs.count;
	}
    return 0;
     
}

- (BOOL) isValidFriendWithMatch:(BOOL)isMatch
{
    if (self.searchBar.selectedScopeButtonIndex == 0)
    {
        return isMatch;
    }
    else if (self.searchBar.selectedScopeButtonIndex == 1)
    {
        return !isMatch;
    }
    
    return  true;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES or NO
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0)
    {
//        lblResult.text = @" Your selected NO.";
    }else if(buttonIndex == 1)
    {
//        lblResult.text = @" Your selected YES.";
        
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:selectedIndex];
        
        XMPPJID* xmpp_jid = [user jid];
        
        NSString* jid = [xmpp_jid bare];
        NSArray *chunks = [jid componentsSeparatedByString: @"@"];
        NSString* hangout_id = [chunks objectAtIndex:0];
        
        NSLog(@"Removed user %@", hangout_id);
        
        [appDel.xmppRoster removeUser:xmpp_jid];
        
        
        [HistoryMessage deleteChatHistory:hangout_id];
    }
    
}

-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete your data
        // Delete the table cell
        
        selectedIndex = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Confirm!"
                              message:@"Do you want to delete this conversation?"
                              delegate: self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil];
        [alert show];
        
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ChatHistoryViewCell";
	
    
	__block ChatHistoryViewCell *cell = (ChatHistoryViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
//        if(profile.is_available)
//        {
//            [user setSection:0];
//        }
//        else
//        {
//            [user setSection:2];
//        }
        
        cell.name.text = profile.s_Name;
        cell.age_near.text = [NSString stringWithFormat:@"%@, %@", profile.s_age, profile.s_location.name];
        
        UIImage* avatar = [a_avatar objectForKey:profile.s_ID];
        
        if(avatar != nil)
        {
            [cell.avatar setImage:avatar];
        }
        
        //NSNumber* mutual_friends = [a_mutual_friends objectForKey:profile.s_ID];
        
        //if(mutual_friends != nil)
        [cell setMutualFriends:profile.numberMutualFriends];
        
        cell.last_message.text = @"";
        cell.date_history.text = @"";
        
        NSMutableArray* messages = [a_messages objectForKey:profile.s_ID];
        
        if(messages != nil)
        {
            HistoryMessage* m = (HistoryMessage*)[messages lastObject];
            
            if(m != nil)
            {
                cell.last_message.text = m.body;
                cell.date_history.text = m.timeStr;
            }
        }
        
        //[queue addOperation:operation];
        //[queue waitUntilAllOperationsAreFinished];
    }
	
	return cell;
    
    [self.view bringSubviewToFront:loadingFriendList];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Profile* profile = [appDel.friendChatList objectForKey:[NSString stringWithFormat:DOMAIN_AT_FMT, [friendChatIDs objectAtIndex:indexPath.row]]];
    
    if(profile == nil)
        return;
    
    selectedProfile = profile;
	[self loadChatView:profile animated:YES];
    
    //isChatLoaded = TRUE;
}

-(void)loadChatView:(Profile*)profile animated:(BOOL)animated
{
    //SMChatViewController *chatController = [[SMChatViewController alloc] initWithUser:userName];
    UIImage* avatar = [a_avatar valueForKey:profile.s_ID];
    NSMutableArray* array = [a_messages valueForKey:profile.s_ID];

    SMChatViewController *chatController =
    [[SMChatViewController alloc] initWithUser:[NSString stringWithFormat:DOMAIN_AT_FMT, profile.s_ID]
                                   withProfile:profile
                                    withAvatar:avatar
                                  withMessages:array];
#if ENABLE_DEMO
    [appDel.rootVC setFrontViewController:appDel.chat focusAfterChange:YES completion:^(BOOL finished) {
        
    }];
#endif
	[self.navigationController pushViewController:chatController animated:animated];


}

-(void)reloadFriendList
{
    [self.tableView reloadData];
}

#pragma mark SearchBar delegate
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsScopeBar = YES;
//    [self.searchBar sizeThatFits:CGSizeMake(272, 88)];
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
    return YES;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length == 0)
        return;
   
    self.searchResult = searchText;
    fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self.tableView reloadData];
    self.scopeButtonPressedIndexNumber = [NSNumber numberWithInt:selectedScope];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    if (self.scopeButtonPressedIndexNumber != nil) {
        self.scopeButtonPressedIndexNumber = nil; //reset
        return NO;
    }
    else {
        return YES;
    }
    
}
@end
