//
//  VCMyProfile.h
//  oakclubbuild
//
//  Created by VanLuu on 5/7/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListForChoose.h"
#import "NavBarOakClub.h"
#import "EditText.h"
#import <CoreLocation/CoreLocation.h>

@interface VCMyProfile : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, ListForChooseDelegate,EditTextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *rbnMale;
@property (weak, nonatomic) IBOutlet UIButton *rbnFemale;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerWeight;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnRelationShip;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnEthnicity;
@property (weak, nonatomic) IBOutlet UIButton *btnLanguage;
@property (weak, nonatomic) IBOutlet UIButton *btnWork;
@property (weak, nonatomic) IBOutlet UITextField *textfieldSchool;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *textFieldHeight;
@property (weak, nonatomic) IBOutlet UITextField *textFieldWeight;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UILabel *labelAge;
@property (weak, nonatomic) IBOutlet UILabel *labelPurposeSearch;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIButton *btnBirthdate;
@property (weak, nonatomic) IBOutlet UITextView *textviewAbout;
@property (strong, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (strong, nonatomic) UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UITableView *tbEditProfile;

-(void)saveSettingWithWarning:(BOOL)warning;
-(void)setDefaultEditProfile:(Profile*)profile;
@end

@interface PickingViewController : UIViewController

@end
