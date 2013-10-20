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

@property (nonatomic) UILabel *senderAndTimeLabel;
@property (nonatomic) UIView *messageContentView;
@property (nonatomic) UIImageView *bgImageView;
@property (nonatomic) UIButton *avatarImageView;
@property (nonatomic) UIView *customView;

@end
