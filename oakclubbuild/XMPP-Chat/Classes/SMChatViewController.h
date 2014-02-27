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
#import "PSTCollectionView.h"
#import "ImagePool.h"

@interface SMChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SMMessageDelegate, UITextFieldDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegateFlowLayout> {

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
@property (strong, nonatomic) IBOutlet UIButton *btnBackToPrevious;

@property (nonatomic,strong) IBOutlet UITextField *messageField;
@property (nonatomic,strong) NSString *chatWithUser;
@property (nonatomic,strong) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblTyping;

-(void)showIsType:(BOOL)show;
- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile;
- (id) initWithUser:(NSString *) _userName withProfile:(Profile*)_profile withMessages:(NSMutableArray*) array;
- (IBAction) closeChat;

@end


@interface SMChat_FirstViewMatchView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblMatchedWith;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchedTime;
@property (weak, nonatomic) IBOutlet UILabel *lblMatchText;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

-(void)setMatchedProfile:(Profile *)profile andImagepool:(ImagePool *)imgPool;
-(void)animateWithCompletion:(void(^)(void))completion;
@end

