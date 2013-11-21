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

enum UpdateProfileItems {
    UpdateProfile_Name = 0,
    UpdateProfile_Birthday,
    UpdateProfile_Email,
    UpdateProfile_Gender,
    UpdateProfile_InterestedIn
    };

#define nItems 6
@interface UpdateProfileViewController () <UITableViewDataSource, UITableViewDelegate, EditTextViewDelegate, ListForChooseDelegate>
{
    NSArray *updateProfileCellTitles;
    Profile *copyProfile;
    AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@end

@implementation UpdateProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        updateProfileCellTitles = [[NSArray alloc] initWithArray:UpdateProfileItemList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    appDelegate = (id) [UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    copyProfile = [appDelegate.myProfile copy];
    [self updateProfile];
    
    [self.view localizeAllViews];
}

-(void)updateProfile
{
    [self.avatarView setImage:copyProfile.img_Avatar];
    [self.tbView reloadData];
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
    
    [self updateProfile];
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

#pragma mark SAVE
-(void)doneButtonTouched:(id)button
{
    appDelegate.myProfile = [copyProfile copy];
    
    [appDelegate.myProfile saveSettingWithCompletion:^(bool isSuccess) {
        
    }];
}
@end
