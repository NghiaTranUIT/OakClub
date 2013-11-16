//
//  VCSnapshotSetting.m
//  oakclubbuild
//
//  Created by VanLuu on 5/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCSnapshotSetting.h"
#import "AppDelegate.h"
#import "SettingObject.h"
#import "NSString+Utils.h"
#import "UIView+Localize.h"

@interface VCSnapshotSetting (){
    NSMutableArray *snapshotItemList;
    SettingObject* snapshotObj;
}

@end

@implementation VCSnapshotSetting
NSIndexPath * whereIndexPath;

@synthesize scrollview, btnMakeNewFriend,rbnChat,rbnDate,rbnShowFriendMeet,rbnShowMeet,chbFriendsOfFriends,chbGirls,chbGuys,chbInterests,chbLikes, chbNewPeople, chbSchool, chbwork, pickerCity,cityOptions,ageOptions, btnCity, btnAgeAround, sliderRange, lblRange, chbFriend, pickerView, rangeSlider, tbSnapshotEdit;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         showCityPicker = NO;
        snapshotItemList = [[NSMutableArray alloc] initWithArray:SnapshotSettingItemList ];
        for(int i =0; i < [SnapshotSettingItemList count]; i++){
            [self updateProfileItemListAtIndex:@"" andIndex:i];
        }
        snapshotObj = [[SettingObject alloc] init];
    }
    return self;
}

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rangeSlider = [[NYSliderPopover alloc] initWithFrame:CGRectMake(0, 0, 300, 23)];
    [self.rangeSlider addTarget:self action:@selector(updateSliderPopoverText) forControlEvents:UIControlEventValueChanged ];
    [self.rangeSlider addTarget:self action:@selector(touchDownOnSlider:) forControlEvents:UIControlEventTouchDown ];
    [self.rangeSlider addTarget:self action:@selector(touchUpOnSlider:) forControlEvents:UIControlEventTouchUpInside ];
    self.rangeSlider.minimumValue=0;
    self.rangeSlider.maximumValue=7;
    // Do any additional setup after loading the view from its nib.
    [scrollview setContentSize:CGSizeMake(320, 1223)];
    fromAge = 16;
    toAge = 25;
    [self loadSetting];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSnapshotSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
//    UIView *infoHeader= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 230, 44)];
//    infoHeader.backgroundColor = [UIColor clearColor];
//    UILabel *titleName = [[UILabel alloc] initWithFrame:infoHeader.frame];
//    titleName.backgroundColor = [UIColor clearColor];
//    titleName.textColor = [UIColor whiteColor];
//    titleName.font = [UIFont boldSystemFontOfSize:26.0];
//    titleName.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//    titleName.textAlignment = UITextAlignmentRight;
//    titleName.text = @"Snapshot";
//    [infoHeader addSubview:titleName];
    self.navigationItem.title = [NSString localizeString:@"Snapshot"];
//    btnAgeAround.titleLabel.text = [NSString stringWithFormat:@"%d-%d year old",fromAge,toAge];
//    [self initCityList];
//    [self initAgeList];
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
//    [pickerCity addGestureRecognizer:singleTap];
    
}
-(void) viewWillAppear:(BOOL)animated{
//    [self loadSetting];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:scrollview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollview:nil];
    [self setBtnMakeNewFriend:nil];
    [self setRbnChat:nil];
    [self setRbnDate:nil];
    [self setChbNewPeople:nil];
    [self setChbFriendsOfFriends:nil];
    [self setChbGuys:nil];
    [self setChbGirls:nil];
    [self setChbInterests:nil];
    [self setChbLikes:nil];
    [self setChbwork:nil];
    [self setChbSchool:nil];
    [self setRbnShowMeet:nil];
    [self setRbnShowFriendMeet:nil];
    [self setPickerCity:nil];
    [self setBtnCity:nil];
    [self setBtnAgeAround:nil];
    [self setLblRange:nil];
    [self setChbFriend:nil];
    [self setPickerView:nil];
    [self setTbSnapshotEdit:nil];
    [super viewDidUnload];
}
- (IBAction)checkboxPressed:(id)sender {
//    sender.selected = !sender.selected;
    [sender setSelected:!((UIButton*)sender).selected];
}
-(IBAction)radiobuttonHereToSelected:(id)sender{
    [self chooseHereToHandle:[(UIButton*)sender tag]];
    
}
-(void) chooseHereToHandle:(int)ID{
    switch (ID) {
        case 0:
            [btnMakeNewFriend setSelected:YES];
            [rbnChat setSelected:NO];
            [rbnDate setSelected:NO];
            break;
        case 1:
            [btnMakeNewFriend setSelected:NO];
            [rbnChat setSelected:YES];
            [rbnDate setSelected:NO];
            break;
        case 2:
            [btnMakeNewFriend setSelected:NO];
            [rbnChat setSelected:NO];
            [rbnDate setSelected:YES];
            break;
        default:
            break;
    }
}

-(IBAction)radiobuttonShowSelected:(id)sender{
    [self chooseShowFOF:[(UIButton*)sender tag]];
    
}
-(void) chooseShowFOF:(int)ID{
    switch (ID) {
        case 0:
            [rbnShowFriendMeet setSelected:NO];
            [rbnShowMeet setSelected:YES];
            break;
        case 1:
            [rbnShowFriendMeet setSelected:YES];
            [rbnShowMeet setSelected:NO];
            break;
        default:
            break;
    }
}
- (IBAction)btnAgeAround:(id)sender {
    [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
//    if (pickerCity.hidden) {
        [self initAgeList];
        CGPoint bottomOffset = CGPointMake(0, chbFriendsOfFriends.frame.origin.y);
        [scrollview setContentOffset:bottomOffset animated:YES];
//        [pickerCity setHidden:NO];
        [self.view addSubview:pickerView.view];
//        [self.view bringSubviewToFront:pickerCity];
//    }
//    else{
////        [pickerCity setHidden:YES];
//        [pickerCity removeFromSuperview];
//    }
}

- (IBAction)onTouchChooseCity:(id)sender {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
   
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(![touch.view isKindOfClass:[UIPickerView class]] ){
        [touch.view removeFromSuperview];
    }
}
- (void) loadSetting{
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getSnapshotSetting parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableDictionary * data= [dict valueForKey:key_data];
        [self loadHereTo:[data valueForKey:key_purpose_of_search]];
        snapshotObj.purpose_of_search = [data valueForKey:key_purpose_of_search];
        [self loadGenderOfSearch:[data valueForKey:key_gender_of_search]];
//        snapshotObj.gender_of_search= [[Gender alloc]init];
        snapshotObj.gender_of_search = [data valueForKey:key_gender_of_search];//[Profile parseGender:[data valueForKey:key_gender_of_search]];
        
        fromAge = [[data valueForKey:key_age_from] integerValue];
        toAge= [[data valueForKey:key_age_to] integerValue];
                
        NSMutableDictionary* status_interested_in = [data valueForKey:key_status_interested_in];
        snapshotObj.interested_new_people = [[status_interested_in valueForKey:key_new_people] boolValue];
        [chbNewPeople setSelected:[[status_interested_in valueForKey:key_new_people] boolValue]];
        snapshotObj.interested_friend_of_friends = [[status_interested_in valueForKey:key_status_fof] boolValue];
        [chbFriendsOfFriends setSelected:[[status_interested_in valueForKey:key_status_fof] boolValue]];
        snapshotObj.interested_friends = [[status_interested_in valueForKey:key_friends] boolValue];

        i_range = [[data valueForKey:key_range] integerValue];
        
        [self.sliderRange setValue:i_range/100];
        [self.rangeSlider setValue:i_range/100];
        lblRange.text = [self getRangeValue:i_range];
        
        NSMutableDictionary *location = [data valueForKey:key_location];
        s_location = [[Location alloc] initWithNSDictionary:location];
        snapshotObj.location = [[Location alloc] initWithNSDictionary:location];
        [btnCity setTitle:s_location.name forState:UIControlStateNormal];
        
        // advance settings
        [self loadShowFOF:[[data valueForKey:key_show_fof] boolValue]];
        
        [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
        [chbInterests setSelected:[[data valueForKey:key_is_interests] boolValue]];
        [chbLikes setSelected:[[data valueForKey:key_is_likes] boolValue]];
        [chbSchool setSelected:[[data valueForKey:key_is_school] boolValue]];
        [chbwork setSelected:[[data valueForKey:key_is_work] boolValue]];

        [self reloadDataSource];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}
-(void)saveSnapshotSetting{
    if(fromAge > toAge){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"From age must be smaller than to age"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert localizeAllViews];
        return;
    }
    
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSString * s_isInterest= [self BoolToString:chbInterests.selected];
    NSString * s_isLikes= [self BoolToString:chbLikes.selected];
    NSString * s_isWork= [self BoolToString:chbwork.selected];
    NSString * s_isSchool= [self BoolToString:chbSchool.selected];
    NSString * s_isNewPeople= [self BoolToString:chbNewPeople.selected];
    NSString * s_isFOF= [self BoolToString:chbFriendsOfFriends.selected];
    NSString * s_isFriend= [self BoolToString:chbFriend.selected];
    NSString *s_hereto = [self getHereToChose];
    NSString *s_gender= [self getGenderSearch];
    NSString *s_showFOF= [self getShowFOFChose];
    //    NSString *s_fromAge = [NSString stringWithFormat:@"%i",fromAge];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,key_purpose_of_search,
                            s_gender,key_gender_of_search,
                            [NSString stringWithFormat:@"%i",i_range],key_range,
                            [NSString stringWithFormat:@"%i",fromAge], key_age_from,
                            [NSString stringWithFormat:@"%i",toAge], key_age_to,
                            s_isNewPeople,key_new_people_status,
                            s_isFOF,key_FOF_status,
                            s_location.ID,key_locationID,
                            s_isInterest,key_is_interests,
                            s_isLikes,key_is_likes,
                            s_isWork,key_is_work,
                            s_isSchool,key_is_school,
                            s_showFOF,key_show_fof,
                            @"",key_BlockList,
                            @"",key_PriorityList,
                            nil];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setSnapshotSetting parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            NSLog(@"POST SUCCESS!!!");
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            NSLog(@"POST FAIL...");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}

- (void) loadHereTo:(NSString*)value{
    if(value!= NULL && [value isEqualToString:value_MakeFriend]){
        [self chooseHereToHandle:0];
    }
    else{
        if([value isEqualToString:value_Chat]){
            [self chooseHereToHandle:1];
        }
        else{
            [self chooseHereToHandle:2];
        }
    }
}
- (NSString*) loadHereToString:(NSString*)value{
    if(value!= NULL && [value isEqualToString:value_MakeFriend]){
        return @"Make New Friends";
    }
    else{
        if([value isEqualToString:value_Chat]){
             return @"Chat";
        }
        else{
             return @"Date";
        }
    }
}

-(void) loadGenderOfSearch:(NSString *)gender{
    if(gender!= NULL && [gender isEqualToString:value_All]){
        [chbGuys setSelected:YES];
        [chbGirls setSelected:YES];
    }
    else{
        if([gender isEqualToString:value_Male]){
            [chbGuys setSelected:YES];
        }
        if([gender isEqualToString:value_Female]){
            [chbGirls setSelected:YES];
        }
    }
}
-(void)loadShowFOF:(BOOL)show{
    if(show){
        [self chooseShowFOF:0];
    }
    else{
        [self chooseShowFOF:1];
    }
}

-(NSString*) BoolToString:(BOOL)value{
    if(value)
        return value_TRUE;
    else
        return value_FALSE;
}

-(NSString*) getHereToChose{
    if(btnMakeNewFriend.selected)
        return value_MakeFriend;
    if(rbnDate.selected)
        return value_Date;
    if(rbnChat.selected)
        return value_Chat;
}
-(NSString*) getGenderSearch{
    if(chbGirls.selected & chbGuys.selected)
        return value_All;
    else{
        if(chbGirls.selected)
            return value_Female;
        else
            return value_Male;
    }
}

-(NSString*) getShowFOFChose{
    if(rbnShowMeet.selected)
        return value_TRUE;
    else
        return value_FALSE;
}
#pragma mark Picker DataSource/Delegate
-(void) initCityList{
    showCityPicker = YES;
    self.cityOptions =  @[@"Ho Chi Minh",@"Ha Noi",@"Hai Phong",@"Da Nang",@"Hue"];//options;
    [pickerCity selectRow:2 inComponent:0 animated:NO];
    [pickerCity reloadAllComponents];
}

-(void) initAgeList{
        showCityPicker = NO;
    NSMutableArray *ages = [NSMutableArray array];
    for(int i =16; i < 46; i++){
        [ages addObject:[NSString stringWithFormat:@"%d",i] ];
    }
    self.ageOptions =  ages;
    [pickerCity reloadAllComponents];
    [pickerCity selectRow:(fromAge - 16) inComponent:0 animated:NO];
    [pickerCity selectRow:(toAge - 16) inComponent:1 animated:NO];
}
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
        [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",fromAge,toAge] forState:UIControlStateNormal];
//        if([ageOptions objectAtIndex:row] < [ageOptions objectAtIndex:[ageOptions count]-1])
    }
    else{
         NSLog(@" select city is %@ OF COMPONENT %d",[cityOptions objectAtIndex:row],component);
        [btnCity setTitle:[NSString stringWithFormat:@"%@ city",[cityOptions objectAtIndex:row]] forState:UIControlStateNormal];
    }
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

-(NSString*)getRangeValue:(NSUInteger)value
{
    NSString* sRange;
    if(value < 600)
        sRange = [NSString stringWithFormat:@"%dkm", value];
    else
        if(value < 700)
            sRange = s_location.countryCode;
        else
            sRange = @"World";
    return sRange;
}

- (void)updateSliderPopoverText
{
//    double value = self.sliderRange.value;
//    int intValue = round(value);
//    [self.sliderRange setValue:intValue];
//    i_range = intValue * 100;
//    NSString* sRange = [self getRangeValue:i_range];
//    self.sliderRange.popover.textLabel.text = sRange;
//    lblRange.text = sRange;
    
    double _value = self.rangeSlider.value;
    int _intValue = round(_value);
    [self.sliderRange setValue:_intValue];
    i_range = _intValue * 100;
    NSString* s_Range = [self getRangeValue:i_range];
    [self.rangeSlider setValue:_intValue];
    self.rangeSlider.popover.textLabel.text = s_Range;
}


#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    SettingObject* selectedValue = [uvcList getSettingValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
            s_location = selected.s_location;
//            [btnCity setTitle:s_location.name forState:UIControlStateNormal];
            snapshotObj.location = s_location;
//            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3] animated:YES];
            break;
        case LISTTYPE_COUNTRY:{
            ListForChoose *locationSubview = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
            [locationSubview setCityListWithCountryCode:selected.s_location.countryCode];
            locationSubview.delegate = self;
            [self.navigationController pushViewController:locationSubview animated:YES];
            break;
        }
        case LISTTYPE_HERETO:
            snapshotObj.purpose_of_search = selectedValue.purpose_of_search;
            break;
        default:
            break;
    }
    [self reloadDataSource];
}
-(SettingObject *)setDefaultSettingValue:(ListForChoose *)uvcList{
    return snapshotObj;
}
- (IBAction)onTapClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onTapSave:(id)sender {
    [self saveSnapshotSetting];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"Edit profile";
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [snapshotItemList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==RANGE)
        return 88;
    else
        return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:MyIdentifier];
	}
    // Configure the cell...
    if(indexPath.row == WHERE)
        whereIndexPath  = indexPath;
    switch (indexPath.row) {
        case NEARBY:
        {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, cell.frame.origin.y + 8, cell.frame.size.width, cell.frame.size.height)] ;
            [aSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:aSwitch];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.textLabel.text = [[snapshotItemList objectAtIndex:indexPath.row] valueForKey:@"key"] ;
            break;
        }
        case RANGE:
        {
            cell.accessoryView = rangeSlider;
            cell.textLabel.text = [[snapshotItemList objectAtIndex:indexPath.row] valueForKey:@"key"] ;
            break;
        }
        default:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [[snapshotItemList objectAtIndex:indexPath.row] valueForKey:@"key"] ;
            cell.detailTextLabel.text = [[snapshotItemList objectAtIndex:indexPath.row] valueForKey:@"value"];
            break;
    }

    
    
    
//    cell.detailTextLabel.text = [[snapshotItemList objectAtIndex:indexPath.row] valueForKey:@"value"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case WHERE:
            [self gotoChooseCity];
            break;
        case HERETO:
            [self gotoChooseHereTo];
            break;
        default:
            break;
    }
}
-(void)reloadDataSource{
    for(int i = 0; i < [SnapshotSettingItemList count]; i++){
        switch (i) {
            case HERETO:
            {
                [self updateProfileItemListAtIndex:[snapshotObj.purpose_of_search valueForKey:@"text"] andIndex:HERETO];
                break;
            }
            case WANTTOSEE:
            {
                if(snapshotObj.interested_new_people){
                    [self updateProfileItemListAtIndex:@"New People" andIndex:WANTTOSEE];
                }
                else{
                    if(snapshotObj.interested_friends){
                        [self updateProfileItemListAtIndex:@"Friends" andIndex:WANTTOSEE];
                    }else{
                        [self updateProfileItemListAtIndex:@"Friends of Friends" andIndex:WANTTOSEE];
                    }
                }
                break;
            }
            case WITHWHO:
            {
                [self updateProfileItemListAtIndex:snapshotObj.gender_of_search andIndex:WITHWHO];
                break;
            }
            case WHERE:
            {
                [self updateProfileItemListAtIndex:snapshotObj.location.name andIndex:WHERE];
                break;
            }
            default:
                break;
        }
    }
    [tbSnapshotEdit reloadData];
}
-(void)updateProfileItemListAtIndex:(NSString*)value andIndex:(SnapshotEditItems)keyEnum{
    [snapshotItemList replaceObjectAtIndex:keyEnum withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:value==nil?@"":value,@"value",[SnapshotSettingItemList objectAtIndex:keyEnum],@"key", nil]];
    
}


-(void)switchChanged{
    UITableViewCell *whereCell = [tbSnapshotEdit cellForRowAtIndexPath:whereIndexPath];
    whereCell.userInteractionEnabled = !whereCell.userInteractionEnabled;
    [whereCell setSelected:NO];
    if( !whereCell.userInteractionEnabled)
        whereCell.detailTextLabel.textColor  = [UIColor grayColor];
    else
         whereCell.detailTextLabel.textColor  = [UIColor blueColor];
}

- (void)gotoChooseCity {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
- (void)gotoChooseHereTo{
    ListForChoose *hereToView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [hereToView setListType:LISTTYPE_HERETO];
    hereToView.delegate=self;
    [self.navigationController pushViewController:hereToView animated:YES];
}



- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
