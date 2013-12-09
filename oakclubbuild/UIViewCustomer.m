//
//  UIViewCustomer.m
//  OakClub
//
//  Created by To Huy on 12/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UIViewCustomer.h"

@implementation UIViewCustomer

#pragma mark Localize String
-(UIView*)localizeText{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    if([self isKindOfClass:[UILabel class]]){
        UILabel* result = (UILabel*)self;
        if ([result.text rangeOfString: @"Dragging a picture"].length != 0)
        {
            NSString* text =[appDelegate.languageBundle localizedStringForKey:result.text value:@"" table:nil];
            [result setText:text];
        }
        else
        {
            NSArray *arr = [result.text componentsSeparatedByString: @" "];
            NSString *str = @"";
            for (int i = 0; i < arr.count - 1; i++)
            {
                [str stringByAppendingString: [NSString stringWithFormat: @"%@ ", arr[i]]];
            }
            NSString *text = [appDelegate.languageBundle localizedStringForKey:str value:@"" table:nil];
            [result setText:[NSString stringWithFormat: @"%@ %@.", text, arr[arr.count - 1]]];
        }
        return result;
    }
    else if([self isKindOfClass:[UIButton class]]){
        UIButton* result = (UIButton*)self;
        NSString* text =[appDelegate.languageBundle localizedStringForKey:result.titleLabel.text value:@"" table:nil];
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
    for(UIViewCustomer* view in [self subviews])
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

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super l];
//    if (self)
//    {
//
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
