//
//  StickerChooseTabs.h
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StickerChooseTabs;

@protocol StickerChooseTabsDelegate <NSObject>

-(void)stickerChooseTabs:(StickerChooseTabs*)stChooseTabs customizeTabButton:(UIButton *)button atIndex:(int)index;
-(void)stickerChooseTabs:(StickerChooseTabs*)stChooseTabs customizeStickerView:(UIView *)contentView atIndex:(int)index;

-(float)stickerChooseTabsHeightOfTabsView:(StickerChooseTabs*)stChooseTabs;
-(int)stickerChooseTabsNumberOfTab:(StickerChooseTabs *)stChooseTabs;

-(void)stickerChooseTabs:(StickerChooseTabs*)stChooseTabs selectedTab:(int)oldIndex isChangedTo:(int)newIndex;
@end

@interface StickerChooseTabs : UIView
- (id)initWithFrame:(CGRect)frame tabsFrameHeight:(float)tabFrameHeight;

@property (strong, nonatomic) UIScrollView *tabsView;
@property (strong, nonatomic) UIView *stickersView;
@property (strong, nonatomic) NSArray *tabButtons;
@property (strong, nonatomic) NSArray *stickerContentViews;
@property (strong, nonatomic) id<StickerChooseTabsDelegate> delegate;

@property int selectedIndex;

-(void)reloadData;
@end
