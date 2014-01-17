//
//  GroupButtons.h
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/7/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupButtons : NSObject
{
    NSMutableArray* buttons;
    BOOL multipleChoice;
}

@property NSMutableArray* buttons;
@property NSInteger selectedIndex;
@property BOOL multipleChoice;

-(void)addButton:(UIButton*)button atIndex:(NSInteger)index;
-(NSInteger)getSelectedIndex;
-(bool)getSelectedAtIndex:(NSInteger)index;

-(void)setSelectedIndex:(int)index;
-(void)setSelected:(bool)selected atIndex:(int)index;

-(id)initWithMultipleChoice:(bool)choice;

@end
