//
//  MatchMakerFriendCell.m
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "MatchMakerFriendCell.h"

#define FRIEND_NAME_LABEL_HEIGHT 32
@implementation MatchMakerFriendCell
{
    UIImageView *avatarBorder;
}
@synthesize friendAvatar, friendName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.friendAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,  frame.size.height - FRIEND_NAME_LABEL_HEIGHT)];
        self.friendName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.friendAvatar.frame.size.height, frame.size.width,FRIEND_NAME_LABEL_HEIGHT)];
        [self.friendName setTextAlignment:NSTextAlignmentCenter];
        [self.friendAvatar.layer setCornerRadius:(self.friendAvatar.layer.frame.size.width / 2)];
        [self.friendAvatar.layer setMasksToBounds:YES];
        
        [self.contentView addSubview:self.friendAvatar];
        [self.contentView addSubview:self.friendName];
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

@end
