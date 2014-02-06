//
//  PickPhotoFromGarelly.m
//  OakClub
//
//  Created by Salm on 10/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PickPhotoFromGarelly.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PickPhotoFromGarelly() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation PickPhotoFromGarelly
{
    UIViewController *parentWindow;
    id<PickPhotoFromGarellyDelegate> delegate;
}

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
//    picker.mediaTypes = @[(NSString*)kUTTypeMovie];
    [parentWindow presentModalViewController:picker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    if (delegate)
    {
        [delegate receiveImageData:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    if (delegate)
    {
        [PickPhotoFromGarelly loadImageFromAssertByUrl:[info objectForKey:UIImagePickerControllerReferenceURL] completion:^(NSData *rawData) {
            [delegate receiveImageData:rawData];
        }];
    }
}

+(void) loadImageFromAssertByUrl:(NSURL *)url completion:(void (^)(NSData *))completion
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        completion(data);
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
}
@end