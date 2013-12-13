//
//  Animation.h
//  OakClub
//
//  Created by To Huy on 12/10/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Animation : NSObject 
{
    UIView* view;
    NSMutableArray *arr;
    int index;
    int step;
}
-(void) translationX: (int) index withFromValue: (int) fromValue withToValue: (int) toValue withDuration: (float) duration;
-(void) translationY: (int) index withFromValue: (int) fromValue withToValue: (int) toValue withDuration: (float) duration;
-(void) start;
-(void) setView: (UIView*) view;
-(void) setIndex: (int) index;
-(void) setStep: (int) step;
-(void) setArr: (NSArray*) arr;
@end
