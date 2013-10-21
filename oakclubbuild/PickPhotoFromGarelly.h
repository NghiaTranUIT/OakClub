//
//  PickPhotoFromGarelly.h
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PickPhotoFromGarellyDelegate
-(void)receiveImage:(UIImage *)image;
@end

@interface PickPhotoFromGarelly : NSObject
-(id)initWithParentWindow:(UIWindow *)parentWindow;
-(void)showPickerWithDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate;
@end