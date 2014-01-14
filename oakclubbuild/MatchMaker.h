//
//  MatchMaker.h
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@interface MatchMaker : UIViewController <UITextViewDelegate>
@property PSTCollectionView *CVFriendsList;

-(void)loadFriendsData;
@end