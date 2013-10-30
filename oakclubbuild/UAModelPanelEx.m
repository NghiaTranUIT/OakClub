//
//  UAModelPanelEx.m
//  OakClub
//
//  Created by Salm on 10/20/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UAModelPanelEx.h"
#import "UIView+Localize.h"

@interface UAModelPanelEx()
{
    SCLoginViewController *loginPage;
}
@end

@implementation UAModelPanelEx

- (id) initWithFrame:(CGRect)frame andLoginPage:(SCLoginViewController *)login
{
    if (self = [super initWithFrame:frame])
    {   
        UIImage *contentImg = [UIImage imageNamed:@"screen"];
        self.backgroundColor = [UIColor colorWithPatternImage:contentImg];
        self.contentColor = [UIColor clearColor];
        self.borderColor = [UIColor clearColor];
        self.closeButton.frame = CGRectMake(0, 0, self.closeButtonFrame.size.width, self.closeButtonFrame.size.height);
        
        UIButton *signInButton = [[UIButton alloc] init];
        [signInButton setBackgroundImage:[UIImage imageNamed:@"btn-fb-inactive_intro.png"] forState:UIControlStateNormal];
        [signInButton sizeToFit];
        signInButton.frame = CGRectMake((self.frame.size.width - 305)/2, 100, 305, signInButton.frame.size.height);
        [signInButton addTarget:self action:@selector(loginTouched:) forControlEvents:UIControlEventTouchUpInside];
        [signInButton setTitle:@"SIGN IN WITH FACEBOOK" forState:UIControlStateNormal];
        [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [self addSubview:signInButton];
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Info_background.png"]]];
        
        [self localizeAllViews];
        
        loginPage = login;
    }
    
    return self;
}

-(void)loginTouched:(id)sender
{
    [self hide];
    [self removeFromSuperview];
    
    [loginPage performLogin:sender];
}
@end
