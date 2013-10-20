//
//  UAModelPanelEx.m
//  OakClub
//
//  Created by Salm on 10/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UAModelPanelEx.h"

@implementation UAModelPanelEx

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {   
        UIImage *contentImg = [UIImage imageNamed:@"screen"];
        self.backgroundColor = [UIColor colorWithPatternImage:contentImg];
        self.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    }
    
    return self;
}

@end
