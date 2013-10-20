//
//  SnapshotSetting.h
//  OakClub
//
//  Created by VanLuu on 6/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSliderPopover.h"
#import "ListForChoose.h"
@interface SnapshotSetting : UITableViewController<UITableViewDelegate,ListForChooseDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet NYSliderPopover *sliderRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRange;
@property (weak, nonatomic) UIPickerView *pickerAge;
@property (weak, nonatomic) IBOutlet UILabel *btnAdvance;

@end
