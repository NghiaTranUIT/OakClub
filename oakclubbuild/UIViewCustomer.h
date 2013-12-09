//
//  UIViewCustomer.h
//  OakClub
//
//  Created by To Huy on 12/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface UIViewCustomer : UIView
-(UIView*)localizeText;
-(void)localizeAllViews;
@end

@interface NSString (Localize)
-(NSString *)localize;
@end
