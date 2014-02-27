//
//  StickerChooseTabs.m
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import "StickerChooseTabs.h"
#import "ChatEmoticon.h"

@implementation StickerChooseTabs
{
    int _selectedIndex;
}

@synthesize tabsView, stickersView, tabButtons, stickerContentViews, delegate;

- (id)initWithFrame:(CGRect)frame tabsFrameHeight:(float)tabFrameHeight
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)reloadData
{
    if (delegate && [delegate respondsToSelector:@selector(stickerChooseTabsHeightOfTabsView:)]
        && [delegate respondsToSelector:@selector(stickerChooseTabsNumberOfTab:)])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        float tabViewHeight = [delegate stickerChooseTabsHeightOfTabsView:self];
        CGRect tabFrame = CGRectMake(0, self.frame.size.height - tabViewHeight, self.frame.size.width, tabViewHeight);
        CGRect stickerFrame = CGRectMake(0, 0,  self.frame.size.width, self.frame.size.height - tabViewHeight);
        
        int nTabs = [delegate stickerChooseTabsNumberOfTab:self];
        
        [self reloadTabsButtonWithFrame:tabFrame andNumberOfTab:nTabs];
        [self reloadStickersViewWithFrame:stickerFrame andNumberOfTab:nTabs];
        
        [self updateUI];
    }
}

#define TAB_BUTTON_PADDING 2
-(void)reloadTabsButtonWithFrame:(CGRect)tabFrame andNumberOfTab:(int)nTabs
{
    self.tabsView = [[UIScrollView alloc] initWithFrame:tabFrame];
    [self addSubview:self.tabsView];
    
    NSMutableArray *_tabButtons = [[NSMutableArray alloc] init];
    
    float padSize = (nTabs - 1) * TAB_BUTTON_PADDING;
    float availWidth = tabFrame.size.width - padSize;
    float btnWidth = availWidth / nTabs;
    CGRect stButtonFrame = CGRectMake(0, 0, btnWidth, tabFrame.size.height);
    
    for (int i = 0; i < nTabs; ++i)
    {
        UIButton *stickerButton = [[UIButton alloc] initWithFrame:stButtonFrame];
        //init button
        stickerButton.tag = i;
        [stickerButton addTarget:self action:@selector(onTabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        if (delegate && [delegate respondsToSelector:@selector(stickerChooseTabs:customizeTabButton:atIndex:)])
        {
            [delegate stickerChooseTabs:self customizeTabButton:stickerButton atIndex:i];
        }
        
        [_tabButtons addObject:stickerButton];
        [self.tabsView addSubview:stickerButton];
        stButtonFrame.origin.x += stickerButton.frame.size.width + padSize;
    }
    
    UIButton *lastTabButton = [self.tabButtons lastObject];
    float contentWidth = lastTabButton.frame.origin.x + lastTabButton.frame.size.width;
    [self.tabsView setContentSize:CGSizeMake(contentWidth, tabFrame.size.height)];
    
    self.tabButtons = _tabButtons;
}

-(void)reloadStickersViewWithFrame:(CGRect)stickerFrame andNumberOfTab:(int)nTabs
{
    self.stickersView = [[UIView alloc] initWithFrame:stickerFrame];
    [self addSubview:self.stickersView];
    
    NSMutableArray *_stickerContentViews = [[NSMutableArray alloc] init];
    
    CGRect contentFrame = CGRectMake(0, 0, stickerFrame.size.width, stickerFrame.size.height);
    for (int i = 0; i < nTabs; ++i)
    {
        UIView *stickerContentView = [[UIView alloc] initWithFrame:contentFrame];
        //init contentView
        stickerContentView.tag = i;
        
        if (delegate && [delegate respondsToSelector:@selector(stickerChooseTabs:customizeStickerView:atIndex:)])
        {
            [delegate stickerChooseTabs:self customizeStickerView:stickerContentView atIndex:i];
        }
        
        [_stickerContentViews addObject:stickerContentView];
        [self.stickersView addSubview:stickerContentView];
    }
    
    self.stickerContentViews = _stickerContentViews;
}

-(int)selectedIndex
{
    return _selectedIndex;
}

-(void)setSelectedIndex:(int)selectedIndex
{
    if (selectedIndex != _selectedIndex)
    {
        int oldIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        [self updateUI];
        
        if (delegate && [delegate respondsToSelector:@selector(stickerChooseTabs:selectedTab:isChangedTo:)])
        {
            [delegate stickerChooseTabs:self selectedTab:oldIndex isChangedTo:selectedIndex];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)onTabButtonTouched:(id)button
{
    self.selectedIndex = [button tag];
}

-(void)updateUI
{
    for (UIButton *tabButton in self.tabButtons)
    {
        if (tabButton.tag != _selectedIndex)
        {
            [tabButton setHighlighted:NO];
        }
        else
        {
            [tabButton setHighlighted:YES];
        }
    }
    
    
    for (UIView *contentView in self.stickerContentViews)
    {
        if (contentView.tag != _selectedIndex)
        {
            [contentView setHidden:YES];
        }
        else
        {
            [contentView setHidden:NO];
        }
    }
}
@end
