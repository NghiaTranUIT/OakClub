//
//  PhotoScrollView.m
//  OakClub
//
//  Created by Salm on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PhotoScrollView.h"
#import "UIView+Localize.h"
@interface PhotoScrollView()
{
    bool isReloading;
}
@end

@implementation PhotoScrollView
@synthesize photoDelegate;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isReloading = false;
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
    if (isReloading)
    {
        return;
    }
    
    isReloading = true;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentSize = CGSizeMake(self.photoDelegate.elementPadding.width, self.photoDelegate.elementSize.height);
    
    for (int i = 0; i < [self.photoDelegate numberOfPhoto]; ++i)
    {
        UIImageView *photoButton = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentSize.width, self.photoDelegate.elementPadding.height, self.photoDelegate.elementSize.width, self.photoDelegate.elementSize.height)];
        [photoButton setImage:[self.photoDelegate photoAtIndex:i]];
        [photoButton setContentMode:UIViewContentModeScaleAspectFit];
        photoButton.tag = i;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTouched:)];
        [photoButton addGestureRecognizer:tapGesture];
        [photoButton setUserInteractionEnabled:YES];
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
        
        if (i == [self.photoDelegate numberOfPhoto] - 1)
        {
            UILabel *label = [[UILabel alloc] init];
            label.languageKey = @"Add photo";
            label.text = @"Add photo";
            [label localizeText];
            [label setFont: FONT_HELVETICANEUE_LIGHT(18)];
            [label setBackgroundColor: [UIColor clearColor]];
            [label setTextColor: COLOR_PURPLE /*[UIColor colorWithRed:116/255.0 green:1/255.0 blue:5/255.0 alpha:1.0]*/];
            [label setFrame: CGRectMake(photoButton.frame.origin.x + 10, photoButton.frame.origin.y + 10, photoButton.frame.size.width - 17, photoButton.frame.size.height)];
            [label setAdjustsFontSizeToFitWidth:YES];
//            [label setMinimumFontSize:5];
            [self addSubview: label];
        }
        
        self.contentSize = CGSizeMake(self.contentSize.width + self.photoDelegate.elementSize.width + self.photoDelegate.elementPadding.width/2, self.contentSize.height);
    }
    isReloading = false;
}

-(void)updatePhotoAtIndex:(int)index
{
    UIImageView *photoView = (UIImageView *) [self viewWithTag:index];
    if (photoView)
    {
        [photoView setImage:[self.photoDelegate photoAtIndex:index]];
    }
}

-(void)photoTouched:(id)photoButton
{
    if (self.photoDelegate)
    {
        [self.photoDelegate photoButton:photoButton touchedAtIndex:[[photoButton view] tag]];
    }
}
@end
