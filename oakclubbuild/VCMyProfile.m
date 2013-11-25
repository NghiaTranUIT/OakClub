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
#import "PhotoUpload.h"
#import "NSString+Utils.h"
#import "PhotoScrollView.h"
#import "UIView+Localize.h"
#import "LocationUpdate.h"
#import "VideoPicker.h"
#import "VideoUploader.h"
#import "LoadingIndicator.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VCMyProfile () <PickPhotoFromGarellyDelegate, VideoPickerDelegate, UIAlertViewDelegate, ImageRequester, PhotoScrollViewDelegate, LocationUpdateDelegate, LoadingIndicatorDelegate>
{
    GroupButtons* genderGroup;
    AppDelegate *appDelegate;
    NSMutableArray *profileItemList;
    NSArray *weightOptionList;
    NSArray *heightOptionList;
    Profile* profileObj;
    PickPhotoFromGarelly *avatarPicker;
    UIImage *avatarImage;
    UIImage *newAvatarImage;
    NSMutableArray *photos;
    NSMutableArray *photosID;
    int selectedPhoto;
    UIImage *uploadImage;
    LocationUpdate *locUpdate;
    VideoPicker *videoPicker;
    LoadingIndicator *indicator,*photo_Indicator;
}
@property (weak, nonatomic) IBOutlet UIView *photoSuperView;
@property (weak, nonatomic) IBOutlet PhotoScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarLayout;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *age_workLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnUploadVideo;
@property (strong, nonatomic) IBOutlet UIView *pickingView;
@property (strong, nonatomic) IBOutlet UIViewController *pickingViewController;
@property (weak, nonatomic) IBOutlet UILabel *lblPickingValue;
@end

@implementation VCMyProfile
UITapGestureRecognizer *tap;

@synthesize rbnFemale, rbnMale, btnLocation, btnRelationShip, btnEthnicity, btnLanguage, btnWork, scrollview,labelAge, labelName, labelPurposeSearch, textFieldName,textFieldHeight,textfieldSchool,textFieldWeight, btnBirthdate, pickerView, textviewAbout, tbEditProfile, pickerWeight, pickerHeight, imgAvatar;

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
    
    locUpdate = [[LocationUpdate alloc] init];
    locUpdate.delegate = self;
    
    avatarPicker = [[PickPhotoFromGarelly alloc] initWithParentWindow:self andDelegate:self];
    videoPicker = [[VideoPicker alloc] initWithParentWindow:self andDelegate:self];
    
    self.photoScrollView.photoDelegate = self;
    
    indicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:self];
    photo_Indicator = [[LoadingIndicator alloc] initWithMainView:self.photoSuperView andDelegate:self];
    
    photos = [[NSMutableArray alloc] init];
    photosID = [[NSMutableArray alloc] init];
    [self reloadPhotos];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.nameLabel.text = profileObj.s_Name;
    self.age_workLabel.text = [NSString stringWithFormat:@"%d", profileObj.age];
    self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", profileObj.i_work.cate_name, profileObj.s_location.name];
    
    [self.imgAvatar setBackgroundImage:avatarImage forState:UIControlStateNormal];
    self.imgAvatar.contentMode = UIViewContentModeScaleAspectFit;
    [self.imgAvatar setFrame:self.avatarLayout.frame];
    
    [profileObj tryGetImageAsync:self];
    
    UIImage *thumb;
    if ((thumb = self.videoThumb))
    {
        [self.btnUploadVideo setBackgroundImage:thumb forState:UIControlStateNormal];
        self.btnUploadVideo.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [self.view localizeAllViews];
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
    [[self navBarOakClub] setHeaderName:[NSString localizeString:@"Edit Profile"]];
}

-(void)setDefaultEditProfile:(Profile*)profile{
    profileObj = [[Profile alloc]init];
    profileObj = [profile copy];
    [self loadProfile];
}

-(void)setImage:(UIImage *)img
{
    avatarImage = img;
}

-(void)loadProfile
{
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
    //[self updateProfileItemListAtIndex:profileObj.c_ethnicity.text andIndex:ETHNICITY];
    for (NSDictionary * object in appDelegate.ethnicityList) {
        if ([[object valueForKey:@"id"] integerValue] == profileObj.c_ethnicity.ID) {
            profileObj.c_ethnicity.name = [object valueForKey:@"name"];
            [self updateProfileItemListAtIndex:profileObj.c_ethnicity.name andIndex:ETHNICITY];
        }
    }
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
    [profileObj tryGetImageAsync:self];
    for (int i =0 ; i < [profileObj.a_language count]; i++) {
        [[profileObj.a_language objectAtIndex:i] localizeNameOfLanguage];
        //        [profileObj.a_language replaceObjectAtIndex:i withObject:[NSString localizeString:profileObj.a_language[i]]];
    }
    [self updateProfileItemListAtIndex:profileObj.languagesDescription andIndex:LANGUAGE];
    
    [self updateProfileItemListAtIndex:profileObj.s_birthdayDate andIndex:BIRTHDATE];
    
    
    //    [profileItemList replaceObjectAtIndex:GENDER withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_gender.text,@"value",@"Gender",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_gender.text andIndex:GENDER];
    
    [self updateProfileItemListAtIndex:profileObj.s_interested.text andIndex:INTERESTED_IN];
    
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
    
    [self updateProfileItemListAtIndex:profileObj.s_Email andIndex:EMAIL];
    
    //    textviewAbout.text = profileObj.s_aboutMe;
    //    [profileItemList replaceObjectAtIndex:ABOUT_ME withObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:profileObj.s_aboutMe,@"value",@"About me",@"key", nil]];
    [self updateProfileItemListAtIndex:profileObj.s_aboutMe andIndex:ABOUT_ME];
    [self.tbEditProfile reloadData];
    
    selectedPhoto = -1;
    uploadImage = nil;
    [self loadProfilePhotos];
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

-(void)gotoInterestedSetting{
    ListForChoose *intersetedView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [intersetedView setListType:LISTTYPE_INTERESTED];
    intersetedView.delegate=self;
    [self.navigationController pushViewController:intersetedView animated:YES];
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
    //    [profileObj.a_language removeAllObjects];
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
    [aboutmeView setTitle:@"About me"];
    aboutmeView.delegate = self;
    [self.navigationController pushViewController:aboutmeView animated:YES];
}

- (void)gotoNameEditText{
    EditText *nameEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [nameEditView initForEditting:profileObj.s_Name andStyle:0];
    [nameEditView setTitle:@"Name"];
    nameEditView.delegate = self;
    [self.navigationController pushViewController:nameEditView animated:YES];
}

- (void)gotoEmail{
    EditText *emailEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [emailEditView initForEditting:profileObj.s_Email andStyle:3];
    [emailEditView setTitle:@"Email"];
    emailEditView.delegate = self;
    [self.navigationController pushViewController:emailEditView animated:YES];
}
- (void)gotoSchoolEditText{
    EditText *schoolEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [schoolEditView initForEditting:profileObj.s_school andStyle:1];
    [schoolEditView setTitle:@"School"];
    schoolEditView.delegate = self;
    [self.navigationController pushViewController:schoolEditView animated:YES];
}
- (void)onTouchBirthdate {
    if (pickerView.hidden) {
        [self.pickingViewController setTitle:@"Birthday"];
        [self.navigationController pushViewController:self.pickingViewController animated:YES];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *birth = [dateFormat dateFromString:profileObj.s_birthdayDate];
        [pickerView setDate:birth animated:YES];
        CGPoint bottomOffset = CGPointMake(0, 170);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerView setHidden:NO];
        [[scrollview.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:YES];
        self.lblPickingValue.text = profileObj.s_birthdayDate;
    }
    
}
- (void)onTouchWeight {
    if (pickerWeight.hidden) {
        [self.pickingViewController setTitle:@"Weight"];
        [self.navigationController pushViewController:self.pickingViewController animated:YES];
        [self initWeightList];
        CGPoint bottomOffset = CGPointMake(0, 360);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerWeight setHidden:NO];
    }
    
}
- (void)onTouchHeight {
    if (pickerHeight.hidden) {
        [self.pickingViewController setTitle:@"Height"];
        [self.navigationController pushViewController:self.pickingViewController animated:YES];
        [self initHeightList];
        CGPoint bottomOffset = CGPointMake(0, 360);
        [scrollview setContentOffset:bottomOffset animated:YES];
        [pickerHeight setHidden:NO];
    }
    
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

-(void)doneButtonTouched:(id)doneButton
{
    [self saveSettingWithWarning:YES];
}

-(void)saveSettingWithWarning:(BOOL)warning
{
    appDelegate.myProfile = [profileObj copy];
    [indicator lockViewAndDisplayIndicator];
    [appDelegate.myProfile saveSettingWithCompletion:^(bool isSuccess) {
        [indicator unlockViewAndStopIndicator];
        if (warning)
        {
            if (isSuccess)
            {
                [self showWarning:@"Profile saved" withTag:0];
            }
            else
            {
                // TRANSLATE
                [self showWarning:@"Cannot save profile" withTag:0];
            }
        }
    }];
}

- (void)showOKCancelWarning:(NSString*)warningText withTag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[@"Message" localize]
                          message:warningText
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:@"Cancel", nil];
    alert.tag = tag;
    
    [alert localizeAllViews];
    [alert show];
}

- (void)showWarning:(NSString*)warningText withTag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[@"Message" localize]
                          message:warningText
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    alert.tag = tag;
    
    [alert localizeAllViews];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) // save profile
    {
        
    }
    else if (alertView.tag == 1) // delete photo
    {
        if (buttonIndex == 0 && selectedPhoto >= 0)
        {
            [indicator lockViewAndDisplayIndicator];
            AFHTTPClient *client = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
            [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
            [client setParameterEncoding:AFFormURLParameterEncoding];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[photosID objectAtIndex:selectedPhoto], @"photo_id", nil];
            NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_deletePhoto parameters:params];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"Delete photo result %@", result);
                bool status = [[result valueForKey:key_status] boolValue];
                if (status)
                {
                    [photos removeObjectAtIndex:selectedPhoto];
                    [photosID removeObjectAtIndex:selectedPhoto];
                    [self reloadPhotos];
                }
                else
                {
                    [self showWarning:@"Cannnot delete this photo." withTag:5];
                }
                selectedPhoto = -1;
                
                [indicator unlockViewAndStopIndicator];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Delete photo error %@", error);
                selectedPhoto = -1;
                
                [indicator unlockViewAndStopIndicator];
            }];
            
            [operation start];
        }
        else
        {
            selectedPhoto = -1;
        }
    }
    else if (alertView.tag == 2) // upload photo
    {
        if (buttonIndex == 0 && selectedPhoto >= 0 && uploadImage != nil)
        {
            NSData *uploadData = UIImagePNGRepresentation(uploadImage);
            if ([uploadData length] >= MAX_UPLOAD_SIZE)
            {
                UIAlertView *maxSizeAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The maximum size of photo is 3MB" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [maxSizeAlert localizeAllViews];
                
                [maxSizeAlert show];
            }
            else
            {
                bool isAvatar = (selectedPhoto == photosID.count + 2);
                PhotoUpload *uploader = [[PhotoUpload alloc] initWithPhoto:uploadData andName:@"uploadedfile" isAvatar:isAvatar];
                [indicator lockViewAndDisplayIndicator];
                [uploader uploadPhotoWithCompletion:^(NSString *imgLink, NSString *imgID, BOOL _isAvatar)
                 {
                     if (imgID)
                     {
                         if (_isAvatar)
                         {
                             [self.imgAvatar setBackgroundImage:uploadImage forState:UIControlStateNormal];
                             self.imgAvatar.contentMode = UIViewContentModeScaleAspectFit;
                             [self.imgAvatar setFrame:self.avatarLayout.frame];
                             
                             UIImage *thumb;
                             if ((thumb = self.videoThumb))
                             {
                                 [self.btnUploadVideo setBackgroundImage:thumb forState:UIControlStateNormal];
                                 self.btnUploadVideo.contentMode = UIViewContentModeScaleAspectFit;
                             }
                             
                             profileObj.img_Avatar = uploadImage;
                             profileObj.s_Avatar = imgLink;
                         }
                         
                         [photos addObject:uploadImage];
                         [photosID addObject:imgID];
                         
                         [self reloadPhotos];
                     }
                     
                     uploadImage = nil;
                     selectedPhoto = -1;
                     [indicator unlockViewAndStopIndicator];
                 }];
            }
        }
        else
        {
            uploadImage = nil;
            selectedPhoto = -1;
        }
    }
    else if (alertView.tag == 4)
    {
        if (buttonIndex == 0)
        {
            [videoPicker showPicker];
        }
        else
        {
            [self playVideo];
        }
    }
}

#pragma mark DatePicker DataSource/Delegate

-(IBAction)onTouchUpDatePicker:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *theDate = [dateFormat stringFromDate:self.pickerView.date];
    profileObj.s_birthdayDate = theDate;
    [self updateProfileItemListAtIndex:theDate andIndex:BIRTHDATE];
    self.lblPickingValue.text = theDate;
    [tbEditProfile reloadData];
    
    // hook
    self.age_workLabel.text = [NSString stringWithFormat:@"%d, %@", profileObj.age, profileObj.i_work.cate_name];
}
#pragma mark Picker DataSource/Delegate
-(void) initWeightList{
    NSMutableArray *weightlist = [NSMutableArray array];
    [weightlist addObject:@"0 kg"];
    for(int i =MIN_WEIGHT; i <= MAX_WEIGHT; i++){
        [weightlist addObject:[NSString stringWithFormat:@"%d kg",i] ];
    }
    weightOptionList =  weightlist;
    [pickerWeight reloadAllComponents];
    NSInteger selecteRow = (profileObj.i_weight == 0)?0:(profileObj.i_weight - MIN_WEIGHT + 1);
    [pickerWeight selectRow:(selecteRow<0?0:selecteRow) inComponent:0 animated:NO];
    self.lblPickingValue.text = [weightlist objectAtIndex:selecteRow];
}
-(void) initHeightList{
    NSMutableArray *heightlist = [NSMutableArray array];
    [heightlist addObject:@"0 cm"];
    for(int i = MIN_HEIGHT; i <= MAX_HEIGHT; i++){
        [heightlist addObject:[NSString stringWithFormat:@"%d cm",i] ];
    }
    heightOptionList =  heightlist;
    [pickerHeight reloadAllComponents];
    NSInteger selecteRow = (profileObj.i_height == 0)?0:(profileObj.i_height - MIN_HEIGHT + 1);
    [pickerHeight selectRow:(selecteRow<0?0:selecteRow) inComponent:0 animated:NO];
    self.lblPickingValue.text = [heightlist objectAtIndex:selecteRow];
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
        self.lblPickingValue.text = [NSString stringWithFormat:@"%i kg", profileObj.i_weight];
    }
    else{
        profileObj.i_height = [[heightOptionList objectAtIndex:row] integerValue];
        [self updateProfileItemListAtIndex:[NSString stringWithFormat:@"%i", profileObj.i_height] andIndex:HEIGHT];
        self.lblPickingValue.text = [NSString stringWithFormat:@"%i cm", profileObj.i_height];
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
        case LISTTYPE_INTERESTED:
            profileObj.s_interested = selected.s_interested;
            [self updateProfileItemListAtIndex:profileObj.s_interested.text andIndex:INTERESTED_IN];
            break;
        case LISTTYPE_WORK:
            profileObj.i_work = selected.i_work;
            [self updateProfileItemListAtIndex:profileObj.i_work.cate_name andIndex:WORK];
            break;
        case LISTTYPE_ETHNICITY:
            profileObj.c_ethnicity = selected.c_ethnicity;
            [self updateProfileItemListAtIndex:profileObj.c_ethnicity.name andIndex:ETHNICITY];
            break;
        case LISTTYPE_LANGUAGE:
            profileObj.a_language = selected.a_language;
            [self updateProfileItemListAtIndex:profileObj.languagesDescription andIndex:LANGUAGE];
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
-(Profile *)setDefaultValue:(ListForChoose *)uvcList
{
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
    return [profileItemList count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row < profileItemList.count)?44:88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    static NSString *DoneID = @"DoneButtonIndentifier";
	
    if (indexPath.row >= [profileItemList count])
    {
        UITableViewCell *doneCell = [tableView dequeueReusableCellWithIdentifier:DoneID];
        if (!doneCell)
        {
            doneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DoneID];
            
            UIButton *doneButton = [[UIButton alloc] init];
            [doneButton setBackgroundImage:[UIImage imageNamed:@"myprofile_doneButton"] forState:UIControlStateNormal];
            [doneButton sizeToFit];
            doneButton.frame = CGRectMake((doneCell.frame.size.width - doneButton.frame.size.width) / 2, (88 - doneButton.frame.size.height) / 2, doneButton.frame.size.width, doneButton.frame.size.height);
            [doneButton setTitle:@"Done" forState:UIControlStateNormal];
            [doneButton.titleLabel setFont:FONT_HELVETICANEUE_LIGHT(15.0)];
            [doneButton addTarget:self action:@selector(doneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [doneCell addSubview:doneButton];
            [doneCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        [doneCell localizeAllViews];
        
        return doneCell;
    }
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:MyIdentifier];
	}
    if(indexPath.row != LOCATION)
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
        default:
            cell.detailTextLabel.text = [[profileItemList objectAtIndex:indexPath.row] valueForKey:@"value"];
            break;
    }
    
    [cell.detailTextLabel setFont:FONT_HELVETICANEUE_LIGHT(17.0)];
    [cell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(17.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    
    [cell localizeAllViews];
    
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
        case INTERESTED_IN:
            [self gotoInterestedSetting];
            break;
        case ETHNICITY:
            [self gotoEthnicitySetting];
            break;
        case EMAIL:
            [self gotoEmail];
            break;
        case LOCATION:
            [locUpdate update];
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
        {
            if (![editObject.texfieldEdit.text isEqualToString:@""])
            {
                profileObj.s_Name = editObject.texfieldEdit.text;
                [self updateProfileItemListAtIndex:editObject.texfieldEdit.text andIndex:NAME];
            }
            else
            {
                [self showWarning:@"Name cannot be empty" withTag:3];
            }
        }
            break;
        case 1:
            profileObj.s_school = editObject.texfieldEdit.text;
            [self updateProfileItemListAtIndex:editObject.texfieldEdit.text andIndex:SCHOOL];
            break;
        case 3:
        {
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+.[a-zA-Z]{2,4}"];
            
            if ([emailTest evaluateWithObject:editObject.texfieldEdit.text])
            {
                [self updateProfileItemListAtIndex:editObject.texfieldEdit.text andIndex:EMAIL];
                profileObj.s_Email = editObject.texfieldEdit.text;
            }
            else
            {
                [self showWarning:@"Email is invalid" withTag:3];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark CLLocation Delegate

-(void)location:(LocationUpdate *)location updateFailWithError:(NSError *)e
{
    
}

-(void)location:(LocationUpdate *)location updateSuccessWithLongitude:(double)longt andLatitude:(double)lati
{
    [location setUserLocationAtLongitude:longt andLatitude:lati useCallback:^(NSString *locationID, NSString *locationName, NSError *err) {
        if (!err)
        {
            profileObj.s_location.longitude = longt;
            profileObj.s_location.latitude = lati;
            profileObj.s_location.ID = locationID;
            profileObj.s_location.name = locationName;
            [self updateProfileItemListAtIndex:profileObj.s_location.name andIndex:LOCATION];
            [self.tableView reloadData];
        }
    }];
}
#pragma mark Switch Delegate

- (IBAction)avatarTouched:(id)sender
{
    if (selectedPhoto < 0 && uploadImage == nil)
    {
        selectedPhoto = photos.count + 2;
        [avatarPicker showPicker];
    }
}

- (IBAction)uploadVideoTouched:(id)sender
{
    if (profileObj.s_video && ![@"" isEqualToString:profileObj.s_video])
    {
        [self showOKCancelWarning:@"Do you want to upload new videos" withTag:4];
    }
    else
    {
        [videoPicker showPicker];
    }
}

-(void)receiveImage:(UIImage *)_image
{
    if (_image)
    {
        uploadImage = _image;
        [self showOKCancelWarning:@"Do you want to upload this photo ?" withTag:2];
    }
    else
    {
        selectedPhoto = -1;
        uploadImage = nil;
    }
}
-(void)receiveVideo:(NSData *)video{
    if(video){
        [indicator lockViewAndDisplayIndicator];
        VideoUploader * uploadVideo = [[VideoUploader alloc]initWithVideoData:video];
        [uploadVideo uploadVideoWithCompletion:^(NSString *link)
         {
             NSLog(@"Video upload completed with link %@", link);
             [indicator unlockViewAndStopIndicator];
             
             profileObj.s_video = link;
             appDelegate.myProfile.s_video = link;
             
             UIImage *thumb;
             if ((thumb = self.videoThumb))
             {
                 [self.btnUploadVideo setBackgroundImage:thumb forState:UIControlStateNormal];
                 self.btnUploadVideo.contentMode = UIViewContentModeScaleAspectFit;
             }
         }];
    }
}

#define H_PADDING 30
#define V_PADDING 2
#define  PHOTO_WIDTH 112
#define  PHOTO_HEIGHT 112
-(void)reloadPhotos
{
    [[self photoScrollView] reloadScrollView];
}

- (void)loadProfilePhotos
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSDictionary *params  = [[NSDictionary alloc]initWithObjectsAndKeys:profileObj.s_ID, key_profileID, nil];
    [request getPath:URL_getListPhotos parameters:params
             success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         [photo_Indicator lockViewAndDisplayIndicator];
         NSMutableDictionary* dictPhotos = [Profile parseListPhotosIncludeID:JSON];
         if(dictPhotos != nil)
         {
             NSArray *keys = [dictPhotos allKeys];
             __block int i = [keys count];
             for (NSString *key in keys)
             {
                 NSString *link = [dictPhotos valueForKey:key];
                 
                 if((![photosID containsObject:key]) && ![link isEqualToString:@""] )
                 {
                     AFHTTPRequestOperation *operation =
                     [Profile getAvatarSyncWithOperation:link
                                                callback:^(AFHTTPRequestOperation *op, UIImage *image)
                      {
                          if (image)
                          {
                              [photos addObject:image];
                              [photosID addObject:key];
                              [self reloadPhotos];
                          }
                          
                          --i;
                          if (!i)
                          {
                              [photo_Indicator unlockViewAndStopIndicator];
                          }
                      }];
                     [operation start];
                 }
                 else
                 {
                     --i;
                 }
             }
             if (!i)
             {
                 [photo_Indicator unlockViewAndStopIndicator];
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Get list photo Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
}

-(void)photoButtonTouchedAtIndex:(int)index
{
    if (selectedPhoto < 0)
    {
        selectedPhoto = index;
        [self showOKCancelWarning:@"Do you want to delete this photo ?" withTag:1];
    }
}

-(void)addPhotoButtonTouched
{
    if (selectedPhoto < 0 && uploadImage == nil)
    {
        selectedPhoto = photos.count + 1;
        [avatarPicker showPicker];
    }
}

-(void)photoButton:(UIButton *)button touchedAtIndex:(int)index
{
    if (index < photos.count)
    {
        [self photoButtonTouchedAtIndex:index];
    }
    else
    {
        [self addPhotoButtonTouched];
    }
}

-(UIImage*)photoAtIndex:(int)index
{
    if (index < photos.count)
    {
        return [photos objectAtIndex:index];
    }
    
    return [UIImage imageNamed:@"myprofile_addphoto"];
}
-(int)numberOfPhoto
{
    return photos.count + 1;
}
-(UIImage*)borderAtIndex:(int)index
{
    if (index < photos.count)
    {
        return [UIImage imageNamed:@"myprofile_photoLayout"];
    }
    
    return nil;
}

-(CGSize)elementSize
{
    return CGSizeMake(74, 74);
}
-(CGSize)elementPadding
{
    return CGSizeMake(15, 15);
}

-(void)lockViewForIndicator:(LoadingIndicator *)_indicator
{
    if (_indicator == indicator)
    {
        [appDelegate.rootVC.view setUserInteractionEnabled:NO];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    }
}

-(void)unlockViewForIndicator:(LoadingIndicator *)_indicator
{
    if (_indicator == indicator)
    {
        [appDelegate.rootVC.view setUserInteractionEnabled:YES];
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    }
    else if (_indicator == photo_Indicator)
    {
        [self reloadPhotos];
    }
}

-(void)customizeIndicator:(UIActivityIndicatorView *)_indicator ofLoadingIndicator:(LoadingIndicator *)loadingIndicator
{
    if (loadingIndicator == indicator)
    {
        [_indicator setFrame:CGRectMake((320 - _indicator.frame.size.width) / 2,
                                        240,
                                        _indicator.frame.size.width, _indicator.frame.size.height)];
    }
    else if (loadingIndicator == photo_Indicator)
    {
        [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.color = [UIColor colorWithRed:(121.f / 255.f) green:(1.f / 255.f) blue:(88.f / 255.f) alpha:1];
    }
}

-(void)playVideo
{
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", DOMAIN_DATA, profileObj.s_video]];
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    
    [moviePlayer.moviePlayer play];
}

-(UIImage *)videoThumb
{
    return nil;
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", DOMAIN_DATA, profileObj.s_video]];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    return thumbnail;
}
@end

@implementation PickingViewController
{
    NSString *title;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
   
    [self customBackButtonBarItem];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_HELVETICANEUE_LIGHT(18.0);//[UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:title];
    label.textColor = [UIColor blackColor]; // change this color
    [label sizeToFit];
    self.navigationItem.titleView = label;
}
-(void) viewWillDisappear:(BOOL)animated{
    if(IS_OS_7_OR_LATER){
        for(UIView* subview in [self.navigationController.navigationBar subviews]){
            if([subview isKindOfClass:[UIButton class]])
                [subview removeFromSuperview];
        }
    }
}
-(void)setTitle:(NSString *)newTitle
{
    [super setTitle:newTitle];
    
    title = [newTitle localize];
}
@end
