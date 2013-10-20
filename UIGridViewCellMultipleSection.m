//
//  UIGridViewCell.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridViewCellMultipleSection.h"


@implementation UIGridViewCellMultipleSection

@synthesize rowIndex;
@synthesize colIndex;
@synthesize sectionIndex;
@synthesize view;
//@synthesize button;

/*
- (id) init {
    self = [super init];
    if(self) {
        self.button = [[UIButton alloc] init];
//        self.button.backgroundColor = [UIColor redColor];
//        [self addSubview:button];
    }
    return self;
}
*/
- (void) addSubview:(UIView *)v
{
//    if(v != self.button) {
        [super addSubview:v];
        v.exclusiveTouch = NO;
        v.userInteractionEnabled = NO;
//        [self.button removeFromSuperview];
//        [super addSubview:self.button];
//    }
//    else {
//        [super addSubview:v];
//    }
}


@end
