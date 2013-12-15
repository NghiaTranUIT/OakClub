//
//  VCChat.h
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SMChatViewController.h"
#import "Profile.h"
#import "SMMessageDelegate.h"
@interface VCChat : UIViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, SMMessageDelegate>
{
//,UITableViewDelegate,UITableViewDataSource>{†
    NSFetchedResultsController *fetchedResultsController;
    NSMutableDictionary* a_messages;
    BOOL isChatLoaded;
    Profile* selectedProfile;
}
@property BOOL isChatLoaded;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingFriendList;

- (IBAction)pushTest:(id)sender;
//@property (strong, nonatomic) IBOutlet RootViewController *tbVC_ChatList;
-(void)loadFriendsInfo;
-(void)reloadFriendList;
@end
