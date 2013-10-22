//
//  PickPhotoFromGarelly.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PickPhotoFromGarelly.h"


@interface PickerDelegate : NSObject
@end

@implementation PickerDelegate

@end

@interface PickPhotoFromGarelly() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation PickPhotoFromGarelly
UIViewController *parentWindow;
id<PickPhotoFromGarellyDelegate> delegate;

-(id)initWithParentWindow:(UIViewController *)_parentWindow andDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate
{
    if (self = [super init])
    {
        parentWindow = _parentWindow;
        delegate = _delegate;
    }
    
    return self;
}

-(void)showPicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [parentWindow presentModalViewController:picker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    if (delegate)
    {
        [delegate receiveImage:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    if (delegate)
    {
        [delegate receiveImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }
}
@end