//
//  UIView+Localize.m
//  OakClub
//
//  Created by VanLuu on 10/23/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UIView+Localize.h"

@implementation UIView (Localize)
#pragma mark Localize String
-(UIView*)localizeText{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;

    if([self isKindOfClass:[UILabel class]]){
        UILabel* result = (UILabel*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.text value:@"" table:nil];
        [result setText:text];
        return result;
    }

    if([self isKindOfClass:[UIButton class]]){
        UIButton* result = (UIButton*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.titleLabel.text value:@"" table:nil];
        [result setTitle:text forState:UIControlStateNormal];
        return result;
    }
    return self;
    //    return rerult;
}

-(void)localizeAllViews{
    for(UIView* view in [self subviews]){
        [view localizeText];
    }
}
@end
