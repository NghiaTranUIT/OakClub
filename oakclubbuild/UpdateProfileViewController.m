//
//  UpdateProfileViewController.m
//  OakClub
//
//  Created by Salm on 11/21/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"
#import "LoadingIndicator.h"
#import "LocationUpdate.h"

enum UpdateProfileItems {
    UpdateProfile_Name = 0,
    UpdateProfile_Birthday,
    UpdateProfile_Email,
    UpdateProfile_Gender,
    UpdateProfile_InterestedIn
    };

#define nItems 5
@interface UpdateProfileViewController () <UITableViewDataSource, UITableViewDelegate, EditTextViewDelegate, ListForChooseDelegate, UIViewControllerBirthdayPickerDelegate, ImageRequester, LoadingIndicatorDelegate>
{
    NSArray *updateProfileCellTitles;
    Profile *copyProfile;
    AppDelegate *appDelegate;
    LoadingIndicator *indicator;
    LocationUpdate *locUpdater;
}
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAgeWork;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UIViewControllerBirthdayPicker *birthdayVC;
@end

@implementation UpdateProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        updateProfileCellTitles = [[NSArray alloc] initWithArray:UpdateProfileItemList];
        appDelegate = (id) [UIApplication sharedApplication].delegate;
        locUpdater = [[LocationUpdate alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    indicator = [[LoadingIndicator alloc] initWithMainView:self.view andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateData];
    
    [self.navBarOakClub.customView removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_HELVETICANEUE_LIGHT(20.0);//[UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:@"Update profile"];
    label.textColor = [UIColor blackColor]; // change this color
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.view localizeAllViews];
}

-(void)updateProfile
{
    copyProfile = [appDelegate.myProfile copy];
}

-(void)updateData
{
    [appDelegate.myProfile tryGetImageAsync:self];
    self.lblName.text = copyProfile.s_Name;
    self.lblAgeWork.text = [NSString stringWithFormat:@"%d, %@,", copyProfile.age, copyProfile.i_work.cate_name];
    self.lblLocation.text = copyProfile.s_location.name;
    [self.tbView reloadData];
}

#pragma Avatar requester
-(void)setImage:(UIImage *)img
{
    if (img)
    {
        [self.avatarView setImage:img];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nItems + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row < nItems)?44:88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    static NSString *DoneID = @"DoneButtonIndentifier";
	
    if (indexPath.row >= nItems)
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
    cell.textLabel.text = [updateProfileCellTitles objectAtIndex:indexPath.row];
    switch (indexPath.row)
    {
        case UpdateProfile_Name:
            cell.detailTextLabel.text = copyProfile.s_Name;
            break;
        case UpdateProfile_Birthday:
            cell.detailTextLabel.text = copyProfile.s_birthdayDate;
            break;
        case UpdateProfile_Email:
            cell.detailTextLabel.text = copyProfile.s_Email;
            break;
        case UpdateProfile_Gender:
            cell.detailTextLabel.text = copyProfile.s_gender.text;
            break;
        case UpdateProfile_InterestedIn:
            cell.detailTextLabel.text = copyProfile.s_interested.text;
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
    switch (indexPath.row)
    {
        case UpdateProfile_Name:
            [self gotoEditName];
            break;
        case UpdateProfile_Birthday:
            [self gotoChooseBirthday];
            break;
        case UpdateProfile_Email:
            [self gotoEditEmail];
            break;
        case UpdateProfile_Gender:
            [self gotoChooseGender];
            break;
        case UpdateProfile_InterestedIn:
            [self gotoChooseInterestedIn];
            break;
    }
}

#pragma mark goto Edit
-(void)gotoEditName
{
    EditText *nameEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [nameEditView initForEditting:copyProfile.s_Name andStyle:0];
    [nameEditView setTitle:@"Name"];
    nameEditView.delegate = self;
    [self.navigationController pushViewController:nameEditView animated:YES];
}
-(void)gotoChooseBirthday
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDay = [dateFormat dateFromString:copyProfile.s_birthdayDate];
    [self.birthdayVC setCurrentDay:birthDay];
    [self.birthdayVC setDelegate:self];
    
    [self.navigationController pushViewController:self.birthdayVC animated:YES];
}
-(void)gotoEditEmail
{
    EditText *emailEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [emailEditView initForEditting:copyProfile.s_Email andStyle:3];
    [emailEditView setTitle:@"Email"];
    emailEditView.delegate = self;
    [self.navigationController pushViewController:emailEditView animated:YES];
}
-(void)gotoChooseGender
{
    ListForChoose *genderView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [genderView setListType:LISTTYPE_GENDER];
    genderView.delegate=self;
    [self.navigationController pushViewController:genderView animated:YES];
}
-(void)gotoChooseInterestedIn
{
    ListForChoose *intersetedView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [intersetedView setListType:LISTTYPE_INTERESTED];
    intersetedView.delegate=self;
    [self.navigationController pushViewController:intersetedView animated:YES];
}

#pragma mark LIST-FOR-CHOOSE delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    switch ([uvcList getType]) {
        case LISTTYPE_GENDER:
            copyProfile.s_gender = selected.s_gender;
            break;
        case LISTTYPE_INTERESTED:
            copyProfile.s_gender = selected.s_gender;
            break;
        default:
            break;
    }
    
    [self updateData];
}
-(Profile *)setDefaultValue:(ListForChoose *)uvcList
{
    return copyProfile;
}

#pragma mark EditText editing
- (void)saveChangedEditting:(EditText *)editObject{
    switch (editObject.getStyle) {
        case 0:
        {
            if (![editObject.texfieldEdit.text isEqualToString:@""])
            {
                copyProfile.s_Name = editObject.texfieldEdit.text;
            }
            else
            {
                [self showWarning:@"Name cannot be empty" withTag:3];
            }
        }
            break;
        case 3:
        {
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+.[a-zA-Z]{2,4}"];
            
            if ([emailTest evaluateWithObject:editObject.texfieldEdit.text])
            {
                copyProfile.s_Email = editObject.texfieldEdit.text;
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
    
    [self updateData];
}

#pragma UIAlertView region
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

#pragma mark BIRTHDAY PICKER
-(void)dateChanged:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    copyProfile.s_birthdayDate = [dateFormat stringFromDate:date];
    
    [self updateData];
}

#pragma mark SAVE
-(void)doneButtonTouched:(id)button
{
    appDelegate.myProfile = [copyProfile copy];
    
    [indicator lockViewAndDisplayIndicator];
    Location *lc = copyProfile.s_location;
    NSNumber *longNumber = [NSNumber numberWithDouble:lc.longitude];
    NSNumber *latiNumber = [NSNumber numberWithDouble:lc.latitude];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            copyProfile.s_birthdayDate, @"birthday",
                            copyProfile.s_Email, @"email",
                            [NSNumber numberWithInt:copyProfile.s_gender.ID], @"gender",
                            [NSNumber numberWithInt:copyProfile.s_interested.ID], @"interested",
                            latiNumber, @"latitude",
                            longNumber, @"longitude",
                            copyProfile.s_Name, @"name", nil];
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableURLRequest *urlReq = [request requestWithMethod:@"POST" path:URL_updateProfileFirstTime parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlReq];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"Update profile result %@", result);
        if ([[result valueForKey:key_status] boolValue])
        {
            appDelegate.myProfile.s_location.name = [result valueForKey:key_location];
            [indicator unlockViewAndStopIndicator];
            
            [appDelegate gotoVCAtCompleteLogin];
        }
        
        NSLog(@"Update profile error with msg: %@", [result valueForKey:key_msg]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Update profile error with err: %@", [error localizedDescription]);
        [indicator unlockViewAndStopIndicator];
    }];
    
    [operation start];
}

#pragma mark Loading Indicator Delegate
-(void)lockViewForIndicator:(LoadingIndicator *)_indicator
{
    [appDelegate.rootVC.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}

-(void)unlockViewForIndicator:(LoadingIndicator *)_indicator
{
    [appDelegate.rootVC.view setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}

#pragma mark location update delegate
-(void)location:(LocationUpdate *)location updateFailWithError:(NSError *)e
{
    // can't continue
}

-(void)location:(LocationUpdate *)location updateSuccessWithLongitude:(double)longt andLatitude:(double)lati
{
    copyProfile.s_location.longitude = longt;
    copyProfile.s_location.latitude = lati;
}
@end

@interface UIViewControllerBirthdayPicker()
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@end

@implementation UIViewControllerBirthdayPicker
{
    NSDateFormatter *dateFormat;
}

@synthesize currentDay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self customBackButtonBarItem];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_HELVETICANEUE_LIGHT(18.0);//[UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:[@"Birthdate" localize]];
    label.textColor = [UIColor blackColor]; // change this color
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.birthdayPicker setDate:currentDay];
    self.valueLabel.text = [dateFormat stringFromDate:currentDay];
    [self.view localizeAllViews];
}

- (IBAction)birthdayPickerValueChanged:(id)sender
{
    currentDay = [sender date];
    
    self.valueLabel.text = [dateFormat stringFromDate:currentDay];
    if (self.delegate)
    {
        [self.delegate dateChanged:currentDay];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        if([subview isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
    }
}
@end
