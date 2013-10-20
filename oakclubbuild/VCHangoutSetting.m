//
//  VCHangoutSetting.m
//  oakclubbuild
//
//  Created by VanLuu on 4/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//
#import "Define.h"
#import "VCHangoutSetting.h"
#import "GroupButtons.h"
#import "AppDelegate.h"


@interface VCHangoutSetting ()

@end

@implementation VCHangoutSetting

@synthesize cityOptions, pickerCity;

@synthesize buttonMakeNewFriendsOption;
@synthesize buttonChatOption;
@synthesize buttonDateOption;

@synthesize wantToSee_Newpeople;
@synthesize wantToSee_FriendsOfFriends;
@synthesize wantToSee_Friend;

@synthesize withWho_Guys;
@synthesize withWho_Girls;

@synthesize buttonAgeAround;
@synthesize buttonLocation;

@synthesize scrollview;
@synthesize sliderRange;
@synthesize labelRangValue;
@synthesize pickerView;

GroupButtons* purposeOfSearch;
GroupButtons* genderOfSearch;
GroupButtons* interestedIn;
ProfileSetting* accountSetting;

NSMutableArray *aPurposesSearch;
NSMutableArray *aGenderSearch;

BOOL showCityPicker;

NSArray *cityOptions;
NSArray *ageOptions;

int fromAge, toAge;

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        Location *temp = [self.appDelegate accountSetting].location;
        accountSetting = [self.appDelegate accountSetting];
    }
    return self;
}

- (IBAction)onTapSaveButton:(id)sender {
    [self saveSetting];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)saveSetting
{
    accountSetting.purpose_of_search = [aPurposesSearch objectAtIndex:[purposeOfSearch getSelectedIndex]];
    
    int index;
    bool checkedMale, checkedFemale;
    checkedMale = [genderOfSearch getSelectedAtIndex:0];
    checkedFemale = [genderOfSearch getSelectedAtIndex:1];
    
    if( checkedMale==TRUE && checkedFemale == TRUE )
        index = 2;
    else
    {
        if(checkedMale)
            index = 0;
        
        if(checkedFemale)
            index = 1;
        
        if(!checkedMale && !checkedFemale)
            index = 3;
    }

    accountSetting.gender_of_search = [aGenderSearch objectAtIndex:index];
    
    accountSetting.interested_new_people = [interestedIn getSelectedAtIndex:0];
    accountSetting.interested_friend_of_friends = [interestedIn getSelectedAtIndex:2];
    accountSetting.interested_friends = [interestedIn getSelectedAtIndex:1];
    
    accountSetting.age_from = fromAge;
    accountSetting.age_to = toAge;
    
//    accountSetting.location_name = [buttonLocation currentTitle];
    
    accountSetting.range = sliderRange.value * 100;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UINavigationController* activeVC = [[self appDelegate] activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if( [vc isKindOfClass:[VCHangOut class]] )
    {
        [(VCHangOut*)vc initDataNearByTableView];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
    
    
    aPurposesSearch = [NSMutableArray arrayWithObjects:value_MakeFriend, value_Chat, value_Date, nil];
     aGenderSearch = [NSMutableArray arrayWithObjects:value_Male, value_Female, value_All, @"none", nil];

    [super viewDidLoad];
    
    NSMutableArray *options = [NSMutableArray array];
    [options addObject:@"Ho Chi Minh"];
    [options addObject:@"Ha Noi"];
    [options addObject:@"Hai Phong"];
    [options addObject:@"Da Nang"];
    [options addObject:@"Hue"];
    self.cityOptions = options;
    
    purposeOfSearch = [[GroupButtons alloc] initWithMultipleChoice:FALSE];
    [purposeOfSearch addButton:buttonMakeNewFriendsOption atIndex:0];
    [purposeOfSearch addButton:buttonChatOption atIndex:1];
    [purposeOfSearch addButton:buttonDateOption atIndex:2];
    
    NSInteger index = [aPurposesSearch indexOfObject:accountSetting.purpose_of_search];
    
    [purposeOfSearch setSelectedIndex:index];
    
    genderOfSearch = [[GroupButtons alloc] initWithMultipleChoice:TRUE];
    [genderOfSearch addButton:withWho_Guys atIndex:0];
    [genderOfSearch addButton:withWho_Girls atIndex:1];
    
    index = [aGenderSearch indexOfObject:accountSetting.gender_of_search];
    
    bool checkedMale, checkedFemale;
    
    checkedMale = (index == 2 || index == 0) ? TRUE : FALSE;
    checkedFemale = (index == 2 || index == 1) ? TRUE : FALSE;
    
    [genderOfSearch setSelected:checkedMale atIndex:0];
    [genderOfSearch setSelected:checkedFemale atIndex:1];
    
    interestedIn = [[GroupButtons alloc] initWithMultipleChoice:TRUE];
    [interestedIn addButton:wantToSee_Newpeople atIndex:0];
    [interestedIn addButton:wantToSee_Friend atIndex:1];
    [interestedIn addButton:wantToSee_FriendsOfFriends atIndex:2];

    
    [interestedIn setSelected:accountSetting.interested_new_people atIndex:0];
    [interestedIn setSelected:accountSetting.interested_friends atIndex:1];
    [interestedIn setSelected:accountSetting.interested_friend_of_friends atIndex:2];
    
    
    fromAge = accountSetting.age_from;
    toAge = accountSetting.age_to;
    
    [buttonAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
    
    [buttonLocation setTitle:accountSetting.location.name forState:UIControlStateNormal];
    
    [sliderRange setValue:accountSetting.range/100];
    [labelRangValue setText:[self getRangeValue:accountSetting.range]];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [pickerCity selectRow:2 inComponent:0 animated:NO];
    [buttonLocation setTitle:accountSetting.location.name forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Picker DataSource/Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if(!showCityPicker)
        return 2;
    else
        return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(!showCityPicker){
        return [ageOptions count];
    }
    else{
        return [cityOptions count];
    }
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    if(!showCityPicker)
        return 70.0;
    else
        return 300.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(!showCityPicker){
        return [ageOptions objectAtIndex:row];
    }
    else{
        return [cityOptions objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //    NSDictionary *optionForRow = [accuracyOptions objectAtIndex:row];
    //    [setupInfo setObject:[optionForRow objectForKey:kAccuracyValueKey] forKey:kSetupInfoKeyAccuracy];
    if(!showCityPicker){
        NSLog(@" select age is %@ OF COMPONENT %d",[ageOptions objectAtIndex:row],component);
        if(component == 0)
            fromAge = [[ageOptions objectAtIndex:row] integerValue];
        else
            toAge = [[ageOptions objectAtIndex:row] integerValue];
        [buttonAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
        //        if([ageOptions objectAtIndex:row] < [ageOptions objectAtIndex:[ageOptions count]-1])
    }
    else{
        NSLog(@" select city is %@ OF COMPONENT %d",[cityOptions objectAtIndex:row],component);
        [buttonLocation setTitle:[NSString stringWithFormat:@"%@ city",[cityOptions objectAtIndex:row]] forState:UIControlStateNormal];
    }
}

-(void) initCityList{
    showCityPicker = YES;
    cityOptions =  @[@"Ha Noi",@"Hai Phong",@"Ho Chi Minh", @"Da Nang", @"Hue"];//options;
    
    int index = [cityOptions indexOfObject:buttonLocation.currentTitle];
    if (index == NSNotFound) {
        index = 0;
    }
    [pickerCity selectRow:index inComponent:0 animated:NO];
    [pickerCity reloadAllComponents];
}

-(void) initAgeList{
    showCityPicker = NO;
    NSMutableArray *ages = [NSMutableArray array];
    for(int i =16; i < 46; i++){
        [ages addObject:[NSString stringWithFormat:@"%d",i] ];
    }
    ageOptions =  ages;
    [pickerCity reloadAllComponents];
    [pickerCity selectRow:(fromAge - 16) inComponent:0 animated:NO];
    [pickerCity selectRow:(toAge - 16) inComponent:1 animated:NO];
}


- (IBAction)btnAgeAround:(id)sender
{
    [buttonAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old", fromAge, toAge] forState:UIControlStateNormal];
     [self initAgeList];
    CGPoint bottomOffset = CGPointMake(0, wantToSee_Newpeople.frame.origin.y + 10);
    [scrollview setContentOffset:bottomOffset animated:YES];
    [self.view addSubview:pickerView.view];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(![touch.view isKindOfClass:[UIPickerView class]] ){
        [touch.view removeFromSuperview];
    }
}
- (IBAction)onTouchChooseCity:(id)sender {
    
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
            accountSetting.location = selected.s_location;
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3] animated:YES];
            break;
        case LISTTYPE_COUNTRY:{
            ListForChoose *locationSubview = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
            [locationSubview setCityListWithCountryCode:selected.s_location.countryCode];
            locationSubview.delegate = self;
            [self.navigationController pushViewController:locationSubview animated:YES];
            break;
        }
        default:
            break;
    }
}
//-(Profile*)setDefaultValue:(ListForChoose *)uvcList{
//    Profile* _pro = [Profile alloc];
//    _pro.s_location = accountSetting.location;
//    return _pro;
//}

- (void)viewDidUnload {
    [self setPickerCity:nil];
    [self setButtonChatOption:nil];
    [self setButtonDateOption:nil];
    [self setWantToSee_Newpeople:nil];
    [self setWantToSee_FriendsOfFriends:nil];
    [self setWithWho_Guys:nil];
    [self setWithWho_Girls:nil];
    [self setButtonAgeAround:nil];
    [self setButtonLocation:nil];
    [self setButtonMakeNewFriendsOption:nil];
    [self setSliderRange:nil];
    [self setLabelRangValue:nil];
    [self setWantToSee_Friend:nil];
    [self setPickerView:nil];
    [super viewDidUnload];
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateSliderPopoverText];
}

- (IBAction)touchDownOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = NO;
}

- (IBAction)touchUpOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = YES;
}

-(NSString*)getRangeValue:(NSUInteger)value
{
    NSString* sRange;
    if(value < 600)
        sRange = [NSString stringWithFormat:@"%dkm", value];
    else
        if(value < 700)
            sRange = accountSetting.location.countryCode;
        else
            sRange = @"World";
    return sRange;
}

- (void)updateSliderPopoverText
{
    double value = self.sliderRange.value;
    int intValue = round(value);
    [self.sliderRange setValue:intValue];
    
    NSString* sRange = [self getRangeValue:intValue * 100];
    self.sliderRange.popover.textLabel.text = sRange;
    labelRangValue.text = sRange;
}

- (IBAction)onTapClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
