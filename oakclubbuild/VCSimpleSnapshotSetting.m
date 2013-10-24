//
//  SnapshotSetting.m
//  OakClub
//
//  Created by VanLuu on 6/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSimpleSnapshotSetting.h"
#import "SettingObject.h"
#import "AppDelegate.h"
#import "UITableView+Custom.h"
#import "UIViewController+Custom.h"
#import "NSString+Utils.h"
#import "UIView+Localize.h"
#import "AppDelegate.h"
@interface VCSimpleSnapshotSetting (){
    SettingObject* snapshotObj;
    AFHTTPClient *request;
    int fromAge;
    int toAge;
    int i_range;
    NSArray *ageOptions;
    UIPickerView* picker;
    bool isPickerShowing;
}
@property (nonatomic) NSUInteger hereTo;
@end

@implementation VCSimpleSnapshotSetting

UITapGestureRecognizer *tap;
@synthesize lblRange,pickerAge, btnAdvance;

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
//    [self customBackButtonBarItem];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tap];
    
    snapshotObj = [[SettingObject alloc] init];
    [self loadSetting];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
}
-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)viewDidAppear:(BOOL)animated{
    [self initSaveButton];
    isPickerShowing = false;
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
    snapshotObj.range = intValue * 100;
    NSString* sRange = [self getRangeValue:snapshotObj.range];
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
            sRange = @"Country";//snapshotObj.location.countryCode;
        else
            sRange = @"World";
    return sRange;
}

-(void)initSaveButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
//    self.navigationItem.title = @"Snapshot Settings";
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
#pragma mark - Table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount=0;
    switch (section)
    {
        case 0:
            rowCount = 3;
            break;
        case 1:
            rowCount = 3;
            break;
        case 2:
            rowCount = 3;
            break;
        case 3:
            rowCount = 1;
            break;
        case 4:
            rowCount = 2;
            break;
    }
    return rowCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [super tableView:tableView
//                       cellForRowAtIndexPath:indexPath];
    static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:MyIdentifier];
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
            switch (row) {
                case 0:
                    cell.textLabel.text = @"Date";
                    break;
                case 1:
                    cell.textLabel.text = @"Make New Friends";
                    break;
                case 2:
                    cell.textLabel.text = @"Chat";
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            if (row == 0 && snapshotObj.interested_new_people)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && snapshotObj.interested_friend_of_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 2 && snapshotObj.interested_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            switch (row) {
                case 0:
                    cell.textLabel.text = @"New People";
                    break;
                case 1:
                    cell.textLabel.text = @"Friend of Friends";
                    break;
                case 2:
                    cell.textLabel.text = @"Friends";
                    break;
                default:
                    break;
            }
            break;
        case 2:
            if (row == 0 && ([snapshotObj.gender_of_search isEqualToString:value_Male] || [snapshotObj.gender_of_search isEqualToString:value_All]))
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && ([snapshotObj.gender_of_search isEqualToString:value_Female] || [snapshotObj.gender_of_search isEqualToString:value_All]) )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if(row == 2){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d-%d %@",fromAge,toAge,[NSString localizeString:@"year old"]];
            }
            
            switch (row) {
                case 0:
                    cell.textLabel.text = @"Guys";
                    break;
                case 1:
                    cell.textLabel.text = @"Girls";
                    break;
                case 2:
                    cell.textLabel.text = @"Age around";
                    break;
                default:
                    break;
            }
            break;
        case 3:
            if(row == 0){
                cell.detailTextLabel.text = snapshotObj.location.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = @"Where";
            break;
        case 4:
        {
            NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
            if (row == 0) {
                cell.textLabel.text = @"Vietnamese";
                
            }
            if(row == 1){
                cell.textLabel.text = @"English";
            }
            
            if( ([selectedLanguage isEqualToString:value_appLanguage_VI] && row ==0)
               || ([selectedLanguage isEqualToString:value_appLanguage_EN] && row ==1) ){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
    }
    cell.textLabel.text = [NSString localizeString:cell.textLabel.text];
    [cell.detailTextLabel setFont: FONT_NOKIA(17.0)];
    [cell.textLabel setFont: FONT_NOKIA(17.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    return cell;
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
            if(!isPickerShowing)
                headerLbl.text = @"Where";
            break;
        case 4:
            headerLbl.text = @"Language";
            break;
        default:
            headerLbl.text = nil;
            break;
    }
    [headerLbl localizeText];
    [headerImage addSubview:headerLbl];
    
    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
    
    [headerView addSubview:headerImage];
    
    return headerView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (section)
    {
        case 4:{
            AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
            if(row == 0){
                [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_VI forKey:key_appLanguage];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if(row == 1){
                [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_EN forKey:key_appLanguage];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [appDelegate updateLanguageBundle];
            [tableView reloadData];
            [[self navBarOakClub] setHeaderName:[NSString localizeString:@"Setting"]];
            [appDelegate loadDataForList];
            break;
        }
        case 3:
            if (row==0) {
                [self gotoChooseCity];
            }
            break;
        case 0:
            self.hereTo = row;
            switch (row) {
                case 0:
                    snapshotObj.purpose_of_search = value_Date;
                    break;
                case 1:
                    snapshotObj.purpose_of_search = value_MakeFriend;
                    break;
                case 2:
                    snapshotObj.purpose_of_search = value_Chat;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            if(row == 0){
                snapshotObj.interested_new_people = !snapshotObj.interested_new_people;
            }
            if(row == 1){
                snapshotObj.interested_friend_of_friends = !snapshotObj.interested_friend_of_friends;
            }
            if(row == 2){
                snapshotObj.interested_friends = !snapshotObj.interested_friends;
            }
            break;
        case 2:
            if(row == 0){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([snapshotObj.gender_of_search isEqualToString:value_Male])
                        snapshotObj.gender_of_search = @"none";
                    else
                        snapshotObj.gender_of_search = value_Female;
                }
                else{
                    if([snapshotObj.gender_of_search isEqualToString:value_Female])
                        snapshotObj.gender_of_search =value_All;
                    else
                        snapshotObj.gender_of_search = value_Male;
                }
                
            }
            if(row == 1){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([snapshotObj.gender_of_search isEqualToString:value_Female])
                        snapshotObj.gender_of_search = @"none";
                    else
                        snapshotObj.gender_of_search = value_Male;
                }
                else{
                    if([snapshotObj.gender_of_search isEqualToString:value_Male])
                        snapshotObj.gender_of_search =value_All;
                    else
                        snapshotObj.gender_of_search = value_Female;
                }
            }
            if(row == 2){
                //                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
                if(isPickerShowing){
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
                    //                    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: self action: @selector(donePressed)];
                    //                    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                    //                    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
                    //
                    [self initAgeList];
                    //                    [picker addSubview: toolbar];
                    [self.view addSubview: picker];
                    [picker setNeedsDisplay];
                    
                }
                isPickerShowing = !isPickerShowing;
                //                [self.tableView.tableHeaderView setHidden:isPickerShowing];// setSectionHeaderHeight:0];
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
    [self setBtnAdvance:nil];
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
            snapshotObj.location = selected.s_location;
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

- (void) loadSetting{
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getSnapshotSetting parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableDictionary * data= [dict valueForKey:key_data];
        snapshotObj.purpose_of_search = [data valueForKey:key_purpose_of_search];
        self.hereTo = [self loadHereTo:snapshotObj.purpose_of_search];
        snapshotObj.gender_of_search = [data valueForKey:key_gender_of_search];//[Profile parseGender:[data valueForKey:key_gender_of_search]];
        
        fromAge = [[data valueForKey:key_age_from] integerValue];
        toAge= [[data valueForKey:key_age_to] integerValue];
        
        NSMutableDictionary* status_interested_in = [data valueForKey:key_status_interested_in];
        snapshotObj.interested_new_people = [[status_interested_in valueForKey:key_new_people] boolValue];
        snapshotObj.interested_friend_of_friends = [[status_interested_in valueForKey:key_status_fof] boolValue];
        snapshotObj.interested_friends = [[status_interested_in valueForKey:key_friends] boolValue];
        
        i_range = [[data valueForKey:key_range] integerValue];
        
        [self.sliderRange setValue:i_range/100];
        lblRange.text = [self getRangeValue:i_range];
        
        NSMutableDictionary *location = [data valueForKey:key_location];
        snapshotObj.location = [[Location alloc] initWithNSDictionary:location];
        
        // advance settings
        //        [self loadShowFOF:[[data valueForKey:key_show_fof] boolValue]];
        //
        //        [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
        //        [chbInterests setSelected:[[data valueForKey:key_is_interests] boolValue]];
        //        [chbLikes setSelected:[[data valueForKey:key_is_likes] boolValue]];
        //        [chbSchool setSelected:[[data valueForKey:key_is_school] boolValue]];
        //        [chbwork setSelected:[[data valueForKey:key_is_work] boolValue]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
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
    
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
//    NSString * s_isInterest= [self BoolToString:false];
//    NSString * s_isLikes= [self BoolToString:false];
//    NSString * s_isWork= [self BoolToString:false];
//    NSString * s_isSchool= [self BoolToString:false];
    NSString * s_isNewPeople= snapshotObj.interested_new_people?@"1":@"0";
    NSString * s_isFOF= snapshotObj.interested_friend_of_friends?@"1":@"0";
    NSString * s_isFriend= snapshotObj.interested_friends?@"1":@"0";
    NSString *s_hereto = snapshotObj.purpose_of_search;
    NSString *s_gender = snapshotObj.gender_of_search;
    NSString *isMale = ([s_gender isEqualToString:value_All] || [s_gender isEqualToString:value_Male])?@"on":@"off";
    NSString *isFemale = ([s_gender isEqualToString:value_All] || [s_gender isEqualToString:value_Female])?@"on":@"off";
//    NSString *s_showFOF= [self BoolToString:false];
    //    NSString *s_fromAge = [NSString stringWithFormat:@"%i",fromAge];
#if ENABLE_DEMO
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,@"purpose_of_search",
                            isFemale,@"filter_female",
                            isMale,@"filter_male",
                            [NSNumber numberWithInt:300],@"range",
                            [NSNumber numberWithInt:fromAge],@"age_from",
                            [NSNumber numberWithInt:toAge],@"age_to",
                            s_isNewPeople,@"new_people",
                            s_isFOF,@"fof",
                            s_isFriend,@"friends",
                            snapshotObj.location.ID,@"location_id",
                            nil];
#else
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,key_purpose_of_search, //
                            s_gender,key_gender_of_search,  //
                            [NSString stringWithFormat:@"%i",i_range],key_range,    //
                            [NSString stringWithFormat:@"%i",fromAge], key_age_from,    //
                            [NSString stringWithFormat:@"%i",toAge], key_age_to,    //
                            s_isNewPeople,key_new_people_status,//
                            s_isFOF,key_FOF_status, //
                            snapshotObj.location.ID,key_locationID, //
                            s_isInterest,key_is_interests,  //
                            s_isLikes,key_is_likes, //
                            s_isWork,key_is_work,   //
                            s_isSchool,key_is_school,   //
                            s_showFOF,key_show_fof, //
                            @"",key_BlockList,  //
                            @"",key_PriorityList,   //
                            nil];
#endif
    
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setSnapshotSetting parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            NSLog(@"POST SUCCESS!!!");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Warning"
                                  message:@"The new settings will take effect within one day."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }
        else
            NSLog(@"POST FAIL...");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
#if ENABLE_DEMO
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:@"Warning"
//                          message:@"The new settings will take effect within one day."
//                          delegate:self
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil];
//    [alert show];
#endif
}


#pragma mark Picker DataSource/Delegate
-(void) initAgeList{
    //    showCityPicker = NO;
    NSMutableArray *ages = [NSMutableArray array];
    for(int i =MIN_AGE; i <= MAX_AGE; i++){
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [picker removeFromSuperview];
    isPickerShowing = NO;
    [self.tableView reloadData];
}
- (void)dismissKeyboard {
    if (isPickerShowing){
        [[self.tableView.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:isPickerShowing];
        [picker removeFromSuperview];
        isPickerShowing = NO;
        [self.tableView reloadData];
    }
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
//    if (buttonIndex == 0)
//    {
//        NSLog(@"OK Tapped.");
//        [self.navigationController popViewControllerAnimated:YES];
//    }

}
@end
