//
//  SendMatchViewCell.m
//  OakClub
//
//  Created by Salm on 1/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "SendMatchViewCell.h"

@implementation SendMatchViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SendMatchViewCell" owner:self options:nil];
        if ([array count]>0) {
            UIView* view = [array objectAtIndex:0];
            
            [self.contentView addSubview:view];
        }
        
        self.shouldIndentWhileEditing = NO;
        [self circlelizeAvatar];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)circlelizeAvatar
{
    [self.friend1Avatar.layer setCornerRadius:(self.friend1Avatar.frame.size.width / 2)];
    [self.friend1Avatar.layer setMasksToBounds:YES];
    [self.friend2Avatar.layer setCornerRadius:(self.friend2Avatar.frame.size.width / 2)];
    [self.friend2Avatar.layer setMasksToBounds:YES];
}
@end
