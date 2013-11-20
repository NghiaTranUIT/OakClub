//
//  LoadingIndicator.h
//  OakClub
//
//  Created by Salm on 11/19/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoadingIndicatorDelegate <NSObject>

@optional
-(void)customizeIndicator:(UIActivityIndicatorView *)indicator;
-(void)lockView;
-(void)unlockView;
@end

@interface LoadingIndicator : NSObject
-(id)initWithMainView:(UIView *)mainView andDelegate:(id<LoadingIndicatorDelegate>)delegate;

-(void)lockViewAndDisplayIndicator;
-(void)unlockViewAndStopIndicator;
@end
