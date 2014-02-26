//
//  menuViewController.h
//  oakclubbuild
//
//  Created by VanLuu on 3/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface menuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *imageNames;
    NSMutableArray *menuArray;
    NSString *username;
    NSString *numPoints;
    UIImage *imageAvatar;
    NSMutableArray *numberNotifications;
    NSDictionary *nameIndex;
}
@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *numCoins;
- (IBAction)onTouchAvatar:(id)sender;


-(void)setUsername:(NSString *)_name;
-(void) setUIInfo:(Profile*)profile;
- (void)refreshMenu;
//- (IBAction)goToChat:(id)sender;
//- (IBAction)goToMyLink:(id)sender;
//- (IBAction)goToSnapshoot:(id)sender;
//
//- (IBAction)goToVisitor:(id)sender;
//- (IBAction)logOut:(id)sender;
//- (IBAction)goToHangOut:(id)sender;
//+(void) downloadAvatarImage:(NSString*)link;


-(void)setChatNotification:(int)n_messages;
-(void)setVisitorsNotification:(int)n_visitors;
-(void)setMyLinksNotification:(int)n_mutualAttractions;

@end
