//
//  PickPhotoFromGarelly.h
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PickPhotoFromGarellyDelegate
-(void)receiveImageData:(NSData*)data;
@end

@interface PickPhotoFromGarelly : NSObject
-(id)initWithParentWindow:(UIViewController *)_parentWindow andDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate;
-(void)showPicker;
@end