//
//  VCPrivacy.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCPrivacy.h"

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
        txtView.text = @"asdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasdaasdasdasdasda";
        [[self contentView] addSubview:txtView];
        
        UIButton *proceedBtn = [[UIButton alloc] init];
        [proceedBtn setBackgroundImage:[UIImage imageNamed:@"proceed-btn-on.png"] forState:UIControlStateNormal];
        proceedBtn.frame = CGRectMake(0, txtView.frame.origin.y + txtView.frame.size.height + 10, self.contentViewFrame.size.width, self.margin.bottom);
        [proceedBtn addTarget:self action:@selector(proceedTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:proceedBtn];
        
        loginPage = login;
    }
    return self;
}

-(void)proceedTouched:(id)sender
{
    [self hide];
    [self removeFromSuperview];
    
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
