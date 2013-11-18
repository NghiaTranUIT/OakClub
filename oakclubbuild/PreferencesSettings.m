//
//  PreferencesSettings.m
//  OakClub
//
//  Created by VanLuu on 7/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "PreferencesSettings.h"
#import "UITableView+Custom.h"
#import "Define.h"
#import "AppDelegate.h"
@interface PreferencesSettings (){
    int fromAge;
    int toAge;
    int i_range;
    NSArray *ageOptions;
    UIPickerView* picker;
    bool isPickerShowing;
    SettingObject *newSetting;
     UITapGestureRecognizer *tap;
}
@property (nonatomic) NSUInteger hereTo;
@end

@implementation PreferencesSettings
@synthesize lblHeader,lblFinish;
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
    isPickerShowing = false;
    fromAge = 16;
    toAge = 40;
    newSetting = [self newDefaultSetting];
    
//    self.view.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    lblHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_small"]];
    [lblHeader setFont:FONT_NOKIA(20.0)];
    [lblFinish setFont:FONT_NOKIA(17.0)];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tap];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(SettingObject*)newDefaultSetting{
    SettingObject* settingObj = [[SettingObject alloc] init];
    settingObj.interested_new_people = true;
    settingObj.interested_friends = true;
    settingObj.interested_friend_of_friends = true;
    settingObj.gender_of_search = value_Male;
    settingObj.age_from = fromAge;
    settingObj.age_to = toAge;
    settingObj.location = [[Location alloc] init];
    settingObj.location.ID = @"108458769184495";
    settingObj.location.name = @"Ho Chi Minh City, Vietnam";
    return settingObj;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Table view delegate
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
//        case 3:
//            if(!isPickerShowing)
//                headerLbl.text = @"Where";
//            break;
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
            if (row == 0 && newSetting.interested_new_people)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && newSetting.interested_friend_of_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 2 && newSetting.interested_friends)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            if (row == 0 && ([newSetting.gender_of_search isEqualToString:value_Male] || [newSetting.gender_of_search isEqualToString:value_All]))
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if (row == 1 && ([newSetting.gender_of_search isEqualToString:value_Female] || [newSetting.gender_of_search isEqualToString:value_All]) )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if(row == 2){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d-%d year old",fromAge,toAge];
            }
            break;
        case 3:
            if(row == 0){
                cell.detailTextLabel.text = newSetting.location.name;
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
#pragma mark - Table view delegate
- (void)gotoChooseCity {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (section)
    {
        case 3:
            if (row==0) {
                [self gotoChooseCity];
            }
            break;
        case 0:
            self.hereTo = row;
            switch (row) {
                case 0:
                    newSetting.purpose_of_search = value_Date;
                    break;
                case 1:
                    newSetting.purpose_of_search = value_MakeFriend;
                    break;
                case 2:
                    newSetting.purpose_of_search = value_Chat;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            if(row == 0){
                newSetting.interested_new_people = !newSetting.interested_new_people;
            }
            if(row == 1){
                newSetting.interested_friend_of_friends = !newSetting.interested_friend_of_friends;
            }
            if(row == 2){
                newSetting.interested_friends = !newSetting.interested_friends;
            }
            break;
        case 2:
            if(row == 0){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([newSetting.gender_of_search isEqualToString:value_Male])
                        newSetting.gender_of_search = @"none";
                    else
                        newSetting.gender_of_search = value_Female;
                }
                else{
                    if([newSetting.gender_of_search isEqualToString:value_Female])
                        newSetting.gender_of_search =value_All;
                    else
                        newSetting.gender_of_search = value_Male;
                }
                
            }
            if(row == 1){
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                    if([newSetting.gender_of_search isEqualToString:value_Female])
                        newSetting.gender_of_search = @"none";
                    else
                        newSetting.gender_of_search = value_Male;
                }
                else{
                    if([newSetting.gender_of_search isEqualToString:value_Male])
                        newSetting.gender_of_search =value_All;
                    else
                        newSetting.gender_of_search = value_Female;
                }
            }
            if(row == 2){
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
                [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                if(isPickerShowing){
                    [picker removeFromSuperview];
                }
                else{
                    picker = [[UIPickerView alloc] init];
                    picker.delegate = self;
                    picker.dataSource =self;
                    picker.showsSelectionIndicator = YES;
                    picker.frame = CGRectMake(0, cell.frame.origin.y + 42, 320, 200);
                    [self initAgeList];
                    [self.view addSubview: picker];
                    [picker setNeedsDisplay];
                    
                }
                isPickerShowing = !isPickerShowing;
                [self.tableView reloadData];
                
            }
            break;
    }
    if (indexPath.row == 0 && indexPath.section==4) {
//        AppDelegate* appDelegate = [self appDelegate];
//        [appDelegate getProfileInfoWithHandler:^(void)
//         {
//             menuViewController *leftController = [[menuViewController alloc] init];
//             [leftController setUIInfo:appDelegate.myProfile];
//             [appDelegate.rootVC setRightViewController:appDelegate.chat];
//             [appDelegate.rootVC setLeftViewController:leftController];
//             appDelegate.window.rootViewController = appDelegate.rootVC;
//         }];
    }
    [self.tableView reloadData];
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
        {
            newSetting.location = selected.s_location;
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
    if(component == 0)
        fromAge = [[ageOptions objectAtIndex:row] integerValue];
    else
        toAge = [[ageOptions objectAtIndex:row] integerValue];
    [self.tableView reloadData];
    
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
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.tableView reloadData];
    }
}


- (void)viewDidUnload {
    [self setLblHeader:nil];
    [self setLblFinish:nil];
    [super viewDidUnload];
}

- (void)saveSettings
{
    
}
@end
