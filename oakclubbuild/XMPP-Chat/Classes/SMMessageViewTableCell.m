//
//  SMMessageViewTableCell.m
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "SMMessageViewTableCell.h"
#import "Define.h"

@implementation SMMessageViewTableCell

@synthesize senderAndTimeLabel, messageContentView, bgImageView,avatarImageView, customView;

#define paddingLeft 10
#define paddingTop 5
#define defaultWidth 300
#define defailtHeight 20

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.customView = [[UIView alloc] init];
        
		senderAndTimeLabel = [[UILabel alloc] init];
        senderAndTimeLabel.backgroundColor = [UIColor clearColor];
		senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
		senderAndTimeLabel.font = FONT_HELVETICANEUE_LIGHT(12);//[UIFont systemFontOfSize:12.0];
		senderAndTimeLabel.textColor = [UIColor lightGrayColor];
		[self.customView addSubview:senderAndTimeLabel];
		
		bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.customView addSubview:bgImageView];
        
		avatarImageView =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = 20;
        avatarImageView.layer.borderWidth = 1.0;
        avatarImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

        [self.customView addSubview:avatarImageView];
        
		messageContentView = [[UIView alloc] init];
		messageContentView.backgroundColor = [UIColor clearColor];
//		messageContentView.editable = NO;
//		messageContentView.scrollEnabled = NO;
		[messageContentView sizeToFit];
		[self.bgImageView addSubview:messageContentView];
        self.userInteractionEnabled = YES;
        
        self.customView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.customView];
    }
	
    return self;
	
}




@end
