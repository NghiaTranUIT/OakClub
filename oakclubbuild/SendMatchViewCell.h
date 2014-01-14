//
//  SendMatchViewCell.h
//  OakClub
//
//  Created by Salm on 1/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchMakerItem.h"

@interface SendMatchViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friend1Avatar;
@property (weak, nonatomic) IBOutlet UIImageView *friend2Avatar;
@property (weak, nonatomic) IBOutlet UIImageView *linkImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime_Status;
@property (weak, nonatomic) IBOutlet UILabel *lblSendStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;
@end
