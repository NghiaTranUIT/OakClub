//
//  ProfileInfoCell.h
//  OakClub
//
//  Created by Salm on 12/16/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

-(void)setTitleImage:(UIImage *)img;
-(void)setDetailText:(NSString *)txt;
@end
