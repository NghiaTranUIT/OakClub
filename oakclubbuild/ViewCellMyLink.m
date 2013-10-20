//
//  ViewCellMyLink.m
//  oakclubbuild
//
//  Created by hoangle on 4/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ViewCellMyLink.h"

@implementation ViewCellMyLink
@synthesize imageView, checkedView;
@synthesize isPlus, isMinus;
@synthesize profile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) init {
    self = [super init];
    if(self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ViewCellMyLink" owner:self options:nil];
        UIView *view = [array objectAtIndex:0];
        [self addSubview:view];
//        UIImageView *imV = [view.subviews objectAtIndex:<#(NSUInteger)#>];
//        self.imageView = imV;
        [self.checkedView setImage:[UIImage  imageNamed:@"cell_selected.png"]];
        self.isMinus = self.isPlus = NO;
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

@end
