//
//  ChatHistoryViewCell.h
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatHistoryViewCell : UITableViewCell
{

}

@property (nonatomic, strong) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *age_near;
@property (nonatomic, weak) IBOutlet UILabel *last_message;
@property (nonatomic, weak) IBOutlet UILabel *date_history;
@property (weak, nonatomic) IBOutlet UILabel *labelMutualFriends;
@property (weak, nonatomic) IBOutlet UIImageView *imgMatched;
@property (weak, nonatomic) IBOutlet UIImageView *imgChat;

- (void)setMutualFriends:(NSUInteger)nMutualFriends;
-(void)setStatus:(int)status;
@end
