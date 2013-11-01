//
//  PhotoScrollView.m
//  OakClub
//
//  Created by Salm on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PhotoScrollView.h"

@interface PhotoScrollView()
@end

@implementation PhotoScrollView
@synthesize photoDelegate;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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

-(void)reloadScrollView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentSize = CGSizeMake(0, self.photoDelegate.elementSize.height);
    
    for (int i = 0; i < [self.photoDelegate numberOfPhoto]; ++i)
    {
        UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentSize.width, self.photoDelegate.elementPadding.height, self.photoDelegate.elementSize.width, self.photoDelegate.elementSize.height)];
        [photoButton setBackgroundImage:[self.photoDelegate photoAtIndex:i] forState:UIControlStateNormal];
        photoButton.tag = i;
        [photoButton addTarget:self action:@selector(photoTouched:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *borderLayoutImg = [self.photoDelegate borderAtIndex:i];
        [self addSubview:photoButton];
        
        if (borderLayoutImg)
        {
            UIImageView *photoImgView = [[UIImageView alloc] initWithImage:borderLayoutImg];
            photoImgView.frame = photoButton.frame;
            photoImgView.backgroundColor = [UIColor clearColor];
            photoButton.backgroundColor = [UIColor clearColor];
            [self addSubview:photoImgView];
        }
        
        self.contentSize = CGSizeMake(self.contentSize.width + self.photoDelegate.elementSize.width + self.photoDelegate.elementPadding.width, self.contentSize.height);
    }
}

-(void)photoTouched:(id)photoButton
{
    if (self.photoDelegate)
    {
        [self.photoDelegate photoButton:photoButton touchedAtIndex:[photoButton tag]];
    }
}
@end
