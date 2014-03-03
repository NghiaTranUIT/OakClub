//
//  EmoticonParser.h
//  OakClub
//
//  Created by Salm on 2/13/14.
//  Copyright (c) 2014 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EmoticonParser <NSObject>
-(bool)parseEmoticonForText:(NSString *)text useFont:(UIFont *)font toView:(UIView *)view;
@end