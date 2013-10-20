//
//  ProfileCell.h
//  oakclubbuild
//
//  Created by VanLuu on 5/28/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell{
    IBOutlet UILabel *keyName;
    IBOutlet UILabel *valueName;
    UIView *view;

}
+ (NSString *)reuseIdentifier;
- (void) setNames:(NSString *)value AndKeyName:(NSString*)key;
//@property (strong, nonatomic) IBOutlet UILabel *keyName;
//@property (strong, nonatomic) IBOutlet UILabel *valueName;
@end
