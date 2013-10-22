//
//  VCMyProfile.m
//  oakclubbuild
//
//  Created by VanLuu on 5/7/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCMyProfile.h"
#import "GroupButtons.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UITableView+Custom.h"
#import "PickPhotoFromGarelly.h"
#import "NSString+Utils.h"
@interface VCMyProfile () <PickPhotoFromGarellyDelegate, UIAlertViewDelegate>{
    GroupButtons* genderGroup;
     AppDelegate *appDelegate;
    NSMutableArray *profileItemList;
    NSArray *weightOptionList;
    NSArray *heightOptionList;
    Profile* profileObj;
    PickPhotoFromGarelly *avatarPicker;
}

@end

@implementation VCMyProfile
UITapGestureRecognizer *tap;

@synthesize rbnFemale, rbnMale, btnLocation, btnRelationShip, btnEthnicity, btnLanguage, btnWork, scrollview,labelAge, labelName, labelPurposeSearch, textFieldName,textFieldHeight,textfieldSchool,textFieldWeight, btnBirthdate,imgAvatar, pickerView, textviewAbout, tbEditProfile, pickerWeight, pickerHeight;

CLLocationManager *locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
        profileItemList = [[NSMutableArray alloc] initWithArray:MyProfileItemList];
        
    }
    return self;
}

- (void)viewDidLoad
{
    tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [scrollview addGestureRecognizer:tap];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self initGenderGroup];
    [pickerView addTarget:self
                   action:@selector(onTouchUpDatePicker:)
         forControlEvents:UIControlEventValueChanged];
//    [self loadProfile];
    
    [pickerView setMaximumDate:[[NSDate alloc] init]];
    
    scrollview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    avatarPicker = [[PickPhotoFromGarelly alloc] initWithParentWindow:self andDelegate:self];
    
    [self initAvatarImage];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self initSaveButton];
}

-(void)initSaveButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 37, 31);
    [btn setImage:[UIImage imageNamed:@"header_btn_save.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"header_btn_save_pressed.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=Item;
}

- (void)initAvatarImage
{
}

-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)showNotifications
{
    AppDelegate* appDel = (id) [UIApplication sharedApplication].delegate;
    int totalNotifications = [appDel countTotalNotifications];
    
    [[self navBarOakClub] setNotifications:totalNotifications];
}

-(void)viewWillAppear:(BOOL)animated{
//    [self updateProfileItemListAtIndex:profileObj.s_Name andIndex:NAME];
//    [self updateProfileItemListAtIndex:profileObj.s_school andIndex:SCHOOL];
//    [self updateProfileItemListAtIndex:profileObj.s_aboutMe andIndex:ABOUT_ME];
   
    [tbEditProfile reloadData];
//    [self loadProfile];
    [self showNotifications];
}

-(void)setDefaultEditProfile:(Profile*)profile{
    profileObj = [[Profile alloc]init];
    profileObj = [profile copy];
    [self loadProfile];
}

-(void)loadProfile{
    for (NSDictionary * object in appDelegate.relationshipList) {
        if ([[object valueForKey:@"rel_status_id"] integerValue] == profileObj.s_relationShip.rel_status_id) {
            profileObj.s_relationShip.rel_text = [object valueForKey:@"rel_text"];
            [self updateProfileItemListAtIndex:profileObj.s_relationShip.rel_text andIndex:RELATIONSHIP];
        }
    }
    if(profileObj.s_relationShip.rel_text.length == 0){
        [self updateProfileItemListAtIndex:@"" andIndex:RELATIONSHIP];
    }
    [self updateProfileItemListAtIndex:profileObj.s_location.name andIndex:LOCATION];
        [self updateProfileItemListAtIndex:profileObj.s_ethnicity andIndex:ETHNICITY];
    for (NSDictionary * object in appDelegate.workList) {
        if ([[object valueForKey:@"cate_id"] integerValue] == profileObj.i_work.cate_id) {
            profileObj.i_work.cate_name = [object valueForKey:@"cate_name"];
            [self updateProfileItemListAtIndex:profileObj.i_work.cate_name andIndex:WORK];
        }
    }
    if(profileObj.i_work.cate_name.length == 0){
        [self updateProfileItemListAtIndex:@"" andIndex:RELATIONSHIP];
    }

    profileObj.s_gender.text = [NSString localizeString:profileObj.s_gender.text];
    AFHTTPClient *request;
    NSString* link = profileObj.s_Avatar;
    if(![link isEqualToString:@""]){
        if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
        {       // check if this is a valid link
            request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
            [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                [imgAvatar setBackgroundImage:[UIImage imageWithData:JSON] forState:UIControlStateNormal];
                [imgAvatar setContentMode:UIViewContentModeScaleAspectFit];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
            }];
        }
        else{
            request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
            [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                [imgAvatar setBackgroundImage:[UIImage imageWithData:JSON] forState:UIControlStateNormal];
                [imgAvatar setContentMode:UIViewContentModeScaleAspectFit];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
            }];
        }
    }

    [self updateProfileItemListAtIndex:[profileObj.a_language componentsJoinedByString:@", "] andIndex:LANGUAGE];

    [self updateProfileItemListAtIndex:profileObj.s_birthdayDate andIndex:BIRTHDATE];
    

//    [profileItemList replaceObjectAtIndex:GENDER withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_gender.text,@"value",@"Gender",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_gender.text andIndex:GENDER];

//    textFieldName.text = profileObj.s_Name;
//    [profileItemList replaceObjectAtIndex:NAME withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_Name,@"value",@"Name",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_Name andIndex:NAME];
    
//    textfieldSchool.text = profileObj.s_school;
//    [profileItemList replaceObjectAtIndex:SCHOOL withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_school==nil?@"":profileObj.s_school,@"value",@"School",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_school andIndex:SCHOOL];
    
//    textFieldWeight.text =[NSString stringWithFormat:@"%i", profileObj.i_weight];
//    [profileItemList replaceObjectAtIndex:WEIGHT withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i", profileObj.i_weight],@"value",@"Weight",@"key", nil]];
    [self updateProfileItemListAtIndex:[NSString stringWithFormat:@"%i", profileObj.i_weight] andIndex:WEIGHT];
    
//    textFieldHeight.text =[NSString stringWithFormat:@"%i", profileObj.i_height];
//    [profileItemList replaceObjectAtIndex:HEIGHT withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i", profileObj.i_height],@"value",@"Height",@"key", nil]];
    [self updateProfileItemListAtIndex:[NSString stringWithFormat:@"%i", profileObj.i_height] andIndex:HEIGHT];
    
//    textviewAbout.text = profileObj.s_aboutMe;
//    [profileItemList replaceObjectAtIndex:ABOUT_ME withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_aboutMe,@"value",@"About me",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_aboutMe andIndex:ABOUT_ME];
    [self.tbEditProfile reloadData];
    
    [self updateProfileItemListAtIndex:@"NO" andIndex:AUTO_LOCATION];
}
//-(void) initGenderGroup{
//    genderGroup = [[GroupButtons alloc] initWithMultipleChoice:FALSE];
//    [genderGroup addButton:rbnMale atIndex:0];
//    [genderGroup addButton:rbnFemale atIndex:1];
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRbnMale:nil];
    [self setRbnFemale:nil];
    [self setBtnRelationShip:nil];
    [self setBtnLocation:nil];
    [self setBtnEthnicity:nil];
    [self setBtnLanguage:nil];
    [self setBtnWork:nil];
    [self setTextfieldSchool:nil];
    [self setScrollview:nil];
    [self setTextFieldHeight:nil];
    [self setTextFieldWeight:nil];
    [self setTextFieldName:nil];
    [self setLabelAge:nil];
    [self setLabelPurposeSearch:nil];
    [self setLabelName:nil];
    [self setBtnBirthdate:nil];
    [self setImgAvatar:nil];
    [self setPickerView:nil];
    [self setTextviewAbout:nil];
    [self setTbEditProfile:nil];
    [self setPickerWeight:nil];
    [self setPickerHeight:nil];
    [super viewDidUnload];
}

-(void)gotoGenderSetting{
    ListForChoose *genderView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [genderView setListType:LISTTYPE_GENDER];
    genderView.delegate=self;
    [self.navigationController pushViewController:genderView animated:YES];
}
- (void)gotoRelatioshipSetting{
    ListForChoose *relationshipView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [relationshipView setListType:LISTTYPE_RELATIONSHIP];
    relationshipView.delegate=self;
    [self.navigationController pushViewController:relationshipView animated:YES];
}

- (void)gotoLocationSetting
{
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
}

- (void) tryUpdateLocation
{
    [locationManager startUpdatingLocation];
}

- (void)gotoEthnicitySetting{
    ListForChoose *ethnicityView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [ethnicityView setListType:LISTTYPE_ETHNICITY];
    ethnicityView.delegate=self;
    [self.navigationController pushViewController:ethnicityView animated:YES];
}

- (void)gotoLanguageSetting{
    ListForChoose *languageView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [languageView setListType:LISTTYPE_LANGUAGE];
    languageView.delegate=self;
    [self.navigationController pushViewController:languageView animated:YES];
}

- (void)gotoWorkSetting{
    ListForChoose *workView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [workView setListType:LISTTYPE_WORK];
    workView.delegate = self;
    [self.navigationController pushViewController:workView animated:YES];
}

- (void)gotoAboutEditText{
    EditText *aboutmeView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [aboutmeView initForEditting:profileObj.s_aboutMe andStyle:2];
//    [workView setListType:LISTTYPE_WORK];
    aboutmeView.delegate = self;
    [self.navigationController pushViewController:aboutmeView animated:YES];
}

- (void)gotoNameEditText{
    EditText *nameEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [nameEditView initForEditting:profileObj.s_Name andStyle:0];
    nameEditView.delegate = self;
    [self.navigationController pushViewController:nameEditView animated:YES];
}
- (void)gotoSchoolEditText{
    EditText *schoolEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [schoolEditView initForEditting:profileObj.s_school andStyle:1];
    schoolEditView.delegate = self;
    [self.navigationController pushViewController:schoolEditView animated:YES];
}
- (void)onTouchBirthdate {
    if (pickerView.hidden) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *birth = [dateFormat dateFromString:profileObj.s_birthdayDate];
        [pickerView setDate:birth animated:YES];
        CGPoint bottomOffset = CGPointMake(0, 170);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerView setHidden:NO];
        [[scrollview.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:YES];
    }
    
}
- (void)onTouchWeight {
    if (pickerWeight.hidden) {
        [self initWeightList];
        CGPoint bottomOffset = CGPointMake(0, 360);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerWeight setHidden:NO];
    }
    
}
- (void)onTouchHeight {
    if (pickerHeight.hidden) {
        [self initHeightList];
        CGPoint bottomOffset = CGPointMake(0, 360);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerHeight setHidden:NO];
    }
    
}
- (IBAction)onTouchRelatioship:(id)sender {
    ListForChoose *relationshipView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [relationshipView setListType:LISTTYPE_RELATIONSHIP];
    relationshipView.delegate=self;
    [self.navigationController pushViewController:relationshipView animated:YES];
}

- (IBAction)onTouchLocation:(id)sender {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
}
- (IBAction)onTouchEthnicity:(id)sender {
    ListForChoose *ethnicityView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [ethnicityView setListType:LISTTYPE_ETHNICITY];
    ethnicityView.delegate=self;
    [self.navigationController pushViewController:ethnicityView animated:YES];
}

- (IBAction)onTouchLanguage:(id)sender {
    ListForChoose *languageView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [languageView setListType:LISTTYPE_LANGUAGE];
    languageView.delegate=self;
    [self.navigationController pushViewController:languageView animated:YES];
}

- (IBAction)onTouchWork:(id)sender {
    ListForChoose *workView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [workView setListType:LISTTYPE_WORK];
    workView.delegate = self;
    [self.navigationController pushViewController:workView animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
-(BOOL) textViewShouldReturn:(UITextView *)textView{
    
    [textView resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField
{
    CGPoint bottomOffset = CGPointMake(0, textField.frame.origin.y - 100);
    [scrollview setContentOffset:bottomOffset animated:YES];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *) textView
{
    CGPoint bottomOffset = CGPointMake(0, textView.frame.origin.y - 80);
    [scrollview setContentOffset:bottomOffset animated:YES];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}
- (IBAction)onTouchBirthdate:(id)sender {
    if (pickerView.hidden) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *birth = [dateFormat dateFromString:profileObj.s_birthdayDate];
        [pickerView setDate:birth animated:YES];
        CGPoint bottomOffset = CGPointMake(0, 110);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerView setHidden:NO];
    }
    else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSString *theDate = [dateFormat stringFromDate:self.pickerView.date];
        [btnBirthdate setTitle:theDate forState:UIControlStateNormal];
        profileObj.s_birthdayDate = theDate;
        [pickerView setHidden:YES];
    }
}

-(void)saveSettingWithWarning:(BOOL)warning
{
    appDelegate.myProfile = [profileObj copy];
    [appDelegate.myProfile SaveSetting];
    
    if (warning)
    {
        [self showWarning:@"Profile saved"];
    }
}

- (void)showWarning:(NSString*)warningText{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:warningText
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *alertIndex = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([alertIndex isEqualToString:@"OK"])
    {
        //Do something
//        [appDel showHangOut];
    }
}
#pragma mark DatePicker DataSource/Delegate

-(IBAction)onTouchUpDatePicker:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *theDate = [dateFormat stringFromDate:self.pickerView.date];
    profileObj.s_birthdayDate = theDate;
    [self updateProfileItemListAtIndex:theDate andIndex:BIRTHDATE];
    [tbEditProfile reloadData];
}
#pragma mark Picker DataSource/Delegate
-(void) initWeightList{
    NSMutableArray *weightlist = [NSMutableArray array];
    for(int i =MIN_WEIGHT; i <= MAX_WEIGHT; i++){
        [weightlist addObject:[NSString stringWithFormat:@"%d kg",i] ];
    }
    weightOptionList =  weightlist;
    [pickerWeight reloadAllComponents];
    NSInteger selecteRow = (profileObj.i_height - MIN_WEIGHT);
    [pickerWeight selectRow:(selecteRow<0?0:selecteRow) inComponent:0 animated:NO];
}
-(void) initHeightList{
    NSMutableArray *heightlist = [NSMutableArray array];
    for(int i =MIN_HEIGHT; i <= MAX_HEIGHT; i++){
        [heightlist addObject:[NSString stringWithFormat:@"%d cm",i] ];
    }
    heightOptionList =  heightlist;
    [pickerHeight reloadAllComponents];
    NSInteger selecteRow = (profileObj.i_height - MIN_HEIGHT);
    [pickerHeight selectRow:(selecteRow<0?0:selecteRow) inComponent:0 animated:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == pickerWeight)
        return [weightOptionList count];
    else
        return [heightOptionList count];
}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//
//        return 70.0;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == pickerWeight)
        return [weightOptionList objectAtIndex:row];
    else
        return [heightOptionList objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == pickerWeight){
        profileObj.i_weight = [[weightOptionList objectAtIndex:row] integerValue];
        [self updateProfileItemListAtIndex:[NSString stringWithFormat:@"%i", profileObj.i_weight] andIndex:WEIGHT];
    }
    else{
        profileObj.i_height = [[heightOptionList objectAtIndex:row] integerValue];
        [self updateProfileItemListAtIndex:[NSString stringWithFormat:@"%i", profileObj.i_height] andIndex:HEIGHT];
    }
    [tbEditProfile reloadData];
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    switch ([uvcList getType]) {
        case LISTTYPE_RELATIONSHIP:
            profileObj.s_relationShip = selected.s_relationShip;
            [self updateProfileItemListAtIndex:profileObj.s_relationShip.rel_text andIndex:RELATIONSHIP];
            break;
        case LISTTYPE_CITY:
            profileObj.s_location = selected.s_location;
            [self updateProfileItemListAtIndex:profileObj.s_location.name andIndex:LOCATION];
            break;
        case LISTTYPE_GENDER:
            profileObj.s_gender = selected.s_gender;
            [self updateProfileItemListAtIndex:profileObj.s_gender.text andIndex:GENDER];
            break;
        case LISTTYPE_WORK:
            profileObj.i_work = selected.i_work;
            [self updateProfileItemListAtIndex:profileObj.i_work.cate_name andIndex:WORK];
            break;
        case LISTTYPE_ETHNICITY:
            profileObj.s_ethnicity = selected.s_ethnicity;
            [self updateProfileItemListAtIndex:profileObj.s_ethnicity andIndex:ETHNICITY];
            break;
        case LISTTYPE_LANGUAGE:
            profileObj.a_language = selected.a_language;
            [self updateProfileItemListAtIndex:[profileObj.a_language componentsJoinedByString:@", "] andIndex:LANGUAGE];
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
    [tbEditProfile reloadData];
}
-(Profile *)setDefaultValue:(ListForChoose *)uvcList{
    return profileObj;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (textField.text.length >= MAXLENGTH_NAME && range.length == 0) {
        return NO; // Change not allowed
    } else {
        return YES; // Change allowed
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length >= MAXLENGTH_ABOUT && range.length == 0) {
        return NO; // Change not allowed
    } else {
        return YES; // Change allowed
    }
}
- (void)dismissKeyboard {
    if(pickerWeight.hidden&& pickerView.hidden && pickerHeight.hidden)
        [[scrollview.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:NO];
    else
        [[scrollview.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:YES];
    [textFieldName resignFirstResponder];
    [textfieldSchool resignFirstResponder];
    [textFieldWeight resignFirstResponder];
    [textFieldHeight resignFirstResponder];
    [textviewAbout resignFirstResponder];
    [pickerView setHidden:YES];
    [pickerWeight setHidden:YES];
    [pickerHeight setHidden:YES];
    
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
    return [profileItemList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:MyIdentifier];
	}
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];

    // Configure the cell...
    NSString *textLabel =[[profileItemList objectAtIndex:indexPath.row] valueForKey:@"key"];
    cell.textLabel.text = [NSString localizeString:textLabel];
    switch (indexPath.row) {
        case WEIGHT:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ kg",[[profileItemList objectAtIndex:indexPath.row] valueForKey:@"value"]] ;
            break;
        case HEIGHT:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ cm",[[profileItemList objectAtIndex:indexPath.row] valueForKey:@"value"]] ;
            break;
        case AUTO_LOCATION:
        {
            static NSString *AutoLocationID = @"ALID";
            UITableViewCell *autoLocationCell = [tableView dequeueReusableCellWithIdentifier:AutoLocationID];
            if (autoLocationCell == nil)
            {
                autoLocationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoLocationID];
                autoLocationCell.textLabel.text = [NSString localizeString:@"Auto location"] ;
                autoLocationCell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *autoSwitch = [[UISwitch alloc] init];
                [autoSwitch addTarget:self action:@selector(switchAutoUpdateLocation:) forControlEvents:UIControlEventValueChanged];
                autoSwitch.frame = CGRectMake(cell.frame.size.width - autoSwitch.frame.size.width - 30, (cell.frame.size.height - autoSwitch.frame.size.height) / 2, autoSwitch.frame.size.width, autoSwitch.frame.size.height);
                autoSwitch.tag = 100;
                [autoLocationCell.contentView addSubview:autoSwitch];
            }
            {
                UISwitch *autoSwitch = (id) [autoLocationCell viewWithTag:100];
                autoSwitch.on = [[[profileItemList objectAtIndex:indexPath.row] valueForKey:@"value"] isEqualToString:@"YES"];
            }
            
            return autoLocationCell;
        }
            break;
        case LOCATION:
            if ([[[profileItemList objectAtIndex:AUTO_LOCATION] valueForKey:@"value"] isEqualToString:@"YES"])
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        default:
            cell.detailTextLabel.text = [[profileItemList objectAtIndex:indexPath.row] valueForKey:@"value"];
            break;
    }
    
    [cell.detailTextLabel setFont: FONT_NOKIA(17.0)];
    [cell.textLabel setFont: FONT_NOKIA(17.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case RELATIONSHIP:
            [self gotoRelatioshipSetting];
            break;
        case GENDER:
            [self gotoGenderSetting];
            break;
        case ETHNICITY:
            [self gotoEthnicitySetting];
            break;
        case AUTO_LOCATION:
            break;
        case LOCATION:
        {
            NSString *autoLoc = [[profileItemList objectAtIndex:AUTO_LOCATION] valueForKey:@"value"];
            if (![autoLoc isEqualToString:@"YES"])
            {
                [self gotoLocationSetting];
            }
            else
            {
                [self tryUpdateLocation];
            }
        }
            //[self tryUpdateLocation];
            break;
        case WORK:
            [self gotoWorkSetting];
            break;
        case LANGUAGE:
            [self gotoLanguageSetting];
            break;
        case ABOUT_ME:
            [self gotoAboutEditText];
            break;
        case NAME:
            [self gotoNameEditText];
            break;
        case SCHOOL:
            [self gotoSchoolEditText];
            break;
        case BIRTHDATE:
            [self onTouchBirthdate];
            break;
        case WEIGHT:
            [self onTouchWeight];
            break;
        case HEIGHT:
            [self onTouchHeight];
            break;
        default:
            break;
    }
}

-(void)updateProfileItemListAtIndex:(NSString*)value andIndex:(EditItems)keyEnum{
    [profileItemList replaceObjectAtIndex:keyEnum withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:(value==nil || [value isKindOfClass:[NSNull class]])?@"":value,@"value",[MyProfileItemList objectAtIndex:keyEnum],@"key", nil]];
    
}
- (void)saveChangedEditting:(EditText *)editObject{
    switch (editObject.getStyle) {
        case 2:
            profileObj.s_aboutMe = editObject.textviewEdit.text;
            [self updateProfileItemListAtIndex:editObject.textviewEdit.text andIndex:ABOUT_ME];
            break;
        case 0:
            profileObj.s_Name = editObject.texfieldEdit.text;
            [self updateProfileItemListAtIndex:editObject.texfieldEdit.text andIndex:NAME];
            break;
        case 1:
            profileObj.s_school = editObject.texfieldEdit.text;
            [self updateProfileItemListAtIndex:editObject.texfieldEdit.text andIndex:SCHOOL];
            break;
        default:
            break;
    }
}

#pragma mark CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [manager stopUpdatingLocation];
    
    //[self gotoLocationSetting];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Stop Location Manager
    [manager stopUpdatingLocation];
    
    /*if (currentLocation != nil) {
        //longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        NSLog(@"Resolving the Address");
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
                NSString *location = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                     placemark.subThoroughfare, placemark.thoroughfare,
                                     placemark.postalCode, placemark.locality,
                                     placemark.administrativeArea,
                                     placemark.country];
                //Message update location automatically
                //Update or goto Location Setting
                [[profileItemList objectAtIndex:LOCATION] setObject:location forKey:@"value"];
                [self.tableView reloadData];
                NSLog(@"Location %@", location);
            } else {
                NSLog(@"Can't resolve location with error:%@", error.debugDescription);
                //[self gotoLocationSetting];
            }
            
            
        } ];
    }
    else
    {
        //[self gotoLocationSetting];
    }*/
    
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
    NSLog(@"Coord: %@", params);
    
    [request getPath:URL_setLocationUser parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Update location: %@", dict);
         profileObj.s_location.ID = [dict valueForKey:key_data];
         profileObj.s_location.name = [dict valueForKey:key_msg];
         [self updateProfileItemListAtIndex:profileObj.s_location.name andIndex:LOCATION];
         [self.tableView reloadData];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Set user location error Code: %i - %@",[error code], [error localizedDescription]);
     }];
}

#pragma mark Switch Delegate

- (void)switchAutoUpdateLocation:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    [[profileItemList objectAtIndex:AUTO_LOCATION] setValue:rez forKey:@"value"];
    
    [self tryUpdateLocation];
    [self.tableView reloadData];
}

- (IBAction)avatarTouched:(id)sender
{
    [avatarPicker showPicker];
}

-(void)receiveImage:(UIImage *)image
{
    if (image)
    {
        [self.imgAvatar setBackgroundImage:image forState:UIControlStateNormal];
    }
}

@end
