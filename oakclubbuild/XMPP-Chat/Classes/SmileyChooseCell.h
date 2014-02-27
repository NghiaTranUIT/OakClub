//
//  SmileyChooseCell.h
//  OakClub
//
//  Created by Salm on 11/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "ChatEmoticon.h"

@interface SmileyChooseCell : PSUICollectionViewCell
@property id<EmoticonData> emoticon;
@property UIButton *smileyButton;
@end