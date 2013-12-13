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
        CGFloat textWidth = 250;
        CGFloat spacingParagraph = 2;
        CGFloat deltaIconPosition = 2;
        
        UIImageView *image1 = [[UIImageView alloc] init];
        UILabel *content1Label = [[UILabel alloc] init];
        [content1Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content1Label setNumberOfLines: 0];
        [content1Label setText: content1String];
        [content1Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        //Set frame according to string
        CGSize size = [content1Label.text sizeWithFont:content1Label.font
                             constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        [content1Label setFrame:CGRectMake(startPoint.x , startPoint.y , size.width , size.height)];
        [image1 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image1 setFrame: CGRectMake((self.frame.size.width - 240)/2, content1Label.frame.origin.y + deltaIconPosition, 11, 11)];
        
        UIImageView *image2 = [[UIImageView alloc] init];
        UILabel *content2Label = [[UILabel alloc] init];
        [content2Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content2Label setNumberOfLines: 0];
        [content2Label setText: content2String];
        [content2Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        CGSize size2 = [content2Label.text sizeWithFont:content2Label.font
                                     constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        [content2Label setFrame:CGRectMake(startPoint.x , content1Label.frame.origin.y + content1Label.frame.size.height + spacingParagraph, size2.width , size2.height)];
        [image2 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image2 setFrame: CGRectMake((self.frame.size.width - 240)/2, content2Label.frame.origin.y+ deltaIconPosition, 11, 11)];
        
        UIImageView *image3 = [[UIImageView alloc] init];
        UILabel *content3Label = [[UILabel alloc] init];
        [content3Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content3Label setNumberOfLines: 0];
        [content3Label setText: content3String];
        [content3Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        CGSize size3 = [content3Label.text sizeWithFont:content3Label.font
                                      constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                          lineBreakMode:NSLineBreakByWordWrapping];
        [content3Label setFrame:CGRectMake(startPoint.x , content2Label.frame.origin.y + content2Label.frame.size.height + spacingParagraph, size3.width , size3.height)];
        [image3 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image3 setFrame: CGRectMake((self.frame.size.width - 240)/2, content3Label.frame.origin.y+ deltaIconPosition, 11, 11)];
        
        UIImageView *image4 = [[UIImageView alloc] init];
        UILabel *content4Label = [[UILabel alloc] init];
        [content4Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content4Label setNumberOfLines: 0];
        [content4Label setText: content4String];
        [content4Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        CGSize size4 = [content4Label.text sizeWithFont:content4Label.font
                                      constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                          lineBreakMode:NSLineBreakByWordWrapping];
        [content4Label setFrame:CGRectMake(startPoint.x , content3Label.frame.origin.y + content3Label.frame.size.height + spacingParagraph, size4.width , size4.height)];
        [image4 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image4 setFrame: CGRectMake((self.frame.size.width - 240)/2, content4Label.frame.origin.y+ deltaIconPosition, 11, 11)];
        
        UIImageView *image5 = [[UIImageView alloc] init];
        UILabel *content5Label = [[UILabel alloc] init];
        [content5Label setLineBreakMode:NSLineBreakByWordWrapping];
        [content5Label setNumberOfLines: 0];
        [content5Label setText: content5String];
        [content5Label setFont: FONT_HELVETICANEUE_LIGHT(11)];
        CGSize size5 = [content5Label.text sizeWithFont:content5Label.font
                                      constrainedToSize:CGSizeMake(textWidth, MAXFLOAT)
                                          lineBreakMode:NSLineBreakByWordWrapping];
        [content5Label setFrame:CGRectMake(startPoint.x , content4Label.frame.origin.y + content4Label.frame.size.height + spacingParagraph, size5.width , size5.height)];
        [image5 setImage: [UIImage imageNamed: @"bullet.png"]];
        [image5 setFrame: CGRectMake((self.frame.size.width - 240)/2, content5Label.frame.origin.y+ deltaIconPosition, 11, 11)];
       
        [signInButton addTarget:self action:@selector(loginTouched:) forControlEvents:UIControlEventTouchUpInside];
        [signInButton setTitle:@"Connect Privately" forState:UIControlStateNormal];
        [signInButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
//        if(IS_OS_7_OR_LATER)
//        {
//            [image1 setFrame: CGRectMake((self.frame.size.width - 240)/2, 175, 11, 11)];
//            [image2 setFrame: CGRectMake((self.frame.size.width - 240)/2, 207, 11, 11)];
//            [image3 setFrame: CGRectMake((self.frame.size.width - 240)/2, 238, 11, 11)];
//            [image4 setFrame: CGRectMake((self.frame.size.width - 240)/2, 270, 11, 11)];
//            [image5 setFrame: CGRectMake((self.frame.size.width - 240)/2, 301, 11, 11)];
//        }
        
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
