//
//  HangoutSetting.h
//  OakClub
//
//  Created by VanLuu on 6/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSliderPopover.h"
#import "ListForChoose.h"

@interface HangoutSetting : UITableViewController<UITableViewDelegate,ListForChooseDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet NYSliderPopover *sliderRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRange;
@property (weak, nonatomic) UIPickerView *pickerAge;
@property (weak, nonatomic) IBOutlet UISwitch *switcherGPS;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeTitle;
@property (weak, nonatomic) IBOutlet UILabel *btnAdvanced;
@property (weak, nonatomic) IBOutlet UILabel *lblNearByTitle;


@end
