//
//  UIGridViewDelegate.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridView.h"
#import "Profile.h"
@protocol UIGridViewDelegate


@optional
- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@required
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex;
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex;

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid;
- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid;

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex AndProfile:(Profile *)_profile;

@end

