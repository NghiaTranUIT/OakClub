//
//  SmileyChooseCell.m
//  OakClub
//
//  Created by Salm on 11/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SmileyChooseCell.h"

@implementation SmileyChooseCell
{
    id<EmoticonData> _emoticon;
}

@synthesize smileyButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        smileyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [smileyButton setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:smileyButton];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(id<EmoticonData>)emoticon
{
    return _emoticon;
}

-(void)setEmoticon:(id<EmoticonData>)emot
{
    if (!_emoticon || ![[_emoticon key] isEqualToString:[emot key]])
    {
        _emoticon= emot;
        [_emoticon getImageAsycn:^(UIImage *image, NSError *e) {
            [smileyButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
    }
}

@end
