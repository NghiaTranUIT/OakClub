//
//  UIAlert.m
//  OakClub
//
//  Created by To Huy on 12/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UIAlert.h"

@implementation UIAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setButton: (NSString*) text withFrame: (CGRect) frame
{
    UIButton *btn;
    btn.titleLabel.text = text;
    [btn setFrame:frame];
    [self addSubview:btn];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
