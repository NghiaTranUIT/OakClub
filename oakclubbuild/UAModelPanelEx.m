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
        NSString *titleString = [@"We take your privacy seriously" localize];
        NSString *content1String = [@"We check every user, Fake and suspicious account get deleted" localize];
        NSString *content2String = [@"We will NEVER post anything to Facebook" localize];
        NSString *content3String = [@"Other users will NEVER know if you've liked them unless they like you back" localize];
        NSString *content4String = [@"Other users can't contact you unless you've already been matched" localize];
        NSString *content5String = [@"Your location will NEVER be shown to other users" localize];
        
        NSArray *contents = @[content1String, content3String, content4String, content5String];
        
        UIImage *contentImg = [UIImage imageNamed:@"screen"];
        self.backgroundColor = [UIColor colorWithPatternImage:contentImg];
        self.contentColor = [UIColor clearColor];
        self.borderColor = [UIColor clearColor];
        self.closeButton.frame = CGRectMake(0, 0, self.closeButtonFrame.size.width, self.closeButtonFrame.size.height);
        
        UIButton *signInButton = [[UIButton alloc] init];
        [signInButton setBackgroundImage:[UIImage imageNamed:@"Login_btnFB_inactive.png"] forState:UIControlStateNormal];
        [signInButton setBackgroundImage:[UIImage imageNamed:@"Login_btnFB_active.png"] forState:UIControlStateHighlighted];
        [signInButton sizeToFit];
        
        signInButton.frame = CGRectMake((self.frame.size.width - 254)/2, 35, 254, 40);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setNumberOfLines: 2];
        [titleLabel setFrame: CGRectMake(0, 70,self.frame.size.width, 100)];
        [titleLabel setText: titleString];
        [titleLabel setTextAlignment: NSTextAlignmentCenter];
        [titleLabel setFont:FONT_HELVETICANEUE_LIGHT(30)];
        
        CGPoint startPoint = CGPointMake((self.frame.size.width - 210)/2, 167);
        for (int i = 0; i < contents.count; ++i) {
            startPoint = [self addContentLabel:contents[i] atPosition:startPoint];
        }
        
        [signInButton addTarget:self action:@selector(loginTouched:) forControlEvents:UIControlEventTouchUpInside];
        [signInButton setTitle:@"Connect Privately" forState:UIControlStateNormal];
        [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [self addSubview: titleLabel];
        [self addSubview:signInButton];
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[@"Info_background" localize]]]];
        
        loginPage = login;
    }
    
    [self localizeAllViews];
    
    return self;
}

-(CGPoint)addContentLabel:(NSString *)content atPosition:(CGPoint)pos
{
    static float deltaIconPosition = 2;
    float spacingParagraph = (IS_HEIGHT_GTE_568)?10:2;
    static float maxWidth = 250;
    
    UIImage *bulletImage = [UIImage imageNamed: @"bullet.png"];
    UIImageView *bulletImgView = [[UIImageView alloc] init];
    UILabel *contentLbl = [[UILabel alloc] init];
    [contentLbl setLineBreakMode:NSLineBreakByWordWrapping];
    [contentLbl setNumberOfLines:0];
    [contentLbl setText:content];
    [contentLbl setFont:FONT_HELVETICANEUE_LIGHT(11)];
    CGSize textSize = [content sizeWithFont:contentLbl.font
                                  constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    [contentLbl setFrame:CGRectMake(pos.x, pos.y, textSize.width , textSize.height)];
    [bulletImgView setImage:bulletImage];
    [bulletImgView setFrame:CGRectMake((self.frame.size.width - 240)/2, pos.y + deltaIconPosition, 11, 11)];
    
    pos.y += contentLbl.frame.size.height + spacingParagraph;
    
    [self addSubview:bulletImgView];
    [self addSubview:contentLbl];
    
    return pos;
}

-(void)loginTouched:(id)sender
{
    [self hide];
    [self removeFromSuperview];
    
    [loginPage performLogin:sender];
}
@end
