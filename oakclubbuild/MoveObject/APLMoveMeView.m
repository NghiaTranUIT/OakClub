/*
     File: APLMoveMeView.m
 Abstract: Contains a (placard) view that can be moved by touch. Illustrates
 handling touch events and two styles of animation.
 
  Version: 3.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "APLMoveMeView.h"

// Import QuartzCore for animations.
#import <QuartzCore/QuartzCore.h>

#import "VCProfile.h"
#import "VCSimpleSnapshot.h"
#import "AFHTTPClient+OakClub.h"
#import "AppDelegate.h"
@interface APLMoveMeView ()
@property (nonatomic, weak) IBOutlet UIScrollView *avatarView;
@property (nonatomic) NSUInteger nextDisplayStringIndex;
@property (nonatomic) Profile* userProfile;
@property (nonatomic) UIImage* avatar_friend;
@property (nonatomic, strong) IBOutlet VCSimpleSnapshot* snapshotView;

@end

#define RIGHT_POINT CGPointMake(600, 165)
#define LEFT_POINT CGPointMake(-400, 165)
#define CENTER_POINT CGPointMake(161,177)
#define CENTER_POINT_568H CGPointMake(161,198)

@implementation APLMoveMeView
@synthesize movemedelegate;
CGPoint startLocation;
CGPoint startCardPoint;
int deltaMove = 100;
int answerType = -1;
BOOL isReversedAnim = FALSE;
BOOL isDragging = FALSE;
-(void) addSubViewToCardView:(UIView*)subview andAtFront:(BOOL)toFront andTag:(int)numTag{
    subview.tag = numTag;
    [self.placardView addSubview:subview];
    if (!toFront) {
        [self.placardView sendSubviewToBack:subview];
    }
}
-(void)removeSubviewFromCardViewWithTag:(int)numTag{
    for (UIView* subview in [self.placardView subviews]) {
        if([subview isKindOfClass:[UIImageView class]] && subview.tag == numTag){
            [subview removeFromSuperview];
        }
    }
}
-(APLPlacardView*) getCardView{
    return self.placardView;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    AppDelegate *appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
    CGRect limitFrame = CGRectMake(0, 0,320 , self.placardView.frame.origin.y+self.placardView.frame.size.height);
    if (CGRectContainsPoint(limitFrame, point))
        appDel.rootVC.recognizesPanningOnFrontView = NO;
    else
        appDel.rootVC.recognizesPanningOnFrontView = YES;
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    
	if ([touch view] == self.placardView) {
        // Animate the first touch.
        CGPoint touchPoint = [touch locationInView:self];
        startLocation = [touch locationInView:self];
        startCardPoint =[touch locationInView:self.placardView];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    
	// If the touch was in the placardView, move the placardView to its location.
	if ([touch view] == self.placardView) {
        isDragging = TRUE;
		CGPoint location = [touch previousLocationInView:self.placardView];
        CGPoint touchLocation = [touch locationInView:self];
        CGFloat dx = touchLocation.x - startLocation.x;
        if(dx < (deltaMove*-1)){
            answerType = interestedStatusNO;
        }
        else{
            if(dx > deltaMove){
                answerType = interestedStatusYES;
            }
            else{
                answerType = -1;
            }
                
        }
        if (dx < 0){
            [self.placardView setAlphaNOPEView:fabsf(dx)/100];
        }
        else{
            [self.placardView setAlphaLIKEView:dx/100];
        }

        CGPoint newCenter = CGPointMake(self.placardView.center.x + (location.x-startCardPoint.x), self.placardView.center.y + (location.y-startCardPoint.y));
		self.placardView.center = newCenter;
        
        // make a curve when draging
        CGFloat angle = (touchLocation.x-startLocation.x) * (touchLocation.y-startLocation.y) * M_PI/180000;
        NSLog(@"(touchLocation.x-startLocation.x): %f", (touchLocation.x-startLocation.x));
        NSLog(@"(touchLocation.y-startLocation.y): %f", (touchLocation.y-startLocation.y));
        NSLog(@"angle: %f", angle);
        CGAffineTransform transforms = CGAffineTransformMakeRotation(angle);
        self.placardView.transform = transforms;
        
		return;
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    
    NSLog(@"touchesEnded [touch view]: %@", [touch view]);
	// If the touch was in the placardView, bounce it back to the center.
	if ([touch view] == self.placardView) {
        if(isDragging)
            isDragging = FALSE;
        else{
            [self.snapshotView  gotoPROFILE];
            return;
        }
		self.userInteractionEnabled = NO;
        NSLog(@"touchesEnded self.userInteractionEnabled: %d", self.userInteractionEnabled);
        
        [self animatePlacardViewToCenter];
        [self.placardView setAlphaNOPEView:0];
        [self.placardView setAlphaLIKEView:0];
        
        if(answerType >0){
            [self.snapshotView setLikedSnapshot:[NSString stringWithFormat:@"%i",answerType]];
        }
        
		return;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	/*
     To impose as little impact on the device as possible, simply set the placard view's center and transformation to the original values.
     */
    if(IS_HEIGHT_GTE_568)
        self.placardView.center = CENTER_POINT_568H;
    else
        self.placardView.center = CENTER_POINT;//self.center;
	self.placardView.transform = CGAffineTransformIdentity;
}


/*
 First of two possible implementations of animateFirstTouchAtPoint: illustrating different behaviors.
 To choose the second, replace '1' with '0' below.
 */

#define GROW_FACTOR 1.2f
#define SHRINK_FACTOR 1.1f

/**
 Bounce the placard back to the center.
*/
- (void)animatePlacardViewToCenter{
	
    APLPlacardView *placardView = self.placardView;
    CALayer *welcomeLayer = placardView.layer;
	
	// Create a keyframe animation to follow a path back to the center.
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
	CGFloat animationDuration = 0.15;
    
	// Create the path for the bounces.
	UIBezierPath *bouncePath = [[UIBezierPath alloc] init];
    CGPoint centerPoint;
    switch (answerType) {
        case interestedStatusNO:
            centerPoint = LEFT_POINT;
            break;
        case interestedStatusYES:
            centerPoint = RIGHT_POINT;
            break;
        default:{
            if (IS_HEIGHT_GTE_568)
                centerPoint = CENTER_POINT_568H;
            else
                centerPoint = CENTER_POINT;
            break;
        }
    }
	CGFloat midX = centerPoint.x;
	CGFloat midY = centerPoint.y;
    CGPoint targetPoint = CGPointMake(midX, midY);

	// Start the path at the placard's current location.
	[bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
	[bouncePath addLineToPoint:targetPoint];
	
	
	bounceAnimation.path = [bouncePath CGPath];
	bounceAnimation.duration = animationDuration;
	
    /*
	// Create a basic animation to restore the size of the placard.
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = animationDuration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	*/
	
	// Create an animation group to combine the keyframe and basic animations.
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction.
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = @[bounceAnimation/*, transformAnimation*/];
	theGroup.removedOnCompletion = NO;
	
	// Add the animation group to the layer.
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
    
    placardView.center = targetPoint;
	placardView.transform = CGAffineTransformIdentity;
}

- (void)animatePlacardViewByReverseAnswer:(int)answer WithDuration:(CGFloat)duration{
    isReversedAnim = TRUE;
    APLPlacardView *placardView = self.placardView;
    CALayer *welcomeLayer = placardView.layer;
	//update position of PalcardView
    switch (answer) {
        case interestedStatusNO:
            placardView.center = LEFT_POINT;
            break;
        case interestedStatusYES:
            placardView.center = RIGHT_POINT;
            break;
        default:
            if(IS_HEIGHT_GTE_568)
                placardView.center = CENTER_POINT_568H;
            else
                placardView.center = CENTER_POINT;
            
    }
	// Create a keyframe animation to follow a path back to the center.
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
    
	
	// Create the path for the bounces.
	UIBezierPath *bouncePath = [[UIBezierPath alloc] init];
	
    CGPoint centerPoint;// = self.center;
    if(IS_HEIGHT_GTE_568)
        centerPoint = CENTER_POINT_568H;
    else
        centerPoint = CENTER_POINT;

    
	CGFloat midX = centerPoint.x;
	CGFloat midY = centerPoint.y;
    
	// Start the path at the placard's current location.
	[bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
	[bouncePath addLineToPoint:CGPointMake(midX, midY)];

	bounceAnimation.path = [bouncePath CGPath];
	bounceAnimation.duration = duration;
	
	// Create a basic animation to restore the size of the placard.
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = duration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	
	// Create an animation group to combine the keyframe and basic animations.
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction.
	theGroup.delegate = self;
	theGroup.duration = duration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = @[bounceAnimation, transformAnimation];
	
	
	// Add the animation group to the layer.
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation.
	placardView.center = centerPoint;
	placardView.transform = CGAffineTransformIdentity;
}

- (void)animatePlacardViewByAnswer:(int)answer andDuration:(CGFloat)duration{
    answerType = answer;
    APLPlacardView *placardView = self.placardView;
    CALayer *welcomeLayer = placardView.layer;
	
	// Create a keyframe animation to follow a path back to the center.
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = duration;
	
	// Create the path for the bounces.
	UIBezierPath *bouncePath = [[UIBezierPath alloc] init];
    CGPoint targetPoint;
    switch (answer) {
        case interestedStatusNO:
            targetPoint = LEFT_POINT;
            break;
        case interestedStatusYES:
            targetPoint = RIGHT_POINT;
            break;
//        default:
//        {
//            if(IS_HEIGHT_GTE_568)
//                centerPoint = CENTER_POINT_568H;
//            else
//                centerPoint = CENTER_POINT;
//            break;
//        }
    }
	CGFloat midX = targetPoint.x;
	CGFloat midY = targetPoint.y;
    
	// Start the path at the placard's current location.
	[bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
	[bouncePath addLineToPoint:CGPointMake(midX, midY)];
	
	bounceAnimation.path = [bouncePath CGPath];
	bounceAnimation.duration = animationDuration;
	
    /*
     // Create a basic animation to restore the size of the placard.
     CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
     transformAnimation.removedOnCompletion = YES;
     transformAnimation.duration = animationDuration;
     transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
     */
    
	//create a basic rotate during moving
    CABasicAnimation* rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    rotateAnim.toValue = [NSNumber numberWithFloat: 2*M_PI];
    rotateAnim.duration = 2.0f;
    rotateAnim.repeatCount = INFINITY;
    
	// Create an animation group to combine the keyframe and basic animations.
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction.
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = @[bounceAnimation,rotateAnim /*, transformAnimation*/];
	
	
	// Add the animation group to the layer.
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
    placardView.center = targetPoint;
	placardView.transform = CGAffineTransformIdentity;
}


/**
 Animation delegate method called when the animation's finished: restore the transform and reenable user interaction.
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    NSLog(@"move me animationDidStop");
    APLPlacardView *placardView = self.placardView;
    CALayer *welcomeLayer = placardView.layer;
    [welcomeLayer removeAnimationForKey:@"animatePlacardViewToCenter"];
    
	self.placardView.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
    NSLog(@"animationDidStop self.userInteractionEnabled: %d", self.userInteractionEnabled);
    if(!isReversedAnim){
        if( ((self.placardView.center.x == LEFT_POINT.x && self.placardView.center.y == LEFT_POINT.y)
            || (self.placardView.center.x == RIGHT_POINT.x && self.placardView.center.y == RIGHT_POINT.y))
           && answerType == -1)
        {
            
        }else{
            if(IS_HEIGHT_GTE_568)
                self.placardView.center = CENTER_POINT_568H;
            else
                self.placardView.center = CENTER_POINT;
            
            self.placardView.transform = CGAffineTransformIdentity;
            NSLog(@"animationDidStop self.placardView: %@ ", self.placardView);
        }
        
        if (movemedelegate) {
            if ([movemedelegate respondsToSelector:@selector(animationDidStop:andAnswerType:)]) {
                [movemedelegate animationDidStop:theAnimation andAnswerType:answerType];
            }
        }
    }
    answerType = -1;
    isReversedAnim = FALSE;
}

- (void)setupNextDisplayString {
    NSUInteger nextIndex = self.nextDisplayStringIndex;
    NSString *displayString = self.displayStrings[nextIndex];
    [self.placardView setDisplayString:displayString];

    nextIndex++;
    if (nextIndex >= [self.displayStrings count]) {
        nextIndex = 0;
    }
    self.nextDisplayStringIndex = nextIndex;

    self.placardView.center = self.center;
}

-(void) setUserProfile:(Profile*)profile andImage:(UIImage*)image{
    self.userProfile = profile;
    self.avatar_friend = image;
}
-(int) getAnswer{
    return answerType;
}
-(void) setAnswer:(int)type{
    answerType = type;
}

@end
