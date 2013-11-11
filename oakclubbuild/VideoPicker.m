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
        [VideoPicker loadImageFromAssertByUrl:[info objectForKey:UIImagePickerControllerReferenceURL] completion:^(NSData * videoData) {
            [delegate receiveVideo:videoData];
        }];
        
    }
}

+(void) loadImageFromAssertByUrl:(NSURL *)url completion:(void (^)(NSData*)) completion
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