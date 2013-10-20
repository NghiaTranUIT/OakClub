//
//  VCSnapshotSetting.h
//  oakclubbuild
//
//  Created by VanLuu on 5/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient+OakClub.h"
#import "Define.h"
#import "Location.h"
#import "NYSliderPopover.h"
#import "ListForChoose.h"
@interface VCSnapshotSetting : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, ListForChooseDelegate>{
    AFHTTPClient *request;
    NSArray *cityOptions;
    NSArray *ageOptions;
    BOOL showCityPicker;
    int fromAge;
    int toAge;
    int i_range;
    Location *s_location;
    NSMutableArray *arr_BloclList;
    NSMutableArray *arr_PriorityList;
}
@property (nonatomic, retain) NSArray *cityOptions;
@property NYSliderPopover *rangeSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnCity;
@property (weak, nonatomic) IBOutlet UIButton *btnAgeAround;
@property (nonatomic, retain) NSArray *ageOptions;
- (IBAction)pressedMakeNewFriend:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMakeNewFriend;
@property (weak, nonatomic) IBOutlet UIButton *rbnChat;
@property (weak, nonatomic) IBOutlet UIButton *rbnDate;
@property (weak, nonatomic) IBOutlet UIButton *chbNewPeople;
@property (weak, nonatomic) IBOutlet UIButton *chbFriendsOfFriends;
@property (weak, nonatomic) IBOutlet UIButton *chbGuys;
@property (weak, nonatomic) IBOutlet UIButton *chbGirls;
@property (weak, nonatomic) IBOutlet UIButton *chbInterests;
@property (weak, nonatomic) IBOutlet UIButton *chbLikes;
@property (weak, nonatomic) IBOutlet UIButton *chbwork;
@property (weak, nonatomic) IBOutlet UIButton *chbSchool;
@property (weak, nonatomic) IBOutlet UIButton *rbnShowMeet;
@property (weak, nonatomic) IBOutlet UIButton *rbnShowFriendMeet;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerCity;
- (IBAction)btnAgeAround:(id)sender;
- (IBAction)onTouchChooseCity:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chbFriend;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet NYSliderPopover *sliderRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRange;
@property (strong, nonatomic) IBOutlet UIViewController *pickerView;
@property (weak, nonatomic) IBOutlet UITableView *tbSnapshotEdit;
@end
