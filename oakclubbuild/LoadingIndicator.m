//
//  LoadingIndicator.m
//  OakClub
//
//  Created by Salm on 11/19/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "LoadingIndicator.h"

@implementation LoadingIndicator
{
    UIActivityIndicatorView *indicator;
    id<LoadingIndicatorDelegate> delegate;
    UIView *mainView;
}

-(id)initWithMainView:(UIView *)_mainView andDelegate:(id<LoadingIndicatorDelegate>)_delegate
{
    if (self = [super init])
    {
        mainView = _mainView;
        delegate = _delegate;
        
        [self initIndicator];
    }
    
    return self;
}

-(void)initIndicator
{
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor colorWithRed:(121.f / 255.f) green:(1.f / 255.f) blue:(88.f / 255.f) alpha:1];
    [self centerIndicator];
    [indicator setHidesWhenStopped:YES];
    [indicator stopAnimating];
}


-(void)centerIndicator
{
    [indicator setFrame:CGRectMake((mainView.frame.size.width - indicator.frame.size.width) / 2,
                                        (mainView.frame.size.height - indicator.frame.size.height) / 2,
                                        indicator.frame.size.width,
                                        indicator.frame.size.height)];
}

-(void)lockViewAndDisplayIndicator
{
    if (![indicator isAnimating])
    {
        if (delegate && [delegate respondsToSelector:@selector(customizeIndicator:)])
        {
            [delegate customizeIndicator:indicator];
        }
        
        [mainView setUserInteractionEnabled:NO];
        if (delegate && [delegate respondsToSelector:@selector(lockView)])
        {
            [delegate lockView];
        }
        
        [mainView addSubview:indicator];
        [mainView bringSubviewToFront:indicator];
        [indicator startAnimating];
    }
}
-(void)unlockViewAndStopIndicator
{
    if ([indicator isAnimating])
    {
        [mainView setUserInteractionEnabled:YES];
        if (delegate && [delegate respondsToSelector:@selector(unlockView)])
        {
            [delegate unlockView];
        }
        
        [indicator removeFromSuperview];
        [indicator stopAnimating];
    }
}
@end
