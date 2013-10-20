//
//  UIGridViewView.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridViewMultipleSection.h"
#import "UIGridViewDelegateMultipleSection.h"
#import "UIGridViewCellMultipleSection.h"
#import "UIGridViewRowMultipleSection.h"

@implementation UIGridViewMultipleSection


@synthesize uiGridViewDelegate;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
	
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void) setUp
{
	self.delegate = self;
	self.dataSource = self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	self.delegate = nil;
	self.dataSource = nil;
}

- (UIGridViewCellMultipleSection *) dequeueReusableCell
{
	UIGridViewCellMultipleSection* temp = tempCell;
	tempCell = nil;
	return temp;
}


// UITableViewController specifics

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([uiGridViewDelegate respondsToSelector:@selector(gridView:titleForHeaderInSection:)]) {
        return [uiGridViewDelegate gridView:self titleForHeaderInSection:section];
    }
    return @"";

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if([uiGridViewDelegate respondsToSelector:@selector(gridView:viewForHeaderInSection:)]) {
        return [uiGridViewDelegate gridView:self viewForHeaderInSection:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return [uiGridViewDelegate heightForHeaderAtSection:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [uiGridViewDelegate numberOfSections];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int residue =  ([uiGridViewDelegate numberOfCellsOfGridView:self atSection:section] % [uiGridViewDelegate numberOfColumnsOfGridView:self]);
	
	if (residue > 0) residue = 1;
	
	return ([uiGridViewDelegate numberOfCellsOfGridView:self atSection:section] / [uiGridViewDelegate numberOfColumnsOfGridView:self]) + residue;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [uiGridViewDelegate gridView:self heightForRowAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UIGridViewRow";
	
    UIGridViewRowMultipleSection *row = (UIGridViewRowMultipleSection *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil) {
        row = [[UIGridViewRowMultipleSection alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	int numCols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
	int count = [uiGridViewDelegate numberOfCellsOfGridView:self atSection:indexPath.section];
	
	CGFloat x = 0.0;
	CGFloat height = [uiGridViewDelegate gridView:self heightForRowAtIndexPath:indexPath];
	
	for (int i=0;i<numCols;i++) {
		
		if ((i + indexPath.row * numCols) >= count) {
			
			if ([row.contentView.subviews count] > i) {
				((UIGridViewCellMultipleSection *)[row.contentView.subviews objectAtIndex:i]).hidden = YES;
			}
			
			continue;
		}
		
		if ([row.contentView.subviews count] > i) {
			tempCell = [row.contentView.subviews objectAtIndex:i];
		} else {
			tempCell = nil;
		}
		
		UIGridViewCellMultipleSection *cell = [uiGridViewDelegate gridView:self 
												cellForRowAt:indexPath.row
												 AndColumnAt:i
                                                  inSection:indexPath.section];
		
		if (cell.superview != row.contentView) {
			[cell removeFromSuperview];
			[row.contentView addSubview:cell];
			
			[cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		cell.hidden = NO;
		cell.rowIndex = indexPath.row;
		cell.colIndex = i;
        cell.sectionIndex = indexPath.section;
		
		CGFloat thisWidth = [uiGridViewDelegate gridView:self widthForColumnAtIndexPath:indexPath];
		cell.frame = CGRectMake(x, 0, thisWidth, height);
		x += thisWidth;
	}
	
	row.frame = CGRectMake(row.frame.origin.x,
							row.frame.origin.y,
							x,
							height);
	
    return row;
}


- (IBAction) cellPressed:(id) sender
{
	UIGridViewCellMultipleSection *cell = (UIGridViewCellMultipleSection *) sender;
    if([uiGridViewDelegate respondsToSelector:@selector(gridView:didSelectRowAt:AndColumnAt:atSectionIndex:selectedCell:)])
        [uiGridViewDelegate gridView:self didSelectRowAt:cell.rowIndex AndColumnAt:cell.colIndex atSectionIndex:cell.sectionIndex selectedCell:cell];
}


@end
