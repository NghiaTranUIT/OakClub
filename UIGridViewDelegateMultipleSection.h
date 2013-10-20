//
//  UIGridViewDelegate.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewMultipleSection.h"
#import "UIGridViewCellMultipleSection.h"

@protocol UIGridViewDelegateMultipleSection<NSObject>


@optional
- (void) gridView:(UIGridViewMultipleSection *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex atSectionIndex:(int)section selectedCell:(UIGridViewCellMultipleSection *)cell;
- (NSString *)gridView:(UIGridViewMultipleSection *)grid titleForHeaderInSection:(NSInteger)section;
- (UIView *)gridView:(UIGridViewMultipleSection *)grid viewForHeaderInSection:(NSInteger)section;

@required


- (NSInteger) numberOfSections;
- (CGFloat) heightForHeaderAtSection:(NSInteger)section;

- (CGFloat) gridView:(UIGridViewMultipleSection *)grid widthForColumnAtIndexPath:(NSIndexPath*)columnIndex;
- (CGFloat) gridView:(UIGridViewMultipleSection *)grid heightForRowAtIndexPath:(NSIndexPath*)rowIndex;

- (NSInteger) numberOfColumnsOfGridView:(UIGridViewMultipleSection *) grid;
- (NSInteger) numberOfCellsOfGridView:(UIGridViewMultipleSection *) grid atSection:(NSInteger)section;

- (UIGridViewCellMultipleSection *) gridView:(UIGridViewMultipleSection *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex inSection:(NSInteger)section;

@end

