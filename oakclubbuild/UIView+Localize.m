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
        //NSLog(@"%@-text:-%@", result,text);
        [result setText:text];
        return result;
    }
    else if([self isKindOfClass:[UIButton class]]){
        UIButton* result = (UIButton*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.titleLabel.text value:@"" table:nil];
        
        //NSLog(@"%@-text:-%@", result,text);
        [result setTitle:text forState:UIControlStateNormal];
        return result;
    }
    else
    {
        id id_self = self;
        if([id_self respondsToSelector:@selector(text)] && [id_self respondsToSelector:@selector(setText:)])
        {
            NSString *localText = [[id_self text] localize];
            if (localText && ![@"" isEqualToString:localText])
            {
                [id_self setText:localText];
            }
        }
    }
    
    return self;
    //    return rerult;
}

-(void)localizeAllViews{
    [self localizeText];
    
    if([self isKindOfClass:[UIButton class]])
        return;
    
    for(UIView* view in [self subviews])
    {
        [view localizeAllViews];
    }
}
@end

@implementation NSString (Localize)

-(NSString *)localize
{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    return [appDelegate.languageBundle localizedStringForKey:self value:@"" table:nil];
}

@end