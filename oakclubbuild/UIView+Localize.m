//
//  UIView+Localize.m
//  OakClub
//
//  Created by VanLuu on 10/23/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UIView+Localize.h"
#import <objc/runtime.h>

NSString * const kLanguageKey = @"kLanguageKey";

@implementation UIView (Localize)

#pragma mark Localize String

- (void)setLanguageKey:(NSString *)languageKey
{
	objc_setAssociatedObject(self, (__bridge const void *)(kLanguageKey), languageKey, OBJC_ASSOCIATION_COPY);
}

- (NSString*)languageKey
{
	 NSString* result = objc_getAssociatedObject(self, (__bridge const void *)(kLanguageKey));
    if (result == nil || result.length <= 0) {
        if([self isKindOfClass:[UILabel class]]){
            UILabel* view = (UILabel*)self;
            result = view.text;
            self.languageKey = result;
        }
        else if([self isKindOfClass:[UIButton class]]){
            UIButton* view = (UIButton*)self;
            result = [view titleForState:UIControlStateNormal];
            self.languageKey = result;
        }
    }
    
    return result;
}

-(UIView*)localizeText{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;

    if([self isKindOfClass:[UILabel class]]){
        UILabel* result = (UILabel*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.languageKey value:result.text table:nil];
        //NSLog(@"%@-text:-%@", result,text);
        [result setText:text];
        return result;
    }
    else if([self isKindOfClass:[UIButton class]]){
        UIButton* result = (UIButton*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.languageKey value:result.titleLabel.text table:nil];
        
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

@implementation UILabel (Localize)

@end

@implementation NSString (Localize)

-(NSString *)localize
{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    return [appDelegate.languageBundle localizedStringForKey:self value:@"" table:nil];
}

@end