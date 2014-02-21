//
//  UserVerificationPage.h
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserVerificationPage : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) BOOL isForceVerify;
@property (nonatomic, assign) BOOL isPopOver;

@property (weak, nonatomic) IBOutlet UIView *normalVerifyView;
@property (weak, nonatomic) IBOutlet UIWebView *normalVerifyWebView;

@property (weak, nonatomic) IBOutlet UIView *forceVerifyView;
@property (weak, nonatomic) IBOutlet UIWebView *forceVerifyWebView;

@property (weak, nonatomic) IBOutlet UIView *failedPopupView;
@property (weak, nonatomic) IBOutlet UIWebView *failedPopupWebView;

@property (weak, nonatomic) IBOutlet UIView *successPopupView;
@property (weak, nonatomic) IBOutlet UIWebView *successPopupWebView;

@end