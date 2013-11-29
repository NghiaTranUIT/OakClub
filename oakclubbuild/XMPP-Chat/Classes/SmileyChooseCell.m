//
//  SmileyChooseCell.m
//  OakClub
//
//  Created by Salm on 11/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SmileyChooseCell.h"
#import "ChatEmoticon.h"

@implementation SmileyChooseCell
{
    ChatEmoticon *emots;
    NSString *smiley;
}

@synthesize smileyButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        emots = [ChatEmoticon instance];
        smileyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                       frame.size.width,
                                                                       frame.size.height)];
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

-(NSString *)smileyText
{
    return smiley;
}

-(void)setSmileyText:(NSString *)smileyText
{
    if (![smiley isEqualToString:smileyText])
    {
        smiley = smileyText;
        [smileyButton setBackgroundImage:[emots valueForKey:smileyText] forState:UIControlStateNormal];
    }
}

@end
