//
//  ViewCellMyLink.h
//  oakclubbuild
//
//  Created by hoangle on 4/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UIGridViewCellMultipleSection.h"
#import "Profile.h"

@interface ViewCellMyLink : UIGridViewCellMultipleSection
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *checkedView;
@property (assign) BOOL isPlus;
@property (assign) BOOL isMinus;
@property (assign) Profile *profile;
@end
