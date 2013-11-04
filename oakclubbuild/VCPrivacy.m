//
//  VCPrivacy.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCPrivacy.h"
#import "UIView+Localize.h"

@interface VCPrivacy()
{
    SCLoginViewController *loginPage;
}
@end

@implementation VCPrivacy

- (id)initWithFrame:(CGRect)frame andLoginPage:(SCLoginViewController *)login
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self.contentView.frame = CGRectMake(self.frame.size.width - 10, self.frame.size.height / 4, self.frame.size.width - 20, self.frame.size.height / 2);
        self.margin = UIEdgeInsetsMake(self.frame.size.width / 5, 10, self.frame.size.width / 5, 10);
        
        UITextView *txtView = [[UITextView alloc] init];
        txtView.frame = CGRectMake(0, 0, self.contentViewFrame.size.width, self.contentViewFrame.size.height - self.margin.bottom);
        txtView.text = @"This Privacy Policy describes how and when Twitter collects, uses and shares your information when you use our Services. Twitter receives your information through our various websites, SMS, APIs, email notifications, applications, buttons, widgets, and ads (the \"Services\" or \"Twitter\") and from our partners and other third parties. For example, you send us information when you use Twitter from our website, post or receive Tweets via SMS, or access Twitter from an application such as Twitter for Mac, Twitter for Android or TweetDeck. When using any of our Services you consent to the collection, transfer, manipulation, storage, disclosure and other uses of your information as described in this Privacy Policy. Irrespective of which country you reside in or supply information from, you authorize Twitter to use your information in the United States and any other country where Twitter operates.";
        [[self contentView] addSubview:txtView];
        
        UIButton *proceedBtn = [[UIButton alloc] init];
        [proceedBtn setBackgroundImage:[UIImage imageNamed:@"proceed-btn-on.png"] forState:UIControlStateNormal];
        proceedBtn.frame = CGRectMake(0, txtView.frame.origin.y + txtView.frame.size.height + 10, self.contentViewFrame.size.width, self.margin.bottom);
        [proceedBtn addTarget:self action:@selector(proceedTouched:) forControlEvents:UIControlEventTouchUpInside];
        [proceedBtn setTitle:@"PROCEED" forState:UIControlStateNormal];
        [proceedBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [self.contentView addSubview:proceedBtn];
        
        loginPage = login;
    }
    
    [self localizeAllViews];
    
    return self;
}

-(void)proceedTouched:(id)sender
{
    [self hide];
    [self removeFromSuperview];
    
    [loginPage startSpinner];
    [loginPage tryLogin];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
