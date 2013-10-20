//
//  ProfileCell.m
//  oakclubbuild
//
//  Created by VanLuu on 5/28/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ProfileCell.h"
#import "Define.h"
@implementation ProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil];
        
        if ([array count]>0) {
            view = [array objectAtIndex:0];
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
+ (NSString *)reuseIdentifier {
    return @"ProfileCellIdentifier";
}
- (void) setNames:(NSString *)value AndKeyName:(NSString*)key{
    keyName.text = key;
    valueName.text = value;
    [keyName setFont:FONT_NOKIA(15.0)];
    [valueName setFont:FONT_NOKIA(15.0)];
}
@end
