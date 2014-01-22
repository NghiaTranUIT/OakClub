//
//  VCPrivacy.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCPrivacy.h"
#import "UIView+Localize.h"
#import "Define.h"

@interface VCPrivacy() <UIWebViewDelegate>
{
    SCLoginViewController *loginPage;
}

@end

@implementation VCPrivacy
{
    float privacyHeight;
    IBOutlet UITextView *engView;
    IBOutlet UITextView *vietView;
}

- (id)initWithFrame:(CGRect)frame andLoginPage:(SCLoginViewController *)login
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.margin = UIEdgeInsetsMake(self.frame.size.width / 5, 10, self.frame.size.width / 5, 10);
        
        if (!engView || !vietView)
        {
            [[NSBundle mainBundle] loadNibNamed:@"PrivacyView" owner:self options:nil];
        }
        if ([value_appLanguage_VI isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage]])
        {
            [self initPrivacyText:vietView];
        }
        else
        {
            [self initPrivacyText:engView];
        }
        
        [[NSBundle mainBundle] loadNibNamed:@"PrivacyView" owner:self options:nil];
        
        UIButton *proceedBtn = [[UIButton alloc] init];
        [proceedBtn setBackgroundImage:[UIImage imageNamed:@"proceed-btn-on.png"] forState:UIControlStateNormal];
        proceedBtn.frame = CGRectMake(0, IS_HEIGHT_GTE_568?328:250 , self.contentViewFrame.size.width, self.margin.bottom);
        [proceedBtn addTarget:self action:@selector(proceedTouched:) forControlEvents:UIControlEventTouchUpInside];
        [proceedBtn setTitle:@"AGREE & PROCEED" forState:UIControlStateNormal];
        [proceedBtn.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15)];//[UIFont systemFontOfSize:15]];
        
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

-(void)initPrivacyText:(UITextView *)txtView
{
    txtView.frame = CGRectMake(self.margin.left + self.borderWidth + 15,
                               self.margin.top + self.borderWidth + 15,
                               txtView.frame.size.width,IS_HEIGHT_GTE_568?txtView.frame.size.height+88:txtView.frame.size.height);
    [self addSubview:txtView];
}
@end
