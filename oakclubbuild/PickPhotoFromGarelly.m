//
//  PickPhotoFromGarelly.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PickPhotoFromGarelly.h"


@interface PickerDelegate : NSObject <UIImagePickerControllerDelegate>
-(id)initWithDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate;
@end

@implementation PickerDelegate
id<PickPhotoFromGarellyDelegate> delegate;

-(id)initWithDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate
{
    if (self = [super init])
    {
        delegate = _delegate;
    }
    
    return self;
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
        NSLog(@"Pick item: %@", info);
    }
}

@end

@implementation PickPhotoFromGarelly : NSObject
UIViewController *parentWindow;

-(id)initWithParentWindow:(UIViewController *)_parentWindow
{
    if (self = [super init])
    {
        parentWindow = _parentWindow;
    }
    
    return self;
}

-(void)showPickerWithDelegate:(id<PickPhotoFromGarellyDelegate>)_delegate
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id) [[PickerDelegate alloc] initWithDelegate:_delegate];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [parentWindow presentModalViewController:picker animated:YES];
}
@end