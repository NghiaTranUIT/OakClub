//
//  PreferencesSettings.h
//  OakClub
//
//  Created by VanLuu on 7/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListForChoose.h"
@interface PreferencesSettings : UITableViewController<ListForChooseDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblFinish;

@end
