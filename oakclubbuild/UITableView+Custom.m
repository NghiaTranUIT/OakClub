//
//  UITableView+Custom.m
//  OakClub
//
//  Created by VanLuu on 6/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UITableView+Custom.h"
#import <QuartzCore/QuartzCore.h>
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
            backgroundView.backgroundColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1];
            backgroundView.layer.cornerRadius = 9.0;
            backgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            backgroundView.layer.borderWidth = 1;
//            CGRect tophalfCellRect = CGRectMake(0, selectedBackground.frame.size.height/2, selectedBackground.frame.size.width, selectedBackground.frame.size.height/2);
//            maskPath = [UIBezierPath bezierPathWithRoundedRect:tophalfCellRect
//                                             byRoundingCorners: UIRectCornerBottomLeft|UIRectCornerBottomRight
//                                                   cornerRadii:CGSizeMake(9.0, 9.0)];
//            maskLayer = [CAShapeLayer layer];
//            maskLayer.frame = selectedBackground.bounds;
//            maskLayer.path = maskPath.CGPath;
//            maskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
//            maskLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//            maskLayer.lineWidth = 1;
//            [selectedBackground.layer addSublayer:maskLayer];
//            CGRect bottomhalfCellRect = CGRectMake(0, 0, selectedBackground.frame.size.width, selectedBackground.frame.size.height/2);
//            maskPath = [UIBezierPath bezierPathWithRoundedRect:bottomhalfCellRect
//                                             byRoundingCorners: UIRectCornerTopLeft|UIRectCornerTopRight
//                                                   cornerRadii:CGSizeMake(9.0, 9.0)];
//            maskLayer = [CAShapeLayer layer];
//            maskLayer.frame = selectedBackground.bounds;
//            maskLayer.path = maskPath.CGPath;
//            maskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
//            maskLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//            maskLayer.lineWidth = 1;
//            [selectedBackground.layer addSublayer:maskLayer];
        }
        else{
        maskPath = [UIBezierPath bezierPathWithRoundedRect:selectedBackground.bounds
                                                       byRoundingCorners: UIRectCornerTopLeft|UIRectCornerTopRight
                                                             cornerRadii:CGSizeMake(9.0, 9.0)];
        maskLayer = [CAShapeLayer layer];
        maskLayer.frame = selectedBackground.bounds;
        maskLayer.path = maskPath.CGPath;
        maskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
        maskLayer.strokeColor = [UIColor lightGrayColor].CGColor;
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
            maskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
            maskLayer.strokeColor = [UIColor lightGrayColor].CGColor;
            maskLayer.lineWidth = 1;
            [selectedBackground.layer addSublayer:maskLayer];
        }
        else{
            maskPath = [UIBezierPath bezierPathWithRect:selectedBackground.bounds];
            maskLayer = [CAShapeLayer layer];
            maskLayer.frame = selectedBackground.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
            maskLayer.strokeColor = [UIColor lightGrayColor].CGColor;
            maskLayer.lineWidth = 1;
            [selectedBackground.layer addSublayer:maskLayer];
        }
        UIImageView *topLineBG = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, frame.size.width - 21.0 , 2)];
        UIBezierPath *lineMaskPath = [UIBezierPath bezierPathWithRect:topLineBG.bounds];
        CAShapeLayer *lineMaskLayer = [CAShapeLayer layer];
        lineMaskLayer.frame = topLineBG.bounds;
        lineMaskLayer.path = lineMaskPath.CGPath;
        lineMaskLayer.fillColor = [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor;
        [topLineBG.layer addSublayer:lineMaskLayer];
        [selectedBackground addSubview:topLineBG];
    }
    [backgroundView addSubview:selectedBackground];
    return backgroundView;
}
@end
