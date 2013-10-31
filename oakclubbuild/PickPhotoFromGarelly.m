//
//  PickPhotoFromGarelly.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PickPhotoFromGarelly.h"
#import <AssetsLibrary/AssetsLibrary.h>


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
    picker = nil;
    if (delegate)
    {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!img)
        {
            img = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        if (!img)
        {
            [PickPhotoFromGarelly loadImageFromAssertByUrl:[info objectForKey:UIImagePickerControllerReferenceURL] completion:^(UIImage *_img) {
                [delegate receiveImage:_img];
            }];
        }
        else
        {
            [delegate receiveImage:img];
        }
    }
}

+(void) loadImageFromAssertByUrl:(NSURL *)url completion:(void (^)(UIImage*)) completion
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        UIImage* img = [UIImage imageWithData:data];
        completion(img);
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
}
@end