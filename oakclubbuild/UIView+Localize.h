//
//  UIView+Localize.h
//  OakClub
//
//  Created by VanLuu on 10/23/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface UIView (Localize)

@property (nonatomic, copy) NSString* languageKey;

-(UIView*)localizeText;
-(void)localizeAllViews;

@end

@interface NSString (Localize)
-(NSString *)localize;
@end