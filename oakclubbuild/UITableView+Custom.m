//
//  UITableView+Custom.m
//  OakClub
//
//  Created by VanLuu on 6/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UITableView+Custom.h"
#import <QuartzCore/QuartzCore.h>
#import "Define.h"
@implementation UITableView (Custom)
-(UIView* )customSelectdBackgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath{
    CGRect frame = [self  rectForRowAtIndexPath:indexPath];
    UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
    UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.5, 0, frame.size.width - 19.0 , frame.size.height)];
    NSUInteger latestIndex = [self numberOfRowsInSection:[indexPath section]] - 1;
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    UIBezierPath *maskPath;
    CAShapeLayer *maskLayer;
    if (row == 0) {
        if([self numberOfRowsInSection:section] == 1){
            backgroundView.backgroundColor = COLOR_PURPLE;
            backgroundView.layer.cornerRadius = 9.0;
            backgroundView.layer.borderColor = CGCOLOR_PURPLE;//[UIColor lightGrayColor].CGColor;
            backgroundView.layer.borderWidth = 1;
        }
        else{
        maskPath = [UIBezierPath bezierPathWithRoundedRect:selectedBackground.bounds
                                                       byRoundingCorners: UIRectCornerTopLeft|UIRectCornerTopRight
                                                             cornerRadii:CGSizeMake(9.0, 9.0)];
        maskLayer = [CAShapeLayer layer];
        maskLayer.frame = selectedBackground.bounds;
        maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = CGCOLOR_PURPLE;//[UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
            maskLayer.strokeColor = CGCOLOR_PURPLE;//[UIColor lightGrayColor].CGColor;
        maskLayer.lineWidth = 1;
        [selectedBackground.layer addSublayer:maskLayer];
        }
    }
    else{
        
        if(row == latestIndex){
            maskPath = [UIBezierPath bezierPathWithRoundedRect:selectedBackground.bounds
                                                           byRoundingCorners: UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(9.0, 9.0)];
            maskLayer = [CAShapeLayer layer];
            maskLayer.frame = selectedBackground.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = CGCOLOR_PURPLE;//[UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
            maskLayer.strokeColor = CGCOLOR_PURPLE;//[UIColor lightGrayColor].CGColor;
            maskLayer.lineWidth = 1;
            [selectedBackground.layer addSublayer:maskLayer];
        }
        else{
            maskPath = [UIBezierPath bezierPathWithRect:selectedBackground.bounds];
            maskLayer = [CAShapeLayer layer];
            maskLayer.frame = selectedBackground.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = CGCOLOR_PURPLE;//[UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
            maskLayer.strokeColor = CGCOLOR_PURPLE;//[UIColor lightGrayColor].CGColor;
            maskLayer.lineWidth = 1;
            [selectedBackground.layer addSublayer:maskLayer];
        }
        UIImageView *topLineBG = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, frame.size.width - 21.0 , 2)];
        UIBezierPath *lineMaskPath = [UIBezierPath bezierPathWithRect:topLineBG.bounds];
        CAShapeLayer *lineMaskLayer = [CAShapeLayer layer];
        lineMaskLayer.frame = topLineBG.bounds;
        lineMaskLayer.path = lineMaskPath.CGPath;
        lineMaskLayer.fillColor = CGCOLOR_PURPLE;//[UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
        [topLineBG.layer addSublayer:lineMaskLayer];
        [selectedBackground addSubview:topLineBG];
    }
    [backgroundView addSubview:selectedBackground];
    return backgroundView;
}
@end
