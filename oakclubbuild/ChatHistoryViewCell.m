//
//  ChatHistoryViewCell.m
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ChatHistoryViewCell.h"

@implementation ChatHistoryViewCell

@synthesize avatar, name, age_near, last_message, date_history, labelMutualFriends;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatHistoryViewCell" owner:self options:nil];
        
        if ([array count]>0) {
            UIView* view = [array objectAtIndex:0];
            
            self.frame = CGRectMake(0, 0, 320, 70);

            //NSLog(@"view name : %f", self.frame.size.height);
            [self.contentView addSubview:view];
                        //self.frame
        }
        
        self.shouldIndentWhileEditing = NO;
    }
    return self;
}

- (void)setMutualFriends:(NSUInteger)nMutualFriends
{
    [labelMutualFriends setText:[NSString stringWithFormat:@"%d", nMutualFriends]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
