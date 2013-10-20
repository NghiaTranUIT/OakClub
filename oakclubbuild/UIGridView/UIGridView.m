//
//  UIGridViewView.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "UIGridViewCell.h"
#import "UIGridViewRow.h"

@implementation UIGridView


@synthesize uiGridViewDelegate, arrayProfile, headerName;


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

- (UIGridViewCell *) dequeueReusableCell
{
	UIGridViewCell* temp = tempCell;
	tempCell = nil;
	return temp;
}

// UITableViewController specifics
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return headerName;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bar.png"]]];
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 310, 30)];
    [name setText:self.headerName];
    [name setTextColor:[UIColor whiteColor]];
    [name setBackgroundColor:[UIColor clearColor]];
    [name setFont:FONT_NOKIA(20.0)];
    [headerView addSubview:name];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int residue =  ([uiGridViewDelegate numberOfCellsOfGridView:self] % [uiGridViewDelegate numberOfColumnsOfGridView:self]);
	
	if (residue > 0) residue = 1;
	
	return ([uiGridViewDelegate numberOfCellsOfGridView:self] / [uiGridViewDelegate numberOfColumnsOfGridView:self]) + residue;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UIGridViewRow";
	
    UIGridViewRow *row = (UIGridViewRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil) {
        row = [[UIGridViewRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	int numCols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
	int count = [uiGridViewDelegate numberOfCellsOfGridView:self];
	
	CGFloat x;
    CGFloat y;
    if(indexPath.row/numCols == 0)
        y = NearByPaddingTop;
    else
        y = NearByMargin;
    if(indexPath.row/numCols == indexPath.section)
        x = NearByPaddingLeft;
    else
        x = NearByMargin;
	CGFloat height = [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
	
	for (int i=0;i<numCols;i++) {
		
		if ((i + indexPath.row * numCols) >= count) {
			
			if ([row.contentView.subviews count] > i) {
				((UIGridViewCell *)[row.contentView.subviews objectAtIndex:i]).hidden = YES;
			}
			
			continue;
		}
		Profile *_profile = [[Profile alloc]init];
        _profile = [arrayProfile objectAtIndex:(indexPath.row*numCols)+i];
		if ([row.contentView.subviews count] > i) {
			tempCell = [row.contentView.subviews objectAtIndex:i];
		} else {
			tempCell = nil;
		}
		
		UIGridViewCell *cell = [uiGridViewDelegate gridView:self 
												cellForRowAt:indexPath.row 
												 AndColumnAt:i AndProfile:_profile];
		
		if (cell.superview != row.contentView) {
			[cell removeFromSuperview];
			[row.contentView addSubview:cell];
			
			[cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		cell.hidden = NO;
		cell.rowIndex = indexPath.row;
		cell.colIndex = i;
		
		CGFloat thisWidth = [uiGridViewDelegate gridView:self widthForColumnAt:i];
		cell.frame = CGRectMake(x, y, thisWidth, height);
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
	UIGridViewCell *cell = (UIGridViewCell *) sender;
	[uiGridViewDelegate gridView:self didSelectRowAt:cell.rowIndex AndColumnAt:cell.colIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [uiGridViewDelegate scrollViewDidScroll:scrollView];
}
@end
