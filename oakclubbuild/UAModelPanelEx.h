//
//  UAModelPanelEx.h
//  OakClub
//
//  Created by Salm on 10/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAModalPanel.h"
#import "SCLoginViewController.h"

@interface UAModelPanelEx : UAModalPanel
- (id) initWithFrame:(CGRect)frame andLoginPage:(SCLoginViewController *)login;
@end