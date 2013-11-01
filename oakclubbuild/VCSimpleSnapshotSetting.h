//
//  VCSimpleSnapshotSetting.h
//  OakClub
//
//  Created by VanLuu on 10/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NYSliderPopover.h"
#import "ListForChoose.h"
@interface VCSimpleSnapshotSetting : UITableViewController<UITableViewDelegate,ListForChooseDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property UILabel *lblRange;
@property (weak, nonatomic) UIPickerView *pickerAge;
@property (weak, nonatomic) IBOutlet UILabel *btnAdvance;

@end