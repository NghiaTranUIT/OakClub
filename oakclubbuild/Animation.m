//
//  Animation.m
//  OakClub
//
//  Created by To Huy on 12/10/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Animation.h"

@implementation Animation

-(id) init
{
    self = [super init];
    if (self) {
        // Initialization code
        arr = [[NSMutableArray alloc] init];
    }
    return self;
    
}

-(void) translationX:(int) index1 withFromValue:(int)fromValue withToValue:(int)toValue withDuration:(float)duration
{
    CABasicAnimation *movex = [CABasicAnimation animationWithKeyPath:@"transform.translation.x" ];
    [movex setFromValue:[NSNumber numberWithFloat:fromValue]];
    [movex setToValue:[NSNumber numberWithFloat:toValue]];
    [movex setDuration: duration];
    [movex setDelegate:self];
    //[[view layer] addAnimation:movex forKey:@"transform.translation.x"];
    [movex setValue: [NSString stringWithFormat:@"%d", index1] forKey:[NSString stringWithFormat:@"%d", index1]];
    [arr addObject: movex];
}

-(void) translationY:(int) index1 withFromValue:(int)fromValue withToValue:(int)toValue withDuration:(float)duration
{
    CABasicAnimation *movey = [CABasicAnimation animationWithKeyPath:@"transform.translation.y" ];
    [movey setFromValue:[NSNumber numberWithFloat: fromValue]];
    [movey setToValue:[NSNumber numberWithFloat: toValue]];
    [movey setDuration:duration];
    [movey setDelegate: self];
    //[[view layer] addAnimation:movey forKey:@"transform.translation.y"];
    [movey setValue: [NSString stringWithFormat:@"%d", index1] forKey:[NSString stringWithFormat:@"%d", index1]];
    [arr addObject: movey];
}
-(void) start
{
    if (index < [arr count])
    {
        for (int i = 0; i < 2; i++)
        {
            [[view layer] addAnimation:(CABasicAnimation*) arr[index] forKey:nil];
        }
    }
    else
    {
        //return;
    }
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"stop");
    if ([[anim valueForKey:[NSString stringWithFormat:@"%d", index]] isEqualToString:[NSString stringWithFormat:@"%d", index]])
    {
        index++;
        [self start];
    }
}

-(void) setView:(UIView *)view1
{
    view = view1;
}
-(void) setIndex:(int)index1
{
    index =index1;
}
-(void) setArr:(NSArray *)arr1
{
    //arr = arr1;
}

@end
