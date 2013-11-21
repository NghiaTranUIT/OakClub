//
//  LoadingIndicator.h
//  OakClub
//
//  Created by Salm on 11/19/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoadingIndicator;

@protocol LoadingIndicatorDelegate <NSObject>

@optional
-(void)customizeIndicator:(UIActivityIndicatorView *)indicator ofLoadingIndicator:(LoadingIndicator *)loadingIndicator;
-(void)lockViewForIndicator:(LoadingIndicator *)indicator;
-(void)unlockViewForIndicator:(LoadingIndicator *)indicator;
@end

@interface LoadingIndicator : NSObject
-(id)initWithMainView:(UIView *)mainView andDelegate:(id<LoadingIndicatorDelegate>)delegate;

-(void)lockViewAndDisplayIndicator;
-(void)unlockViewAndStopIndicator;
@end
