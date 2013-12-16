//
//  ProfileInfoCell.m
//  OakClub
//
//  Created by Salm on 12/16/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ProfileInfoCell.h"

@interface ProfileInfoCell()
{
    UIImage *titleImg;
    NSString *detailText;
}
@end

@implementation ProfileInfoCell
@synthesize imgViewTitle, lblDetail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //[[NSBundle mainBundle] loadNibNamed:@"ProfileInfoCell" owner:self options:nil];
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ProfileInfoCell" owner:self options:nil];
        
        if ([array count]>0) {
            UIView *view = [array objectAtIndex:0];
            [self.contentView addSubview:view];
            //            view.frame = CGRectMake(0, 0, 320, 35);
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setTitleImage:(UIImage *)img
{
    titleImg = img;
}

-(void)setDetailText:(NSString *)txt
{
    detailText = txt;
}
@end
