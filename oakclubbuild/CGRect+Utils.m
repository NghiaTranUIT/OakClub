//
//  CGRect+Utils.m
//  OakClub
//
//  Created by Salm on 12/10/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "CGRect+Utils.h"

@implementation CGRectUtils
+(CGRect)move:(CGRect)rect delta:(CGPoint)delta
{
    return CGRectMake(rect.origin.x + delta.x, rect.origin.y + delta.y, rect.size.width, rect.size.height);
}
+(CGRect)strecth:(CGRect)rect deltaSize:(CGSize)delta
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + delta.width, rect.size.height + delta.height);
}
+(CGRect)moveRect:(CGRect)rect withDelta:(CGPoint)delta andStrecthWithDeltaSize:(CGSize)deltaSize
{
    return CGRectMake(rect.origin.x + delta.x, rect.origin.y + delta.y, rect.size.width + deltaSize.width, rect.size.height + deltaSize.height);
}
+(CGRect)centerRect:(CGRect)inRect inOuter:(CGRect)outRect applyForXDim:(BOOL)isXDim yDim:(BOOL)isYDim
{
    if (isXDim)
    {
        inRect.origin.x = (outRect.size.width - inRect.size.width) / 2;
    }
    
    if (isYDim)
    {
        inRect.origin.y = (outRect.size.height - inRect.size.height) / 2;
    }
    
    return inRect;
}
@end