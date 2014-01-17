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
#import "VCLogout.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RangeSlider.h"
#import "NSString+Utils.h"
#import "LoadingIndicator.h"
#import "VCAppLanguageChoose.h"

@interface VCSimpleSnapshotSetting () <LoadingIndicatorDelegate, MFMailComposeViewControllerDelegate>{
    SettingObject* snapshotObj;
    AFHTTPClient *request;
    NSArray *ageOptions;
    UIPickerView* picker;
    bool isPickerShowing;
    AppDelegate *appDel;
    LoadingIndicator *indicator;
    NSDictionary *appLangs;
}
@property (nonatomic) NSUInteger hereTo;
@property NYSliderPopover *rangeSlider;
@property RangeSlider* ageSlider;
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak,nonatomic) IBOutlet VCLogout* logoutViewController;
@end

@implementation VCSimpleSnapshotSetting

UITapGestureRecognizer *tap;
@synthesize lblRange,pickerAge, btnAdvance,lblRangeOfAge;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        appLangs = AppLanguageList;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self customBackButtonBarItem];
    [self initSliderForRange];
    appDel = [self appDelegate];
    indicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:self];
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tbView addGestureRecognizer:tap];
    
    snapshotObj = appDel.snapshotSettingsObj;
    [self initAgeRangeSlider];
    [self loadSetting];
//    self.tbView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
     [self showNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated{
//    [self initSaveButton];
    [super viewWillAppear:animated];
    
    isPickerShowing = false;
    [self showNotifications];
    
    [self.view localizeAllViews];
    [self.navigationController.view localizeAllViews];
    [self.tbView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Intialize
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)showNotifications
{
    int totalNotifications = [appDel countTotalNotifications];
    [[self navBarOakClub] setNotifications:totalNotifications];
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
    return NumOfSettingGroup;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == MoreGroup) {
        return 0;
    }
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rowHeight=0;
    switch (indexPath.section) {
        case DistanceGroup:
            rowHeight = 80;
            break;
        case MoreGroup:
            rowHeight = 250;
            break;
        case AgeGroup:
            rowHeight = 80;
            break;
        default:
            rowHeight = 44;
            break;
    }
    return rowHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount=0;
    switch (section)
    {
        case LanguageGroup:
            rowCount = 1;
            break;
        case GenderSearchGroup:
#if ENABLE_INCLUDE_FACEBOOKFRIEND
            rowCount = 3;
#else
            rowCount = 2;
#endif
            break;
#ifndef DISABLE_HERETO_SHOWME
        case HereToGroup:
            rowCount = 3;
            break;
        case ShowMeGroup:
            rowCount = 3;
            break;
#endif
        case DistanceGroup:
            rowCount = 1;
            break;
        case AgeGroup:
            rowCount = 1;
            break;
        case MoreGroup:
            rowCount = 1;
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
#ifndef DISABLE_HERETO_SHOWME
        case HereToGroup:
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
            
        case ShowMeGroup:
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
#endif
        case AgeGroup:
        {
            static NSString *rangeAgeCellID = @"RangeAgeCell";
            UITableViewCell *rangeAgeCell = [tableView dequeueReusableCellWithIdentifier:rangeAgeCellID];
            if (rangeAgeCell == nil)
            {
                rangeAgeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rangeAgeCellID];
                UIView *newCellView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
                lblRangeOfAge = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 280, 30)];
                
                lblRangeOfAge.textAlignment = NSTextAlignmentCenter;
                //                [lblRange setTextColor:[UIColor blackColor]];
                [lblRangeOfAge setBackgroundColor:[UIColor clearColor]];
                [lblRangeOfAge setFont:FONT_HELVETICANEUE_LIGHT(15.0)];
                [newCellView addSubview:self.ageSlider];
                [newCellView addSubview:lblRangeOfAge];
                
                [rangeAgeCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                rangeAgeCell.accessoryView = newCellView;
            }
            [lblRangeOfAge setText: [NSString stringWithFormat: @"%d %@ %d %@",snapshotObj.age_from,[@"to" localize],snapshotObj.age_to,[@"years old" localize]]];
//            NSLog(@"lblRangeOfAge: %@", lblRangeOfAge);
//            [rangeAgeCell localizeAllViews];
            return rangeAgeCell;
            break;
        }
        case GenderSearchGroup:
            switch (row) {
                case 0:
                {
                    static NSString *filterGuysID = @"FilterGuysID";
                    UITableViewCell *filterGuysCell = [tableView dequeueReusableCellWithIdentifier:filterGuysID];
                    if (filterGuysCell == nil)
                    {
                        filterGuysCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:filterGuysID];
                        filterGuysCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *autoSwitch = [[UISwitch alloc] init];
                        [autoSwitch addTarget:self action:@selector(onSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
                        autoSwitch.frame = CGRectMake(cell.frame.size.width - autoSwitch.frame.size.width - 30, (cell.frame.size.height - autoSwitch.frame.size.height) / 2, autoSwitch.frame.size.width, autoSwitch.frame.size.height);
                        [autoSwitch setOnTintColor:COLOR_PURPLE];
                        autoSwitch.tag = 100;
                        [filterGuysCell.contentView addSubview:autoSwitch];
                        [filterGuysCell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(15.0)];
                        filterGuysCell.textLabel.highlightedTextColor = [UIColor whiteColor];
                    }
                    
                    UISwitch *autoSwitch = (id) [filterGuysCell viewWithTag:100];
                    autoSwitch.on = snapshotObj.hasMale;
                    
                    filterGuysCell.textLabel.text = [@"Male" localize];
                    return filterGuysCell;
                }
                    break;
                case 1:
                {
                    static NSString *filterGirlsID = @"FilterGirlsID";
                    UITableViewCell *filterGirlsCell = [tableView dequeueReusableCellWithIdentifier:filterGirlsID];
                    if (filterGirlsCell == nil)
                    {
                        filterGirlsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:filterGirlsID];
                        filterGirlsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *autoSwitch = [[UISwitch alloc] init];
                        [autoSwitch addTarget:self action:@selector(onSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
                        autoSwitch.frame = CGRectMake(cell.frame.size.width - autoSwitch.frame.size.width - 30, (cell.frame.size.height - autoSwitch.frame.size.height) / 2, autoSwitch.frame.size.width, autoSwitch.frame.size.height);
                        [autoSwitch setOnTintColor:COLOR_PURPLE];
                        autoSwitch.tag = 101;
                        [filterGirlsCell.contentView addSubview:autoSwitch];
                        [filterGirlsCell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(15.0)];
                        filterGirlsCell.textLabel.highlightedTextColor = [UIColor whiteColor];
                    }
                    
                    UISwitch *autoSwitch = (id) [filterGirlsCell viewWithTag:101];
                    autoSwitch.on = snapshotObj.hasFemale;
                    
                    filterGirlsCell.textLabel.text = [@"Female" localize];
                    return filterGirlsCell;
                }
                case 2:
                {
                    static NSString *includeFBFriendID = @"IncludeFBFriendsID";
                    UITableViewCell *includeFBFriendsCell = [tableView dequeueReusableCellWithIdentifier:includeFBFriendID];
                    if (includeFBFriendsCell == nil)
                    {
                        includeFBFriendsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:includeFBFriendID];
                        includeFBFriendsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *autoSwitch = [[UISwitch alloc] init];
                        [autoSwitch addTarget:self action:@selector(onSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
                        autoSwitch.frame = CGRectMake(cell.frame.size.width - autoSwitch.frame.size.width - 30, (cell.frame.size.height - autoSwitch.frame.size.height) / 2, autoSwitch.frame.size.width, autoSwitch.frame.size.height);
                        [autoSwitch setOnTintColor:COLOR_PURPLE];
                        autoSwitch.tag = 102;
                        [includeFBFriendsCell.contentView addSubview:autoSwitch];
                        [includeFBFriendsCell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(15.0)];
                        includeFBFriendsCell.textLabel.highlightedTextColor = [UIColor whiteColor];
                    }
                    
                    UISwitch *autoSwitch = (id) [includeFBFriendsCell viewWithTag:102];
                    autoSwitch.on = snapshotObj.include_facebook_friend;
                    
                    includeFBFriendsCell.textLabel.text = [@"Include facebook friend" localize];
                    return includeFBFriendsCell;
                }
                    break;
                default:
                    break;
            }
            break;
        case DistanceGroup:
        {
            static NSString *rangeCellID = @"RangeCell";
            UITableViewCell *rangeCell = [tableView dequeueReusableCellWithIdentifier:rangeCellID];
            if (rangeCell == nil)
            {
                rangeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rangeCellID];
                UIView *newCellView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
                lblRange = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 280, 30)];
                [lblRange setBackgroundColor:[UIColor clearColor]];
                [lblRange setFont:FONT_HELVETICANEUE_LIGHT(15.0)];
                lblRange.adjustsFontSizeToFitWidth = YES;
                [newCellView addSubview:self.rangeSlider];
                [newCellView addSubview:lblRange];
                
                [rangeCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                rangeCell.accessoryView = newCellView;
            }
            lblRange.text = [self getRangeValue:snapshotObj.range];
//            [rangeCell localizeAllViews];
            return rangeCell;
            break;
        }
        case LanguageGroup:
        {
            static NSString *languageIdentifier = @"LANGUAGEID";
            UITableViewCell *languageCell = [tableView dequeueReusableCellWithIdentifier:languageIdentifier];
            if (!languageCell)
            {
                languageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:languageIdentifier];
                [languageCell.textLabel setFont:FONT_HELVETICANEUE_LIGHT(15.0)];
                languageCell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
            languageCell.textLabel.text = [appLangs objectForKey:selectedLanguage];
            
//            [languageCell localizeAllViews];
            return languageCell;
            break;
        }
        case MoreGroup:
        {
            static NSString *moreCellID = @"MoreCell";
            UITableViewCell *moreCell = [tableView dequeueReusableCellWithIdentifier:moreCellID];
            if (moreCell == nil)
            {
                moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:moreCellID];
                UIView *newCellView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 250)];
                
//                UIButton* btnSave = [[UIButton alloc]initWithFrame:CGRectMake(25, 26, 291, 45)];
//                [btnSave setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_save_inactive"] forState:UIControlStateNormal];
//                [btnSave setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_save_active"] forState:UIControlStateHighlighted];
//                [btnSave setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_save_active"] forState:UIControlStateSelected];
//                [btnSave setTitle:@"Save Your Settings" forState:UIControlStateNormal];
//                [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                [btnSave setTitleColor:COLOR_PURPLE forState:UIControlStateHighlighted];
//                [btnSave setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
//                [btnSave.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15)];
//                [btnSave addTarget:self action:@selector(onTouchSaveSetting) forControlEvents:UIControlEventTouchUpInside];
//                [newCellView addSubview:btnSave];
                
                UIButton* btnContactUs = [[UIButton alloc]initWithFrame:CGRectMake(25, 26, 143, 45)];
                [btnContactUs setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_contactus_inactive"] forState:UIControlStateNormal];
                [btnContactUs setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_contactus_active"] forState:UIControlStateHighlighted];
                [btnContactUs setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_contactus_active"] forState:UIControlStateSelected];
                btnContactUs.titleLabel.languageKey = @"Contact us";
                [btnContactUs setTitle:@"Contact us" forState:UIControlStateNormal];
                [btnContactUs setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnContactUs setTitleColor:COLOR_PURPLE forState:UIControlStateHighlighted];
                [btnContactUs setTitleEdgeInsets: UIEdgeInsetsMake(0, 45, 0, 0)];
                [btnContactUs.titleLabel setTextAlignment: NSTextAlignmentLeft];
                [btnContactUs.titleLabel setAdjustsFontSizeToFitWidth:YES];
                [btnContactUs.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15)];
                [btnContactUs addTarget:self action:@selector(onTouchContactUs) forControlEvents:UIControlEventTouchUpInside];
                [newCellView addSubview:btnContactUs];
                
                UIButton* btnLogout = [[UIButton alloc]initWithFrame:CGRectMake(172, 26, 143, 45)];
                [btnLogout setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_logout_active"] forState:UIControlStateNormal];
                [btnLogout setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_logout_inactive"] forState:UIControlStateHighlighted];
                [btnLogout setBackgroundImage:[UIImage imageNamed:@"SnapshotSetting_btn_logout_inactive"] forState:UIControlStateSelected];
                btnLogout.titleLabel.languageKey = @"Logout";
                [btnLogout setTitle:@"Logout" forState:UIControlStateNormal];
                [btnLogout setTitleEdgeInsets:UIEdgeInsetsMake(0, 32, 0, 0)];
                [btnLogout setTitleColor:COLOR_PURPLE forState:UIControlStateNormal];
                [btnLogout setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btnLogout.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15)];
                [btnLogout addTarget:self action:@selector(onTouchLogout) forControlEvents:UIControlEventTouchUpInside];
                [newCellView addSubview:btnLogout];
                
                UIImage* logoImage = [UIImage imageNamed:@"SnapshotSetting_oakclub_logo.png"];
                UIImageView* logoImageView = [[UIImageView alloc]initWithImage:logoImage];
                [logoImageView setFrame:CGRectMake((newCellView.frame.size.width - 108)/2, 97  , 108, 90)];
                [newCellView addSubview:logoImageView];
                
                
                UILabel* lblVersion = [[UILabel alloc]initWithFrame:CGRectMake(100, logoImageView.frame.origin.y  + logoImageView.frame.size.height + 2, 120, 30)];
                [lblVersion setText:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] ];
                [lblVersion setTextColor:[UIColor lightGrayColor]];
                [lblVersion setFont:FONT_HELVETICANEUE_LIGHT(12)];
                [lblVersion setBackgroundColor:[UIColor clearColor]];
                [lblVersion setTextAlignment:NSTextAlignmentCenter];
                [newCellView addSubview:lblVersion];
                
                [newCellView localizeAllViews];
                [moreCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                moreCell.accessoryView = newCellView;
            }
            
            [moreCell localizeAllViews];
            return moreCell;
            
            break;
        }
    }
    
    [cell.detailTextLabel setFont: FONT_HELVETICANEUE_LIGHT(15.0)];
    cell.detailTextLabel.textColor = COLOR_PURPLE;
    [cell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(15.0)];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    
    [cell localizeAllViews];
    return cell;
}
#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == MoreGroup)
        return nil;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    UIImageView *headerImage = [[UIImageView alloc] init]; //set your image/
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 20)];//set as you need
    headerLbl.backgroundColor = [UIColor clearColor];
    UIFont *newfont = FONT_HELVETICANEUE_LIGHT(15.0);
    [headerLbl setFont:newfont];
    switch (section) {
#ifndef DISABLE_HERETO_SHOWME
        case HereToGroup:
            headerLbl.text = @"I'M HERE TO";
            break;
        case ShowMeGroup:
            headerLbl.text = @"SHOW ME";
            break;
#endif
        case GenderSearchGroup: 
            headerLbl.text = @"I WOULD LIKE TO BE MATCHED WITH";
            break;
        case DistanceGroup:
            if(!isPickerShowing)
                headerLbl.text = @"FIND PEOPLE AROUND ME";
            break;
        case LanguageGroup:
            headerLbl.text = @"CHOOSE YOUR LANGUAGE";
            break;
        case AgeGroup:
            headerLbl.text = @"SHOW ME PEOPLE AGE OF";
            break;
        default:
            headerLbl.text = nil;
            break;
    }
    [headerImage addSubview:headerLbl];
    
    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
    
    [headerView addSubview:headerImage];
    
    [headerView localizeAllViews];
    return headerView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    switch (section)
    {
        case LanguageGroup:
        {
            
            VCAppLanguageChoose *appLangChoose = [[VCAppLanguageChoose alloc]initWithNibName:@"VCAppLanguageChoose" bundle:nil];
            [self.navigationController pushViewController:appLangChoose animated:YES];
            break;
        }
//        case DistanceGroup:
//            if (row==0) {
//                [self gotoChooseCity];
//            }
//            break;
#ifndef DISABLE_HERETO_SHOWME
        case HereToGroup:
        {
            self.hereTo = row;
            NSString *newPurpose;
            switch (row) {
                case 0:
                    newPurpose = value_Date;
                    break;
                case 1:
                    newPurpose = value_MakeFriend;
                    break;
                case 2:
                    newPurpose = value_Chat;
                    break;
                default:
                    break;
            }
            if (![newPurpose isEqualToString:snapshotObj.purpose_of_search])
            {
                snapshotObj.purpose_of_search = newPurpose;
                appDel.reloadSnapshot = YES;
            }
        }
            break;
        case ShowMeGroup:
//            if(row == 0){
//                snapshotObj.interested_new_people = !snapshotObj.interested_new_people;
//            }
//            if(row == 1){
//                snapshotObj.interested_friend_of_friends = !snapshotObj.interested_friend_of_friends;
//            }
//            if(row == 2){
//                snapshotObj.interested_friends = !snapshotObj.interested_friends;
//            }
            if(row == 0 && !snapshotObj.interested_new_people){
                snapshotObj.interested_new_people = YES;
                snapshotObj.interested_friend_of_friends = NO;
                snapshotObj.interested_friends = NO;
                appDel.reloadSnapshot = YES;
            }
            if(row == 1 && !snapshotObj.interested_friend_of_friends){
                snapshotObj.interested_new_people = NO;
                snapshotObj.interested_friend_of_friends = YES;
                snapshotObj.interested_friends = NO;
                appDel.reloadSnapshot = YES;
            }
            if(row == 2 && !snapshotObj.interested_friends){
                snapshotObj.interested_new_people = NO;
                snapshotObj.interested_friend_of_friends = NO;
                snapshotObj.interested_friends = YES;
                appDel.reloadSnapshot = YES;
            }

            break;
#endif
        case GenderSearchGroup:
            // do nothing
            break;
    }
    [self.tbView reloadData];
}

- (void)viewDidUnload {
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
    //SettingObject* selectedValue = [uvcList getSettingValue];
    switch ([uvcList getType]) {
        case LISTTYPE_CITY:
        {
            snapshotObj.location = selected.s_location;
            [self.tbView reloadData];
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

- (void) loadSetting
{
    self.hereTo = [self loadHereTo:snapshotObj.purpose_of_search];
    
    self.ageSlider.max = (CGFloat) (snapshotObj.age_to - MIN_AGE)/(MAX_AGE-MIN_AGE);
    [self.ageSlider setMin:(CGFloat) (snapshotObj.age_from - MIN_AGE)/(MAX_AGE-MIN_AGE)];
    
    [self.rangeSlider setValue:snapshotObj.range/100];
    lblRange.text = [self getRangeValue:snapshotObj.range];
    
    [self.tbView reloadData];
}

-(void)saveSetting{
    if(snapshotObj.age_from > snapshotObj.age_to){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[@"Warning" localize]
                              message:@"From age must be smaller than to age"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert localizeAllViews];
        [alert show];
        return;
    }
    
    NSString * s_isNewPeople= snapshotObj.interested_new_people?@"true":@"";
    NSString * s_isFOF= snapshotObj.interested_friend_of_friends?@"true":@"";
    NSString * s_isFriend= snapshotObj.interested_friends?@"true":@"";
    NSString *s_hereto = snapshotObj.purpose_of_search;
    NSString *isMale = snapshotObj.hasMale?@"on":@"";
    NSString *isFemale = snapshotObj.hasFemale?@"on":@"";
#if ENABLE_DEMO
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,@"purpose_of_search",
                            isFemale,@"filter_female",
                            isMale,@"filter_male",
                            [NSNumber numberWithInt:snapshotObj.range],@"range",
                            [NSNumber numberWithInt:snapshotObj.age_from],@"age_from",
                            [NSNumber numberWithInt:snapshotObj.age_to],@"age_to",
                            s_isNewPeople,@"new_people",
                            s_isFOF,@"fof",
                            s_isFriend,@"friends",
                            nil];
#else
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            s_hereto,key_purpose_of_search, //
                            s_gender,key_gender_of_search,  //
                            [NSString stringWithFormat:@"%i",snapshotObj.range],key_range,    //
                            [NSString stringWithFormat:@"%i",snapshotObj.age_from], key_age_from,    //
                            [NSString stringWithFormat:@"%i",snapshotObj.age_to], key_age_to,    //
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
    [indicator lockViewAndDisplayIndicator];
    NSLog(@"setSnapshot setting params : %@",params);
    
    request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_setSnapshotSetting parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            NSLog(@"POST SUCCESS!!!");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[@"Completed" localize]
                                  message:@"Settings saved"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert localizeAllViews];
            [alert show];

            appDel.reloadSnapshot = TRUE;
        }
        else
        {
            NSLog(@"POST FAIL...");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[@"Warning" localize]
                                  message:@"Settings cannot be saved now."
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
            [alert localizeAllViews];
            [alert show];
        }
        
        [indicator unlockViewAndStopIndicator];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_setSnapshotSetting - Error Code: %i - %@",[error code], [error localizedDescription]);
        [indicator unlockViewAndStopIndicator];
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
    [picker selectRow:(snapshotObj.age_from - 16) inComponent:0 animated:NO];
    [picker selectRow:(snapshotObj.age_to - 16) inComponent:1 animated:NO];
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
        snapshotObj.age_from = [[ageOptions objectAtIndex:row] integerValue];
    else
        snapshotObj.age_to = [[ageOptions objectAtIndex:row] integerValue];
    //    [self.tbView reloadSections:[[NSIndexPath alloc] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbView reloadData];
    //    [btnAgeAround setTitle:[NSString stringWithFormat:@"%d-%d year old",snapshotObj.age_from,snapshotObj.age_to] forState:UIControlStateNormal];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [picker removeFromSuperview];
    isPickerShowing = NO;
    [self.tbView reloadData];
}
- (void)dismissKeyboard {
    if (isPickerShowing){
        [[self.tbView.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:isPickerShowing];
        [picker removeFromSuperview];
        isPickerShowing = NO;
        [self.tbView reloadData];
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

#pragma mark SLIDE -delegate/init
-(void)initSliderForRange{
    self.rangeSlider = [[NYSliderPopover alloc] initWithFrame:CGRectMake(30, 40, 280, 23)];
    self.rangeSlider.minimumTrackTintColor = COLOR_PURPLE;
    //custom view for slider
    UIImage *minImage = [[UIImage imageNamed:@"SnapshotSetting_fillrange_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *maxImage = [[UIImage imageNamed:@"SnapshotSetting_fullrange_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"SnapshotSetting_thumb_slider.png"];
    [self.rangeSlider  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [self.rangeSlider  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.rangeSlider  setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [self.rangeSlider addTarget:self action:@selector(updateSliderPopoverText) forControlEvents:UIControlEventValueChanged ];
    [self.rangeSlider addTarget:self action:@selector(touchDownOnSlider:) forControlEvents:UIControlEventTouchDown ];
    [self.rangeSlider addTarget:self action:@selector(touchUpOnSlider:) forControlEvents:UIControlEventTouchUpInside ];
    self.rangeSlider.minimumValue=0;
    self.rangeSlider.maximumValue=7;
}

- (IBAction)touchDownOnSlider:(id)sender {
    appDel.rootVC.recognizesPanningOnFrontView = NO;
}

- (IBAction)touchUpOnSlider:(id)sender {
    appDel.rootVC.recognizesPanningOnFrontView = YES;
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateSliderPopoverText];
}
- (void)updateSliderPopoverText
{
    double value = self.rangeSlider.value;
    int intValue = round(value);
    [self.rangeSlider setValue:intValue];
    if (snapshotObj.range != intValue)
    {
        snapshotObj.range = intValue * 100;
        NSString* sRange = [self getRangeValue:snapshotObj.range];
        lblRange.text = sRange;
        
        appDel.reloadSnapshot = YES;
    }
}

-(NSString*)getRangeValue:(NSUInteger)value
{
    NSString* sRange;
    NSString *prefSearchDistance = [@"Limit my search to this distance" localize];
    if(value < 600)
        sRange = [NSString stringWithFormat:[prefSearchDistance stringByAppendingString:@": %d km"],value];
    else{
        sRange = [prefSearchDistance stringByAppendingString:@": "];
        if(value < 700)
            sRange = [sRange stringByAppendingString:[@"Country" localize]];//snapshotObj.location.countryCode;
        else
            sRange = [sRange stringByAppendingString:[@"World" localize]];
    }
    return sRange;
}

#pragma mark handle OnTouch Events
-(void)onTouchSaveSetting{
    [self saveSetting];
}
-(void)onTouchContactUs{
//    NSString* body = @"";
//    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:body,nil] applicationActivities:nil];
//    
//    [activityViewController setValue:[@"Requests and Suggestions to Oakclub" localize] forKey:@"subject"];
//    [activityViewController setValue:@"sfkjdhfkj" forKey:@"torecipients"];
//    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToTwitter,UIActivityTypePostToFacebook,UIActivityTypeMessage];
//    [self presentViewController:activityViewController animated:YES completion:nil];
//
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:[@"Requests and Suggestions to Oakclub" localize]];
        [mailCont setToRecipients:[NSArray arrayWithObjects:[@"help@oakclub.com" localize],nil]];
        [mailCont setMessageBody:@"" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[@"Warning" localize]
                              message:@"Can not access to email."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert localizeAllViews];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


-(void)onTouchLogout{
//    [self.tbView setUserInteractionEnabled:NO];
//    [self.tbView setScrollEnabled:NO];
//    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
//    self.logoutViewController = [[VCLogout alloc]init];
    CGPoint viewPoint = CGPointZero;
    [self.logoutController.view setFrame:CGRectMake(0, self.view.frame.size.height, self.logoutController.view.frame.size.width, self.view.frame.size.height-44)];
    [self.logoutController.view localizeAllViews];
    [self.view addSubview:self.logoutController.view];
    [self.view bringSubviewToFront:self.logoutController.view];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.logoutController.view setFrame:CGRectMake(0, viewPoint.y, self.logoutController.view.frame.size.width, self.view.frame.size.height-44)];
                     }completion:^(BOOL finished) {
                     }];
}
#pragma mark handle on touch
- (IBAction)onTouchConfirmLogout:(id)sender {
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.logoutViewController.view removeFromSuperview];
//    appDel.rootVC.recognizesPanningOnFrontView = YES;
    [self.tbView setScrollEnabled:YES];
    [appDel  logOut];
}
- (IBAction)onTouchCancelLogout:(id)sender {
    //    [self.navigationController popViewControllerAnimated:NO];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.logoutViewController.view setFrame:CGRectMake(0, self.tbView.contentSize.height, self.logoutViewController.view.frame.size.width, self.view.frame.size.height-44)];
                     }completion:^(BOOL finished) {
                         [self.logoutViewController.view removeFromSuperview];
                         [self.tbView setScrollEnabled:YES];
//                         appDel.rootVC.recognizesPanningOnFrontView = YES;
                         [self.navigationController.navigationBar setUserInteractionEnabled:YES];
                     }];
    
}

#pragma mark Switch delegate
-(void)onSwitchChangedValue:(id)sender{
    int tag= [(UISwitch*)sender tag];
    switch (tag) {
        case 100:
        {
            if ([sender isOn] != snapshotObj.hasMale)
            {
                snapshotObj.hasMale = [sender isOn];
                appDel.reloadSnapshot = YES;
            }
            break;
        }
        case 101:
        {
            if ([sender isOn] != snapshotObj.hasFemale)
            {
                snapshotObj.hasFemale = [sender isOn];
                appDel.reloadSnapshot = YES;
            }
            break;
        }
        case 102:
        {
            if ([sender isOn] != snapshotObj.include_facebook_friend)
            {
                snapshotObj.include_facebook_friend = [sender isOn];
                appDel.reloadSnapshot = YES;
            }
        }
        default:
            break;
    }
    
    [self.tbView reloadData];
}

#pragma mark Range of Age slider
-(void)initAgeRangeSlider{
    self.ageSlider = [[RangeSlider alloc] initWithFrame:CGRectMake(30, 40, 280, 23)]; // the slider enforces a height of 30, although I'm not sure that this is necessary
	
	self.ageSlider.minimumRangeLength = 0;//.03; // this property enforces a minimum range size. By default it is set to 0.0


	[self.ageSlider setMinThumbImage:[UIImage imageNamed:@"SnapshotSetting_thumb_slider.png"]]; // the two thumb controls are given custom images
	[self.ageSlider setMaxThumbImage:[UIImage imageNamed:@"SnapshotSetting_thumb_slider.png"]];
	
	UIImage *image; // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
	
	[self.ageSlider setTrackImage:[[UIImage imageNamed:@"SnapshotSetting_fullrange_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
	
	image = [UIImage imageNamed:@"SnapshotSetting_fillrange_slider.png"];
	[self.ageSlider setInRangeTrackImage:image];
    
	
	[self.ageSlider addTarget:self action:@selector(report:) forControlEvents:UIControlEventValueChanged]; // The slider sends actions when the value of the minimum or maximum changes
	[self.ageSlider addTarget:self action:@selector(touchDownOnSlider:) forControlEvents:UIControlEventTouchDown];
    [self.ageSlider addTarget:self action:@selector(touchUpOnSlider:) forControlEvents:UIControlEventTouchUpInside];
//    snapshotObj.age_from = 18;
//    snapshotObj.age_to = 45;
    [lblRangeOfAge setText: [NSString stringWithFormat: @"%d %@ %d %@",snapshotObj.age_from,[@"to" localize],snapshotObj.age_to,[@"years old" localize]]];
    self.ageSlider.max = (CGFloat) (snapshotObj.age_to - MIN_AGE)/(MAX_AGE-MIN_AGE);
    [self.ageSlider setMin:(CGFloat) (snapshotObj.age_from - MIN_AGE)/(MAX_AGE-MIN_AGE)];
}

- (void)report:(RangeSlider *)sender {
//	NSString *report = [NSString stringWithFormat:@"current slider range is %f to %f", sender.min, sender.max];
//	reportLabel.text = report;
    int fromAge, toAge;
    fromAge = MIN_AGE + (sender.min * (MAX_AGE - MIN_AGE));
    toAge = MIN_AGE + (sender.max * (MAX_AGE - MIN_AGE));
    
    
    if (toAge == 17) {
        toAge++;
    }
    if (fromAge == toAge) {
        fromAge = toAge - 1;
    }
    
    if ((toAge - fromAge) > 16) {
        if ([sender isTrackingMaxSlider]) {
            fromAge = toAge - 16;
        } else {
            toAge = fromAge + 16;
        }
        
        self.ageSlider.max = (CGFloat) (toAge - MIN_AGE)/(MAX_AGE-MIN_AGE);
        self.ageSlider.min = (CGFloat) (fromAge - MIN_AGE)/(MAX_AGE-MIN_AGE);
    }
    
    if (fromAge != snapshotObj.age_from || toAge != snapshotObj.age_to)
    {
        snapshotObj.age_from = fromAge;
        snapshotObj.age_to = toAge;
        
        appDel.reloadSnapshot = YES;
    }
    [lblRangeOfAge setText: [NSString stringWithFormat: @"%d %@ %d %@",snapshotObj.age_from,[@"to" localize],snapshotObj.age_to,[@"years old" localize]]];
//	NSLog(@"%@",report);
    
}

#pragma mark LOADING INDICATOR DELEGATE
-(void)lockViewForIndicator:(LoadingIndicator *)indicator
{
    [appDel.rootVC.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}

-(void)unlockViewForIndicator:(LoadingIndicator *)indicator
{
    [appDel.rootVC.view setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}

-(void)customizeIndicator:(UIActivityIndicatorView *)_indicator ofLoadingIndicator:(LoadingIndicator *)loadingIndicator
{
    CGRect frame = _indicator.frame;
    frame.origin.y = 200;
    
    [_indicator setFrame:frame];
}
@end
