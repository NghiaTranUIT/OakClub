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
        NSString *content4String = [@"Other users can't contact you\nunless you've already been matched" localize];
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
        
        signInButton.frame = CGRectMake((self.frame.size.width - 254)/2, 35, 254, 40);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setNumberOfLines: 2];
        [titleLabel setFrame: CGRectMake(0, 70,self.frame.size.width, 100)];
        [titleLabel setText: titleString];
        [titleLabel setTextAlignment: NSTextAlignmentCenter];
        [titleLabel setFont:FONT_HELVETICANEUE_LIGHT(30)];
        
        UIImageView *image1 = [[UIImageView alloc] init];
        UILabel *content1Label = [[UILabel alloc] init];
        [content1Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content1Label setNumberOfLines: 2];
        [content1Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 167, 260, 35)];
        [content1Label setText: content1String];
        [content1Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        [image1 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image1 setFrame: CGRectMake((self.frame.size.width - 240)/2, 172, 11, 11)];
        
        UIImageView *image2 = [[UIImageView alloc] init];
        UILabel *content2Label = [[UILabel alloc] init];
        [content2Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content2Label setNumberOfLines: 2];
        [content2Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 199, 260, 35)];
        [content2Label setText: [NSString stringWithFormat:@"%@\n  ", content2String]];
        //[content2Label setBackgroundColor:[UIColor redColor]];
        [content2Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        [image2 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image2 setFrame: CGRectMake((self.frame.size.width - 240)/2, 204, 11, 11)];
        
        UIImageView *image3 = [[UIImageView alloc] init];
        UILabel *content3Label = [[UILabel alloc] init];
        [content3Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content3Label setNumberOfLines: 2];
        [content3Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 230, 260, 35)];
        [content3Label setText: content3String];
        [content3Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        [image3 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image3 setFrame: CGRectMake((self.frame.size.width - 240)/2, 235, 11, 11)];
        
        UIImageView *image4 = [[UIImageView alloc] init];
        UILabel *content4Label = [[UILabel alloc] init];
        [content4Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content4Label setNumberOfLines: 2];
        [content4Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 265, 260, 30)];
        [content4Label setText: content4String];
        [content4Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        [image4 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image4 setFrame: CGRectMake((self.frame.size.width - 240)/2, 267, 11, 11)];
        
        UIImageView *image5 = [[UIImageView alloc] init];
        UILabel *content5Label = [[UILabel alloc] init];
        [content5Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content5Label setNumberOfLines: 2];
        [content5Label setFrame: CGRectMake((self.frame.size.width - 210)/2, 293, 260, 35)];
        [content5Label setText: [NSString stringWithFormat: @"%@\n  ", content5String]];
        [content5Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        [image5 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image5 setFrame: CGRectMake((self.frame.size.width - 240)/2, 298, 11, 11)];
       
        [signInButton addTarget:self action:@selector(loginTouched:) forControlEvents:UIControlEventTouchUpInside];
        [signInButton setTitle:@"Connect Privately" forState:UIControlStateNormal];
        [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        if(IS_OS_7_OR_LATER)
        {
            [image1 setFrame: CGRectMake((self.frame.size.width - 240)/2, 175, 11, 11)];
            [image2 setFrame: CGRectMake((self.frame.size.width - 240)/2, 207, 11, 11)];
            [image3 setFrame: CGRectMake((self.frame.size.width - 240)/2, 238, 11, 11)];
            [image4 setFrame: CGRectMake((self.frame.size.width - 240)/2, 270, 11, 11)];
            [image5 setFrame: CGRectMake((self.frame.size.width - 240)/2, 301, 11, 11)];
        }
        
        [self addSubview: titleLabel];
        [self addSubview: content1Label];
        [self addSubview: content2Label];
        [self addSubview: content3Label];
        [self addSubview: content4Label];
        [self addSubview: content5Label];
        [self addSubview: image1];
        [self addSubview: image2];
        [self addSubview: image3];
        [self addSubview: image4];
        [self addSubview: image5];
        
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
