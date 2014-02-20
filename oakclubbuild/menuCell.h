//
//  menuCell.h
//  oakclubbuild
//
//  Created by VanLuu on 4/5/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface menuCell : UITableViewCell{
    IBOutlet UIImageView *itemMenu;
    IBOutlet UIImageView *iconMenu;
    UIView *view;
}
@property (weak, nonatomic) IBOutlet UILabel *labelMenu;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedIconImage;

- (void) setItemMenu:(NSString *)imageName AndlabelName:(NSString*)label;
- (void) setNotification:(int)nNotifications;
- (void) setItemBackground:(UIImage*)image andHighlight:(UIImage*)highlightImage;
- (void) setItemIcon:(UIImage*)image;
@end
