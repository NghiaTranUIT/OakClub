//
//  ChatHistoryViewCell.m
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ChatHistoryViewCell.h"
#import "Define.h"

@implementation ChatHistoryViewCell

@synthesize avatar, name, age_near, last_message, date_history, labelMutualFriends,imgChat, imgMatched;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatHistoryViewCell" owner:self options:nil];
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = avatar.frame.size.width/2;
        avatar.layer.borderWidth = 2.0;
        avatar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        if ([array count]>0) {
            UIView* view = [array objectAtIndex:0];
            
            self.frame = CGRectMake(0, 0, 320, 75);

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

-(void)setStatus:(int)status{
    switch (status) {
        case MatchUnViewed:
        {
            [imgMatched setHidden:NO];
            [imgMatched setHighlighted:YES];
            [imgChat setHidden:YES];
            break;
        }
        case MatchViewed:
        {
            [imgMatched setHidden:NO];
            [imgMatched setHighlighted:NO];
            [imgChat setHidden:YES];
            break;
        }
        case ChatUnviewed:
        {
            [imgChat setHidden:NO];
            [imgChat setHighlighted:YES];
            [imgMatched setHidden:YES];
            break;
        }
        case ChatViewed:
        {
            [imgChat setHidden:NO];
            [imgChat setHighlighted:NO];
            [imgMatched setHidden:YES];
            break;
        }
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
