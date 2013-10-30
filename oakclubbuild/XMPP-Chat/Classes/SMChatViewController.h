//
//  SMChatViewController.h
//  jabberClient
//
//  Created by cesarerocchi on 7/16/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "TURNSocket.h"
#import "SMMessageDelegate.h"
#import "SMMessageViewTableCell.h"
#import "Profile.h"
#import "MessageStorage.h"

@interface SMChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SMMessageDelegate, UITextFieldDelegate> {

	UITextField		*messageField;
	NSString		*chatWithUser;
	UITableView		*tView;
	MessageStorage	*messages;
	NSMutableArray *turnSockets;
    
    NSString		*userName;
    NSString        *userAge;
    Profile         *userProfile;
}

@property (weak, nonatomic) IBOutlet UILabel *label_Age;
@property (strong, nonatomic) IBOutlet UILabel *label_header;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreOption;
@property (strong, nonatomic) IBOutlet UIButton *btnShowProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;
@property (strong, nonatomic) IBOutlet UIButton *btnBackToPrevious;

@property (nonatomic,strong) UIImage *avatar_me;
@property (nonatomic,strong) UIImage *avatar_friend;
@property (nonatomic,strong) IBOutlet UITextField *messageField;
@property (nonatomic,strong) NSString *chatWithUser;
@property (nonatomic,strong) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblTyping;

-(void)showIsType:(BOOL)show;
- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile;
- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile withAvatar:(UIImage*)avatar withMessages:(NSMutableArray*) array;
- (IBAction) sendMessage;
- (IBAction) closeChat;

@end
