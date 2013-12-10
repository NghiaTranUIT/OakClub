//
//  CGRect+Utils.h
//  OakClub
//
//  Created by Salm on 12/10/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGRectUtils : NSObject
+(CGRect)move:(CGRect)rect delta:(CGPoint)delta;
+(CGRect)strecth:(CGRect)rect deltaSize:(CGSize)delta;
+(CGRect)moveRect:(CGRect)rect withDelta:(CGPoint)delta andStrecthWithDeltaSize:(CGSize)deltaSize;

+(CGRect)centerRect:(CGRect)inRect inOuter:(CGRect)outRect applyForXDim:(BOOL)isXDim yDim:(BOOL)isYDim;
@end