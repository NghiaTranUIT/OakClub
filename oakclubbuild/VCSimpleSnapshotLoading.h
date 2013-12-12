//
//  VCSimpleSnapshotLoading.h
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCSimpleSnapshotLoading : UIViewController
-(void) setTypeOfAlert:(int)type andAnim:(UIImageView*)imgAnim;
-(int)typeOfAlert;
-(void)setTypeOfAlert:(int)type;
@end
