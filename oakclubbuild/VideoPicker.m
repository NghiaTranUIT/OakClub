//
//  VideoPicker.m
//  OakClub
//
//  Created by Salm on 11/9/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VideoPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoPicker() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation VideoPicker
UIViewController *parentWindow;
id<VideoPickerDelegate> delegate;

-(id)initWithParentWindow:(UIViewController *)_parentWindow andDelegate:(id<VideoPickerDelegate>)_delegate
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
    picker.mediaTypes = @[(NSString*)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [parentWindow presentModalViewController:picker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    if (delegate)
    {
        [delegate receiveVideo:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    if (delegate)
    {
        [delegate receiveVideo:[info objectForKey:UIImagePickerControllerReferenceURL]];
    }
}
@end