//
//  UpdateProfileViewController.h
//  OakClub
//
//  Created by Salm on 11/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateProfileViewController : UIViewController
-(void)updateProfile;
@end

@protocol UIViewControllerBirthdayPickerDelegate <NSObject>
-(void)dateChanged:(NSDate *)date;
@end

@interface UIViewControllerBirthdayPicker : UIViewController
@property (strong, nonatomic) NSDate *currentDay;
@property (weak, nonatomic) id<UIViewControllerBirthdayPickerDelegate> delegate;
@end