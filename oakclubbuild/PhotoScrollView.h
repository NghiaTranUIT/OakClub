//
//  PhotoScrollView.h
//  OakClub
//
//  Created by Salm on 11/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoScrollViewDelegate <NSObject>
-(void)photoButton:(UIButton *)button touchedAtIndex:(int)index;

-(UIImage*)photoAtIndex:(int)index;
-(int)numberOfPhoto;
-(UIImage*)borderAtIndex:(int)index;

-(CGSize)elementSize;
-(CGSize)elementPadding;
@end

@interface PhotoScrollView : UIScrollView
-(id)initWithFrame:(CGRect)frame;
-(void)reloadScrollView;

@property id<PhotoScrollViewDelegate> photoDelegate;
@end
