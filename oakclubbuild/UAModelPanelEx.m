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
        NSString *titleString = [@"We take your\nprivacy seriously" localize];
        NSString *content1String = [@"We check every user, Fake and suspicious\naccount get deleted" localize];
        NSString *content2String = [@"We will NEVER post anything to Facebook" localize];
        NSString *content3String = [@"Other users will NEVER know if you've liked them\nunless they like you back" localize];
        NSString *content4String = [@"Other users can't contact you unless you've already been matched" localize];
        NSString *content5String = [@"Your location will NEVER be shown to other users" localize];
        
                                
        
        UIImage *contentImg = [UIImage imageNamed:@"screen"];
        self.backgroundColor = [UIColor colorWithPatternImage:contentImg];
        self.contentColor = [UIColor clearColor];
        self.borderColor = [UIColor clearColor];
        self.closeButton.frame = CGRectMake(0, 0, self.closeButtonFrame.size.width, self.closeButtonFrame.size.height);
        
        UIButton *signInButton = [[UIButton alloc] init];
        [signInButton setBackgroundImage:[UIImage imageNamed:@"Login_btnFB_inactive.png"] forState:UIControlStateNormal];
        [signInButton setBackgroundImage:[UIImage imageNamed:@"Login_btnFB_active.png"] forState:UIControlStateHighlighted];
        [signInButton sizeToFit];
        if ([value_appLanguage_VI isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage]])
        {
             signInButton.frame = CGRectMake((self.frame.size.width - 254)/2, 60, 254, 40);
        }
        else
        {
            signInButton.frame = CGRectMake((self.frame.size.width - 254)/2, 35, 254, 40);
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setNumberOfLines: 2];
        [titleLabel setFrame: CGRectMake((self.frame.size.width - 254)/2, 70, 260, 100)];
        [titleLabel setText: titleString];
        [titleLabel setTextAlignment: NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont systemFontOfSize: 24]];
        
        UILabel *content1Label = [[UILabel alloc] init];
        [content1Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content1Label setNumberOfLines: 2];
        [content1Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 167, 260, 35)];
        [content1Label setText: content1String];
        [content1Label setFont: [UIFont systemFontOfSize: 11]];
        
        UILabel *content2Label = [[UILabel alloc] init];
        [content2Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content2Label setNumberOfLines: 2];
        [content2Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 196, 260, 35)];
        [content2Label setText: content2String];
        [content2Label setFont: [UIFont systemFontOfSize: 11]];
        
        UILabel *content3Label = [[UILabel alloc] init];
        [content3Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content3Label setNumberOfLines: 2];
        [content3Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 227, 260, 35)];
        [content3Label setText: content3String];
        [content3Label setFont: [UIFont systemFontOfSize: 11]];
        
        UILabel *content4Label = [[UILabel alloc] init];
        [content4Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content4Label setNumberOfLines: 2];
        [content4Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 262, 260, 30)];
        [content4Label setText: content4String];
        [content4Label setFont: [UIFont systemFontOfSize: 11]];
        
        UILabel *content5Label = [[UILabel alloc] init];
        [content5Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content5Label setNumberOfLines: 2];
        [content5Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 290, 260, 35)];
        [content5Label setText: content5String];
        [content5Label setFont: [UIFont systemFontOfSize: 11]];
       
        [signInButton addTarget:self action:@selector(loginTouched:) forControlEvents:UIControlEventTouchUpInside];
        [signInButton setTitle:@"Connect Privately" forState:UIControlStateNormal];
        [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [self addSubview: titleLabel];
        [self addSubview: content1Label];
        [self addSubview: content2Label];
        [self addSubview: content3Label];
        [self addSubview: content4Label];
        [self addSubview: content5Label];
        [self addSubview:signInButton];
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[@"Info_background" localize]]]];
        
        [self localizeAllViews];
        
        loginPage = login;
    }
    
    [self localizeAllViews];
    
    return self;
}

-(void)loginTouched:(id)sender
{
    [self hide];
    [self removeFromSuperview];
    
    [loginPage performLogin:sender];
}
@end
