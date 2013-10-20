//
//  VCMutualMatch.h
//  OakClub
//
//  Created by VanLuu on 10/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewDelegateMultipleSection.h"
#import "UIGridViewMultipleSection.h"
#import "UIGridViewCellMultipleSection.h"
#import "Profile.h"
#import "Cell.h"
#import "ViewCellMyLink.h"
#import "VCProfile.h"

@interface VCMutualMatch : UIViewController<UIGridViewDelegateMultipleSection>
@property (weak, nonatomic) IBOutlet UIGridViewMultipleSection *gridView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end
