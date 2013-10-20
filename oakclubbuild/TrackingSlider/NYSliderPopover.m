//
//  NYSliderPopover.m
//  NYReader
//
//  Created by Cassius Pacheco on 21/12/12.
//  Copyright (c) 2012 Nyvra Software. All rights reserved.
//

#import "NYSliderPopover.h"
#import "NYPopover.h"

#define THUMB_SIZE 10
#define EFFECTIVE_THUMB_SIZE 20

@implementation NYSliderPopover

#pragma mark -
#pragma mark UISlider methods

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -10, -8);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    float thumbPercent = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float thumbPos = THUMB_SIZE + (thumbPercent * (bounds.size.width - (2 * THUMB_SIZE)));
    CGPoint touchPoint = [touch locationInView:self];
    return (touchPoint.x >= (thumbPos - EFFECTIVE_THUMB_SIZE) &&
            touchPoint.x <= (thumbPos + EFFECTIVE_THUMB_SIZE));
}
- (NYPopover *)popover
{
    if (_popover == nil) {
        //Default size, can be changed after
        self.continuous = YES;
        [self addTarget:self action:@selector(updatePopoverFrame) forControlEvents:UIControlEventValueChanged];
        _popover = [[NYPopover alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - 32, 40, 32)];
        [self updatePopoverFrame];
        _popover.alpha = 0;
        [self.superview addSubview:_popover];
    }
    
    return _popover;
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [self updatePopoverFrame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self updatePopoverFrame];
//    [self showPopoverAnimated:YES];
    [super touchesBegan:touches withEvent:event];
    
    NSLog(@"1. touchesBegan");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@"2. touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self hidePopoverAnimated:YES];
    [super touchesEnded:touches withEvent:event];
    
    NSLog(@"3. touchesEnded");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self hidePopoverAnimated:YES];
    
    //[super touchesCancelled:touches withEvent:event];
    
    NSLog(@"4. touchesCancelled");
}

#pragma mark -
#pragma mark - Popover methods

- (void)updatePopoverFrame
{
    //Inspired in Collin Ruffenach's ELCSlider https://github.com/elc/ELCSlider/blob/master/ELCSlider/ELCSlider.m#L53
    
    CGFloat minimum =  self.minimumValue;
	CGFloat maximum = self.maximumValue;
	CGFloat value = self.value;
	
	if (minimum < 0.0) {
        
		value = self.value - minimum;
		maximum = maximum - minimum;
		minimum = 0.0;
	}
	
	CGFloat x = self.frame.origin.x;
    CGFloat maxMin = (maximum + minimum) / 2.0;
    
    x += (((value - minimum) / (maximum - minimum)) * self.frame.size.width) - (self.popover.frame.size.width / 2.0);
	
	if (value > maxMin) {
		
		value = (value - maxMin) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x - value;
        
	} else {
		
		value = (maxMin - value) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x + value;
	}
    
    CGRect popoverRect = self.popover.frame;
    popoverRect.origin.x = x;
    popoverRect.origin.y = self.frame.origin.y - popoverRect.size.height - 1;
    
    self.popover.frame = popoverRect;
    NSLog(@"updatePopoverFrame: value = %f", value);
}

- (void)showPopover
{
    [self showPopoverAnimated:NO];
}

- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 1.0;
        }];
    } else {
        self.popover.alpha = 1.0;
    }
}

- (void)hidePopover
{
    [self hidePopoverAnimated:NO];
}

- (void)hidePopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 0;
        }];
    } else {
        self.popover.alpha = 0;
    }
}

@end
