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
@property (nonatomic, strong) IBOutlet APLPlacardView *placardView;
@property (nonatomic, weak) IBOutlet UIScrollView *avatarView;
@property (nonatomic) NSUInteger nextDisplayStringIndex;
@property (nonatomic) Profile* userProfile;
@property (nonatomic) UIImage* avatar_friend;
@property (nonatomic, strong) IBOutlet VCSimpleSnapshot* snapshotView;

@end

#define RIGHT_POINT CGPointMake(600, 165)
#define LEFT_POINT CGPointMake(-400, 165)
#define CENTER_POINT CGPointMake(160,176)
#define CENTER_POINT_568H CGPointMake(160,198)

@implementation APLMoveMeView
@synthesize movemedelegate;
CGPoint startLocation;
CGPoint startCardPoint;
int deltaMove = 100;
int answerType = -1;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self changeView];
	// We only support single touches, so anyObject retrieves just that touch from touches.
	UITouch *touch = [touches anyObject];
	if ([touch view] == self.placardView) {
//        if ([touch tapCount] == 2) {
//            VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
//            [viewProfile loadProfile:self.userProfile andImage:self.avatar_friend];
//            
//            [self.navigationController pushViewController:viewProfile animated:YES];
//        }
//        else{
            // Animate the first touch.
            CGPoint touchPoint = [touch locationInView:self];
            startLocation = [touch locationInView:self];
        startCardPoint =[touch locationInView:self.placardView];
//        startLocation = CGPointMake(160, 240);
            [self animateFirstTouchAtPoint:touchPoint];
//        }
       
    }
	// Only move the placard view if the touch was in the placard view.
//	if ([touch view] != self.placardView) {
//		// In case of a double tap outside the placard view, update the placard's display string.
//		if ([touch tapCount] == 2) {
//			[self setupNextDisplayString];
//		}
//		return;
//	}
    
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, move the placardView to its location.
	if ([touch view] == self.placardView) {
        isDragging = TRUE;
		CGPoint location = [touch previousLocationInView:self.placardView];
        CGPoint touchLocation = [touch locationInView:self];
//        NSLog(@"%f",[touch locationInView:self].x);
        CGFloat dx = touchLocation.x - startLocation.x;
//        CGFloat dy = location.y - startLocation.y;
        NSLog(@"location.x:%f - startLocation.x:%f",touchLocation.x,startLocation.x);
        NSLog(@"dx:%f",dx);
        if(dx < (deltaMove*-1)){
//            [self.placardView setAlphaNOPEView:fabsf(dx)/100];
            answerType = interestedStatusNO;
        }
        else{
            if(dx > deltaMove){
//                [self.placardView setAlphaLIKEView:dx/100];
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

//        if(touchLocation.x < 60){
//            answerType = interestedStatusNO;
//        }
//        else{
//            if(touchLocation.x > 260){
//                answerType = interestedStatusYES;
//            }
//            else{
//                answerType = -1;
//            }
//           
//        }
        CGPoint newCenter = CGPointMake(self.placardView.center.x + (location.x-startCardPoint.x), self.placardView.center.y/* + (location.y-startCardPoint.y)*/);
		self.placardView.center = newCenter;
        
        // make a curve when draging
        CGAffineTransform transforms = CGAffineTransformConcat(self.placardView.transform,CGAffineTransformMakeRotation(M_PI/900*((location.x-startCardPoint.x)>0?-1:1)));
        self.placardView.transform = transforms;
        
		return;
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
    
	// If the touch was in the placardView, bounce it back to the center.
	if ([touch view] == self.placardView) {
        if(isDragging)
            isDragging = FALSE;
        else
            [self.snapshotView  gotoPROFILE];
		/*
         Disable user interaction so subsequent touches don't interfere with animation until the placard has returned to the center. Interaction is reenabled in animationDidStop:finished:.
         */
//        [self.placardView setAlpha:0];
		self.userInteractionEnabled = NO;
		[self animatePlacardViewToCenter];
        [self.placardView setAlphaNOPEView:0];
        [self.placardView setAlphaLIKEView:0];
//        [self.snapshotView loadView];
        if(answerType >0){
            [self.snapshotView setFavorite:[NSString stringWithFormat:@"%i",answerType]];
//            [self.snapshotView loadCurrentProfile];
        }
		return;
	}
}

//-(void)setFavorite:(NSString*)answerChoice{
//    AFHTTPClient* request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
////    NSLog(@"current id = %@",currentProfile.s_snapshotID);
//    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//     NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSnapShotID"];
//    if ([answerChoice isEqualToString:@"1"]) {
//        if([appDelegate.likedMeList containsObject:value]){
//            [self.snapshotView showMatchView];
//        }
//    }
//   
//    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:value ,@"snapshot_id",answerChoice,@"set", nil];
//    [request getPath:URL_setFavorite parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
//        NSLog(@"post success !!!");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
//    }];
//}


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

#if 1

/**
 "Pulse" the placard view by scaling up then down, then move the placard to under the finger.
*/
- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
	/*
	 This illustrates using UIView's built-in animation.  We want, though, to animate the same property (transform) twice -- first to scale up, then to shrink.  You can't animate the same property more than once using the built-in animation -- the last one wins.  So we'll set a delegate action to be invoked after the first animation has finished.  It will complete the sequence.
     
     The touch point is passed in an NSValue object as the context to beginAnimations:. To make sure the object survives until the delegate method, pass the reference as retained.
	 */
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
//	
//	NSValue *touchPointValue = [NSValue valueWithCGPoint:touchPoint];
//	[UIView beginAnimations:nil context:(__bridge_retained void *)touchPointValue];
//	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
//	CGAffineTransform transform = CGAffineTransformMakeScale(GROW_FACTOR, GROW_FACTOR);
//	self.placardView.transform = transform;
//	[UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

#define MOVE_ANIMATION_DURATION_SECONDS 0.15

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
	self.placardView.transform = CGAffineTransformMakeScale(SHRINK_FACTOR, SHRINK_FACTOR);
	/*
	 Move the placardView to under the touch.
	 We passed the location wrapped in an NSValue as the context. Get the point from the value, and transfer ownership to ARC to balance the bridge retain in touchesBegan:withEvent:.
	 */
	NSValue *touchPointValue = (__bridge_transfer NSValue *)context;
	self.placardView.center = [touchPointValue CGPointValue];
	[UIView commitAnimations];
}

#else

/*
 Alternate behavior.
 The preceding implementation grows the placard in place then moves it to the new location and shrinks it at the same time.  An alternative is to move the placard for the total duration of the grow and shrink operations; this gives a smoother effect.
 
 */


/**
 Create two separate animations. The first animation is for the grow and partial shrink. The grow animation is performed in a block. The method uses a completion block that itself includes an animation block to perform the shrink. The second animation lasts for the total duration of the grow and shrink animations and contains a block responsible for performing the move.
 */

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {

#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15

    [UIView animateWithDuration:GROW_ANIMATION_DURATION_SECONDS animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(GROW_FACTOR, GROW_FACTOR);
        self.placardView.transform = transform;
    }
                     completion:^(BOOL finished){

                         [UIView animateWithDuration:(NSTimeInterval)SHRINK_ANIMATION_DURATION_SECONDS animations:^{
                             self.placardView.transform = CGAffineTransformMakeScale(SHRINK_FACTOR, SHRINK_FACTOR);
                         }];

                     }];

    [UIView animateWithDuration:(NSTimeInterval)GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS animations:^{
        self.placardView.center = touchPoint;
    }];
    
}


/*

 Equivalent implementation using delegate-based method.
 
- (void)animateFirstTouchAtPointOld:(CGPoint)touchPoint {
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
	self.placardView.transform = transform;
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS];
	self.placardView.center = touchPoint;
	[UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
	self.placardView.transform = CGAffineTransformMakeScale(1.1, 1.1);
	[UIView commitAnimations];
}
*/


#endif


/**
 Bounce the placard back to the center.
*/
- (void)animatePlacardViewToCenter{
	
    APLPlacardView *placardView = self.placardView;
    CALayer *welcomeLayer = placardView.layer;
	
	// Create a keyframe animation to follow a path back to the center.
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 0.25f;
    
    if(answerType != -1){
        animationDuration = 0.5f;
        [NSTimer scheduledTimerWithTimeInterval:0.2f
                                         target:self
                                       selector:@selector(handleTimer)
                                       userInfo:nil
                                        repeats:NO];
    }
	
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
//	CGFloat originalOffsetX = placardView.center.x - midX;
//	CGFloat originalOffsetY = placardView.center.y - midY;
//	CGFloat offsetDivider = 4.0f;
	
//	BOOL stopBouncing = NO;

	// Start the path at the placard's current location.
	[bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
	[bouncePath addLineToPoint:CGPointMake(midX, midY)];
	
	// Add to the bounce path in decreasing excursions from the center.
//	while (stopBouncing != YES) {
//
//        CGPoint excursion = CGPointMake(midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
//        [bouncePath addLineToPoint:excursion];
//        [bouncePath addLineToPoint:centerPoint];
//
//		offsetDivider += 4;
//		animationDuration += 1/offsetDivider;
//		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
//			stopBouncing = YES;
//		}
//	}
	
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
	
	
	// Add the animation group to the layer.
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
  
    
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation.
    if (IS_HEIGHT_GTE_568) {
        placardView.center = CENTER_POINT_568H;
    }
    else{
        placardView.center = CENTER_POINT;
    }
	
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
    CGPoint centerPoint;
    switch (answer) {
        case interestedStatusNO:
            centerPoint = LEFT_POINT;
            break;
        case interestedStatusYES:
            centerPoint = RIGHT_POINT;
            break;
        default:
        {
            if(IS_HEIGHT_GTE_568)
                centerPoint = CENTER_POINT_568H;
            else
                centerPoint = CENTER_POINT;
            break;
        }
    }
	CGFloat midX = centerPoint.x;
	CGFloat midY = centerPoint.y;
    //	CGFloat originalOffsetX = placardView.center.x - midX;
    //	CGFloat originalOffsetY = placardView.center.y - midY;
    //	CGFloat offsetDivider = 4.0f;
	
    //	BOOL stopBouncing = NO;
    
	// Start the path at the placard's current location.
	[bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
	[bouncePath addLineToPoint:CGPointMake(midX, midY)];
	
	// Add to the bounce path in decreasing excursions from the center.
    //	while (stopBouncing != YES) {
    //
    //        CGPoint excursion = CGPointMake(midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
    //        [bouncePath addLineToPoint:excursion];
    //        [bouncePath addLineToPoint:centerPoint];
    //
    //		offsetDivider += 4;
    //		animationDuration += 1/offsetDivider;
    //		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
    //			stopBouncing = YES;
    //		}
    //	}
	
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
	
    
    //add new animation
    [NSTimer scheduledTimerWithTimeInterval:0.2f
                                     target:self
                                   selector:@selector(handleTimer)
                                   userInfo:nil
                                    repeats:NO];
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation.
    if(IS_HEIGHT_GTE_568)
        placardView.center = CENTER_POINT_568H;
    else
        placardView.center = CENTER_POINT;
	placardView.transform = CGAffineTransformIdentity;
}


/**
 Animation delegate method called when the animation's finished: restore the transform and reenable user interaction.
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	self.placardView.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
    [self.placardView setAlpha:1];
    /*
    if(answerType != -1 && self.snapshotView.isContinueLoad){
        [self.snapshotView loadCurrentProfile];
        [self.snapshotView loadNextProfileByCurrentIndex];
//        [self bringSubviewToFront:self.placardView];
         answerType = -1;
        if(IS_HEIGHT_GTE_568)
            self.placardView.center = CENTER_POINT_568H;
        else
            self.placardView.center = CENTER_POINT;
//        self.placardView.center = CENTER_POINT;
        self.placardView.transform = CGAffineTransformIdentity;
    }
    else if (!self.snapshotView.isContinueLoad)
    {
        [self.snapshotView showWarning];
    }
     */
    if(IS_HEIGHT_GTE_568)
        self.placardView.center = CENTER_POINT_568H;
    else
        self.placardView.center = CENTER_POINT;
    self.placardView.transform = CGAffineTransformIdentity;
    if (movemedelegate) {
        if ([movemedelegate respondsToSelector:@selector(animationDidStop:andAnswerType:)]) {
            [movemedelegate animationDidStop:theAnimation andAnswerType:answerType];
        }
    }
    answerType = -1;
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

#pragma mark Timer
- (void)handleTimer
{
    [self.placardView setAlpha:0];
}
@end
