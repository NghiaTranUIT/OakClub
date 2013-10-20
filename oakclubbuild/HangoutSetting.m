//
//  HangoutSetting.m
//  OakClub
//
//  Created by VanLuu on 6/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "HangoutSetting.h"
#import "SettingObject.h"
#import "AppDelegate.h"
#import "UITableView+Custom.h"
#import "UIViewController+Custom.h"
@interface HangoutSetting (){
//    SettingObject* accountSetting;
    NSArray *optionList;
    AFHTTPClient *request;
    int fromAge;
    int toAge;
    int i_range;
    NSArray *ageOptions;
    UIPickerView* picker;
}
@property (nonatomic) NSUInteger hereTo;
@end

@implementation HangoutSetting
bool isPickerShowed= false;
UITapGestureRecognizer *tap;
ProfileSetting* hangoutSetting;
@synthesize lblRange,pickerAge, switcherGPS, lblRangeTitle, btnAdvanced,lblNearByTitle;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customBackButtonBarItem];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tap];
    UIImage *sliderBarImg = [UIImage imageNamed:@"NearNowSettiing_line_location.png"];
    [self.sliderRange setThumbImage:[UIImage imageNamed:@"NearNowSetting_icon_here.png"] forState:UIControlStateNormal];
    [self.sliderRange setThumbImage:[UIImage imageNamed:@"NearNowSetting_icon_here.png"] forState:UIControlStateHighlighted];
    [self.sliderRange setMinimumTrackImage:sliderBarImg forState:UIControlStateNormal];
    [self.sliderRange setMaximumTrackImage:sliderBarImg forState:UIControlStateNormal];
    
    
    switcherGPS.on = [[NSUserDefaults standardUserDefaults] boolForKey:key_isUseGPS];
    hangoutSetting = [self.appDelegate accountSetting];
    self.hereTo = [self loadHereTo:hangoutSetting.purpose_of_search];
    optionList = [[NSArray alloc] initWithObjects:@"DateCell",@"MakeFriendsCell",@"ChatCell",@"NewPeopleCell",@"FoFCell",@"FriendsCell",@"GuysCell",@"GirlsCell",@"AgeCell",@"WhereCell",@"", nil];
    fromAge = hangoutSetting.age_from;
    toAge = hangoutSetting.age_to;
    i_range = hangoutSetting.range;
    [self.sliderRange setValue:i_range/100];
    lblRange.text = [self getRangeValue:i_range];
    [lblRange setFont:FONT_NOKIA(17.0)];
    [lblRangeTitle setFont:FONT_NOKIA(17.0)];
    [lblNearByTitle setFont:FONT_NOKIA(17.0)];
    [btnAdvanced setFont:FONT_NOKIA(17.0)];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}
-(void)viewDidAppear:(BOOL)animated{
    [self initSaveButton];
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchDownOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = NO;
}

- (IBAction)touchUpOnSlider:(id)sender {
    [self appDelegate].rootVC.recognizesPanningOnFrontView = YES;
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateSliderPopoverText];
}
- (void)updateSliderPopoverText
{
    double value = self.sliderRange.value;
    int intValue = round(value);
    [self.sliderRange setValue:intValue];
    hangoutSetting.range = intValue * 100;
    NSString* sRange = [self getRangeValue:hangoutSetting.range];
    self.sliderRange.popover.textLabel.text = sRange;
    lblRange.text = sRange;
}

-(NSString*)getRangeValue:(NSUInteger)value
{
    NSString* sRange;
    if(value < 600)
        sRange = [NSString stringWithFormat:@"%d km", value];
    else
        if(value < 700)
            sRange = @"Country";//accountSetting.location.countryCode;
        else
            sRange = @"World";
    return sRange;
}
- (int) loadHereTo:(NSString*)value{
    if(value!= NULL && [value isEqualToString:value_MakeFriend]){
        return 1;
    }
    else{
        if([value isEqualToString:value_Chat]){
            return 2;
        }
        else{
            return 0;
        }
    }
}
-(void)initSaveButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
    self.navigationItem.title = @"Near Now Setting";
}
-(void)saveSetting{
    if(fromAge > toAge){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"FromAge Must Be Smaller Than ToAge"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    hangoutSetting.age_from = fromAge;
    hangoutSetting.age_to = toAge;
    
    hangoutSetting.range = self.sliderRange.value * 100;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UINavigationController* activeVC = [[self appDelegate] activeViewController];
    UIViewController* vc = [activeVC.viewControllers objectAtIndex:0];
    if( [vc isKindOfClass:[VCHangOut class]] )
    {
        [(VCHangOut*)vc initDataNearByTableView];
    }
}
#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    UIImageView *headerImage = [[UIImageView alloc] init]; //set your image/
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 205, 20)];//set as you need
    headerLbl.backgroundColor = [UIColor clearColor];
    UIFont *newfont = FONT_NOKIA(20.0);
    [headerLbl setFont:newfont];
    switch (section) {
        case 0:
            headerLbl.text = @"I'm here to";
            break;
        case 1:
            headerLbl.text = @"I want to see";
            break;
        case 2:
            headerLbl.text = @"With who";
            break;
        case 3:
            if(!isPickerShowed)
                headerLbl.text = @"Where";
            break;
        default:
            headerLbl.text = nil;
            break;
    }
    [headerImage addSubview:headerLbl];
    
    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);

    [headerView addSubview:headerImage];
    
    return headerView;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section)
    {
        case 0:
            if (row == self.hereTo)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        case 1:
            if (row == 0 && hangoutSetting.interested_new_people)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && hangoutSetting.interested_friend_of_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 2 && hangoutSetting.interested_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            if (row == 0 && ([hangoutSetting.gender_of_search isEqualToString:value_Male] || [hangoutSetting.gender_of_search isEqualToString:value_All]))
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && ([hangoutSetting.gender_of_search isEqualToString:value_Female] || [hangoutSetting.gender_of_search isEqualToString:value_All]) )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if(row == 2){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d-%d year old",fromAge,toAge];
            }
            break;
        case 3:
            if(row == 1){
                if(switcherGPS.on){
                    cell.userInteractionEnabled = NO;
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                }
                else{
                    cell.userInteractionEnabled = YES;
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:(56/255.0) green:(84/255.0) blue:(135/255.0) alpha:1];
                }
                cell.detailTextLabel.text = hangoutSetting.location.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            break;
    }
    [cell.detailTextLabel setFont: FONT_NOKIA(17.0)];
    [cell.textLabel setFont: FONT_NOKIA(17.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (section)
    {
        case 3:
            if (row==1) {
                [self gotoChooseCity];
            }
            break;
        case 0:
            self.hereTo = row;
            switch (row) {
                case 0:
                    hangoutSetting.purpose_of_search = value_Date;
                    break;
                case 1:
                    hangoutSetting.purpose_of_search = value_MakeFriend;
                    break;
                case 2:
                    hangoutSetting.purpose_of_search = value_Chat;
                    break;
                default:
                    break;
            }
            

            break;
        case 1:
            if(row == 0){
                hangoutSetting.interested_new_people = !hangoutSetting.interested_new_people;
            }
            if(row == 1){
                hangoutSetting.interested_friend_of_friends = !hangoutSetting.interested_friend_of_friends;
            }
            if(row == 2){
                hangoutSetting.interested_friends = !hangoutSetting.interested_friends;
            }
            break;
        case 2:
            if(row == 0){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([hangoutSetting.gender_of_search isEqualToString:value_Male])
                        hangoutSetting.gender_of_search = @"none";
                    else
                        hangoutSetting.gender_of_search = value_Female;
                }
                else{
                    if([hangoutSetting.gender_of_search isEqualToString:value_Female])
                        hangoutSetting.gender_of_search =value_All;
                    else
                        hangoutSetting.gender_of_search = value_Male;
                }
                
            }
            if(row == 1){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([hangoutSetting.gender_of_search isEqualToString:value_Female])
                        hangoutSetting.gender_of_search = @"none";
                    else
                        hangoutSetting.gender_of_search = value_Male;
                }
                else{
                    if([hangoutSetting.gender_of_search isEqualToString:value_Male])
                        hangoutSetting.gender_of_search =value_All;
                    else
                        hangoutSetting.gender_of_search = value_Female;
                }
            }
            if(row == 2){
                [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
                
                if(isPickerShowed){
                    [picker removeFromSuperview];
                }
                else{
                    
                    picker = [[UIPickerView alloc] init];
                    picker.delegate = self;
                    picker.dataSource =self;
                    picker.showsSelectionIndicator = YES;
                    picker.frame = CGRectMake(0, cell.frame.origin.y + 52, 320, 200);
//                    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, picker.frame.size.width, 30)];
//                    toolbar.barStyle = UIBarStyleBlackOpaque;
//                    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                    
//                    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: self action: @selector(donePressed)];
//                    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//                    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
                    
//                    [picker addSubview: toolbar];
                    [self.view addSubview: picker];
//                    [self.view sendSubviewToBack:self.tableView];
//                    [self.view bringSubviewToFront:picker];
                    [self initAgeList];
                }
                isPickerShowed = !isPickerShowed;
//                [self.tableView.tableHeaderView setHidden:isPickerShowed];// setSectionHeaderHeight:0];
                [self.tableView reloadData];
            }
            break;
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setSliderRange:nil];
    [self setLblRange:nil];
    [self setPickerAge:nil];
    [self setSwitcherGPS:nil];
    [self setLblRangeTitle:nil];
    [self setBtnAdvanced:nil];
    [self setLblNearByTitle:nil];
    [super viewDidUnload];
}

- (void)gotoChooseCity {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    SettingObject* selectedValue = [uvcList getSettingValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
        {
            hangoutSetting.location = selected.s_location;
            [self.tableView reloadData];
            break;
        }
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

-(NSString*) BoolToString:(BOOL)value{
    if(value)
        return value_TRUE;
    else
        return value_FALSE;
}



#pragma mark Picker DataSource/Delegate
-(void) initAgeList{
    //    showCityPicker = NO;
    NSMutableArray *ages = [NSMutableArray array];
    for(int i =MIN_AGE  ; i <= MAX_AGE; i++){
        [ages addObject:[NSString stringWithFormat:@"%d",i] ];
    }
    ageOptions =  ages;
    [picker reloadAllComponents];
    [picker selectRow:(fromAge - 16) inComponent:0 animated:NO];
    [picker selectRow:(toAge - 16) inComponent:1 animated:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [ageOptions count];
}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//
//        return 70.0;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [ageOptions objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@" select age is %@ OF COMPONENT %d",[ageOptions objectAtIndex:row],component);
    if(component == 0)
        fromAge = [[ageOptions objectAtIndex:row] integerValue];
    else
        toAge = [[ageOptions objectAtIndex:row] integerValue];
    //    [self.tableView reloadSections:[[NSIndexPath alloc] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    //    [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
    
}

- (void) singleTapGestureCaptured{
    NSLog(@"touch on table view");
    UIView* lastView = [[self.view subviews] objectAtIndex:[[self.view subviews] count]-1];
    if([lastView isKindOfClass:[UIPickerView class]] )
        [picker removeFromSuperview];
}

- (IBAction)onSwitchNearbyGPS:(id)sender {
    UISwitch *switcher= (UISwitch*)sender;
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]];
    BOOL result=switcher.on;
    NSUserDefaults *defaultUser =[NSUserDefaults standardUserDefaults];
    [defaultUser setBool:result forKey:key_isUseGPS];
    [defaultUser synchronize];
    if(result){
        cell.userInteractionEnabled = NO;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else{
        cell.userInteractionEnabled = YES;
          cell.detailTextLabel.textColor = COLOR_BLUE_CELLTEXT;
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    [self.tableView reloadData];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [picker removeFromSuperview];
    isPickerShowed = NO;
    [self.tableView reloadData];
}
- (void)dismissKeyboard {
    if (isPickerShowed){
        [[self.tableView.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:isPickerShowed];
        [picker removeFromSuperview];
        isPickerShowed = NO;
        [self.tableView reloadData];
    }
    
}
@end
