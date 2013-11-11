//
//  VideoPicker.h
//  OakClub
//
//  Created by Salm on 11/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoPickerDelegate
-(void)receiveVideo:(NSData *)video;
@end

@interface VideoPicker : NSObject
-(id)initWithParentWindow:(UIViewController *)_parentWindow andDelegate:(id<VideoPickerDelegate>)_delegate;
-(void)showPicker;
@end