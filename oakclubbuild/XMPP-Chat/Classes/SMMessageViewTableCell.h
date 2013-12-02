//
//  SMMessageViewTableCell.h
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SMMessageViewTableCell : UITableViewCell {

	UILabel	*senderAndTimeLabel;
	UIView *messageContentView;
	UIImageView *bgImageView;
    UIButton *avatarImageView;
	UIView *customView;
}

@property (strong, nonatomic) UILabel *senderAndTimeLabel;
@property (strong, nonatomic) UIView *messageContentView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIButton *avatarImageView;
@property (strong, nonatomic) UIView *customView;

@end
