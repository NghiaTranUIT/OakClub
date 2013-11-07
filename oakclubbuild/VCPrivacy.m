//
//  VCPrivacy.m
//  OakClub
//
//  Created by Salm on 10/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCPrivacy.h"
#import "UIView+Localize.h"

@interface VCPrivacy() <UIWebViewDelegate>
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
        
        UIWebView *txtView = [[UIWebView alloc] init];
        txtView.frame = CGRectMake(0, 0, self.contentViewFrame.size.width, self.contentViewFrame.size.height - self.margin.bottom);
        txtView.delegate = self;
        [self initText:txtView];
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

-(void)initText:(UIWebView *)txtView
{
    NSURL *documentURL = [[NSBundle mainBundle] URLForResource:@"Privacy_Eng" withExtension:@".rtf"];
    NSURLRequest *docRequest = [NSURLRequest requestWithURL:documentURL];
    [txtView loadRequest:docRequest];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* js =
    @"var meta = document.createElement('meta'); " \
    "meta.setAttribute( 'name', 'viewport' ); " \
    "meta.setAttribute( 'content', 'width = 260, initial-scale = 0.3, user-scalable = yes' ); " \
    "document.getElementsByTagName('head')[0].appendChild(meta)";
    
    [webView stringByEvaluatingJavaScriptFromString: js];
}

@end
