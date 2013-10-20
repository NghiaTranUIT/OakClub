//
//  VCVisitor.h
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewDelegateMultipleSection.h"
#import "UIGridViewMultipleSection.h"
#import "UIGridViewCellMultipleSection.h"
#import "Profile.h"
#import "Cell.h"
#import "ViewCellMyLink.h"
#import "Define.h"
#import "AFHTTPClient+OakClub.h"
#import "VCProfile.h"
@interface VCVisitor : UIViewController
@property (weak, nonatomic) IBOutlet UIGridViewMultipleSection *gv_Visitors;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarControll;

@end
