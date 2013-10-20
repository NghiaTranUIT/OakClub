//
//  GroupButtons.m
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 5/7/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "GroupButtons.h"

@implementation GroupButtons

@synthesize buttons, selectedIndex, multipleChoice;

-(id)init
{
    self = [super init];
    
    buttons = [[NSMutableArray alloc] init];
    selectedIndex = 0;
    multipleChoice = FALSE;
    return self;
}

-(id)initWithMultipleChoice:(bool)choice
{
    self = [super init];
    
    buttons = [[NSMutableArray alloc] init];
    selectedIndex = 0;
    multipleChoice = choice;
    return self;
}

-(void)addButton:(UIButton*)button atIndex:(NSInteger)index
{
    [button setTag:index];
    [buttons addObject:button];
    [button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSInteger)getSelectedIndex
{
    return selectedIndex;
}

-(void)setSelectedIndex:(int)index
{
    if(multipleChoice == TRUE)
        return;
    
    for(int i = 0; i < [buttons count]; i++)
    {
        UIButton* button = (UIButton*)[buttons objectAtIndex:i];
        
        if( button.tag == index )
        {
            [button setSelected:TRUE];
        }
        else
        {
            [button setSelected:FALSE];
        }
    }
}

-(void)setSelected:(bool)selected atIndex:(int)index
{
    if(multipleChoice == FALSE)
        return;
    
    for(int i = 0; i < [buttons count]; i++)
    {
        UIButton* button = (UIButton*)[buttons objectAtIndex:i];
        
        if( button.tag == index )
        {
            [button setSelected:selected];
        }
    }
}

-(bool)getSelectedAtIndex:(NSInteger)index
{
    
    for(int i = 0; i < [buttons count]; i++)
    {
        UIButton* button = (UIButton*)[buttons objectAtIndex:i];
        
        if( button.tag == index )
        {
            return button.selected;
        }
    }
    return FALSE;
}

-(IBAction)handleButtonTap:(id)sender
{
    UIButton* selectedButton = (UIButton*)sender;
    
    if(multipleChoice)
    {
        [selectedButton setSelected:!selectedButton.selected];
    }
    else{
        for(int i = 0; i < [buttons count]; i++)
        {
            UIButton* button = (UIButton*)[buttons objectAtIndex:i];
            
            if( [button isEqual:selectedButton] )
            {
                [button setSelected:TRUE];
                selectedIndex = button.tag;
            }
            else
            {
                [button setSelected:FALSE];
            }
        }
    }

}

@end
