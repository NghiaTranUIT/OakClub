//
//  UIGridView.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIGridViewDelegateMultipleSection;
@class UIGridViewCellMultipleSection;

@interface UIGridViewMultipleSection : UITableView<UITableViewDelegate, UITableViewDataSource> {
	UIGridViewCellMultipleSection *tempCell;
}

@property (nonatomic, strong) IBOutlet id<UIGridViewDelegateMultipleSection> uiGridViewDelegate;

- (void) setUp;
- (UIGridViewCellMultipleSection *) dequeueReusableCell;

- (IBAction) cellPressed:(id) sender;

@end
