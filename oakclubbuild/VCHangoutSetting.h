//
//  VCHangoutSetting.h
//  oakclubbuild
//
//  Created by VanLuu on 4/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSliderPopover.h"
#import "ListForChoose.h"

@interface VCHangoutSetting : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, ListForChooseDelegate>{
    NSArray *cityOptions;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonMakeNewFriendsOption;

@property (weak, nonatomic) IBOutlet UIButton *buttonChatOption;
@property (weak, nonatomic) IBOutlet UIButton *buttonDateOption;

@property (weak, nonatomic) IBOutlet UIButton *wantToSee_Newpeople;
@property (weak, nonatomic) IBOutlet UIButton *wantToSee_FriendsOfFriends;
@property (weak, nonatomic) IBOutlet UIButton *wantToSee_Friend;

@property (weak, nonatomic) IBOutlet UIButton *withWho_Guys;
@property (weak, nonatomic) IBOutlet UIButton *withWho_Girls;

@property (weak, nonatomic) IBOutlet UIButton *buttonAgeAround;
@property (weak, nonatomic) IBOutlet UIButton *buttonLocation;



@property (weak, nonatomic) IBOutlet UIPickerView *pickerCity;
@property (nonatomic, retain) NSArray *cityOptions;

@property (weak, nonatomic) IBOutlet UILabel *labelRangValue;
@property (weak, nonatomic) IBOutlet NYSliderPopover *sliderRange;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIViewController *pickerView;


- (IBAction)btnAgeAround:(id)sender;
- (IBAction)onTouchChooseCity:(id)sender;
@end
