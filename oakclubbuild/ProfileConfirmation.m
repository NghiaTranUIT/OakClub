//
//  ProfileConfirmation.m
//  OakClub
//
//  Created by VanLuu on 7/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ProfileConfirmation.h"
#import "PreferencesSettings.h"
#import "UIView+Localize.h"

@interface ProfileConfirmation (){
    Profile *newAccount;
    UIDatePicker* pickerBirthdate;
    bool isPickerShown;
    UITapGestureRecognizer *tap;
}

@end

@implementation ProfileConfirmation
@synthesize lblHeader,lblNext, tb_Profile;

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
    isPickerShown = false;
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tap];
    
//    self.view.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    lblHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_small"]];
    [lblHeader setFont:FONT_NOKIA(20.0)];
    [lblNext setFont:FONT_NOKIA(17.0)];
    [self loadFBUserInfo];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load values from server
-(void)loadFBUserInfo{
    newAccount = [[Profile alloc] init];
    NSDictionary* params = [NSDictionary dictionaryWithObject:@"id,name,gender,relationship_status,about,location,interested_in,birthday,email" forKey:@"fields"];
    [FBRequestConnection startWithGraphPath:@"me" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"USER INFO _ %@",result);
        newAccount.s_Name = [result objectForKey:@"name"];
        newAccount.s_gender = [[Gender alloc] initWithNSString:[result objectForKey:@"gender"]];
        newAccount.s_relationShip = [[RelationShip alloc] initWithNSString:[result objectForKey:@"relationship_status"]];
        if([newAccount.s_relationShip.rel_text length]== 0){
            if(newAccount.s_interested.ID == MALE)
                newAccount.s_interested = [[Gender alloc] initWithID:FEMALE];
            else
                newAccount.s_interested = [[Gender alloc] initWithID:MALE];
        }
        
        newAccount.s_location = [[Location alloc] initWithNSDictionary:[result objectForKey:@"location"]];
        newAccount.s_FB_id = [result objectForKey:@"id"];
        newAccount.s_birthdayDate = [result objectForKey:@"birthday"];
        newAccount.s_Email = [result objectForKey:@"email"];
        [tb_Profile reloadData];
    }];
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 60;
    else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        NSString *headerName = @"Welcome! Please confirm your profile then we will bring you to the club.";
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
        [headerView setBackgroundColor:[UIColor clearColor]];
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 310, 60)];
        [name setText:headerName];
        [name setLineBreakMode:NSLineBreakByWordWrapping];
        [name setNumberOfLines:2];
        [name setFont:FONT_NOKIA(17.0)];
        [name setTextColor:[UIColor blackColor]];
        [name setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:name];
        return headerView;
    }
    else{
        return nil;
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if(section == 0){
        if(row != 4)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (row) {
            case 0:
                cell.detailTextLabel.text = newAccount.s_Email;
                break;
            case 1:
                cell.detailTextLabel.text = newAccount.s_gender.text;
                break;
            case 2:
                cell.detailTextLabel.text = newAccount.s_interested.text;
                break;
            case 3:
                cell.detailTextLabel.text = newAccount.s_relationShip.rel_text;
                break;
            case 4:
                cell.detailTextLabel.text = newAccount.s_birthdayDate;
                break;
            case 5:
                cell.detailTextLabel.text = newAccount.s_location.name;
                break;
            case 6:
                cell.detailTextLabel.text = newAccount.c_ethnicity.name;
                break;
            case 7:
                cell.detailTextLabel.text = newAccount.s_aboutMe;
                break;
        }
    }
    [cell.detailTextLabel setFont: FONT_NOKIA(15.0)];
    [cell.textLabel setFont: FONT_NOKIA(15.0)];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.detailTextLabel.highlightedTextColor = COLOR_BLUE_CELLTEXT;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
-(Profile *)setDefaultValue:(ListForChoose *)uvcList{
    return newAccount;
}
#pragma mark - Table view delegate
-(void)gotoGenderSetting{
    ListForChoose *genderView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [genderView setListType:LISTTYPE_GENDER];
    genderView.delegate=self;
    [self.navigationController pushViewController:genderView animated:YES];
}
-(void)gotoInterestedSetting{
    ListForChoose *genderView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [genderView setListType:LISTTYPE_INTERESTED];
    genderView.delegate=self;
    [self.navigationController pushViewController:genderView animated:YES];
}

- (void)gotoRelatioshipSetting{
    ListForChoose *relationshipView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [relationshipView setListType:LISTTYPE_RELATIONSHIP];
    relationshipView.delegate=self;
    [self.navigationController pushViewController:relationshipView animated:YES];
}

- (void)gotoLocationSetting {
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
- (void)gotoAboutEditText{
    EditText *aboutmeView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [aboutmeView initForEditting:newAccount.s_aboutMe andStyle:2];
    aboutmeView.delegate = self;
    [self.navigationController pushViewController:aboutmeView animated:YES];
}
- (void)gotoEmailEditText{
    EditText *aboutmeView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [aboutmeView initForEditting:newAccount.s_Email andStyle:0];
    aboutmeView.delegate = self;
    [self.navigationController pushViewController:aboutmeView animated:YES];
}
- (void)onTouchBirthdate {
    if(isPickerShown){
        [pickerBirthdate removeFromSuperview];
    }
    else{
        pickerBirthdate = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 216, 320, 200)];
        [pickerBirthdate setMaximumDate:[[NSDate alloc] init]];
        [pickerBirthdate addTarget:self action:@selector(onTouchUpDatePicker) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview: pickerBirthdate];
        [pickerBirthdate setNeedsDisplay];
        
    }
    isPickerShown = !isPickerShown;
    [self.tableView reloadData];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                [self gotoEmailEditText];
                break;
            case 1:
                [self gotoGenderSetting];
                break;
            case 2:
                [self gotoInterestedSetting];
                break;
            case 3:
                [self gotoRelatioshipSetting];
                break;
            case 4:
                //                [self.tableView setScrollEnabled:YES];
                [tb_Profile scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                //                [self.tableView setScrollEnabled:NO];
                [self onTouchBirthdate];
                break;
            case 5:
                [self gotoLocationSetting];
                break;
            case 6:
                [self gotoEthnicitySetting];
                break;
            case 7:
                [self gotoAboutEditText];
                break;
            default:
                break;
        }
    }
    else{
        [self onTouchNext];
    }

}

#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
    switch ([uvcList getType]) {
        case LISTTYPE_RELATIONSHIP:
            newAccount.s_relationShip = selected.s_relationShip;
            break;
        case LISTTYPE_CITY:
            newAccount.s_location = selected.s_location;
            break;
        case LISTTYPE_GENDER:
            newAccount.s_gender = selected.s_gender;
            break;
        case LISTTYPE_INTERESTED:
            newAccount.s_interested = selected.s_interested;
            break;
        case LISTTYPE_ETHNICITY:
            newAccount.c_ethnicity = selected.c_ethnicity;
            break;
//        case LISTTYPE_LANGUAGE:
//            profileObj.a_language = selected.a_language;
//            [self updateProfileItemListAtIndex:[profileObj.a_language componentsJoinedByString:@", "] andIndex:LANGUAGE];
//            break;
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
    [tb_Profile reloadData];
}

#pragma mark - EditText Delegate
- (void)saveChangedEditting:(EditText *)editObject{
    switch (editObject.getStyle) {
        case 2:
            newAccount.s_aboutMe = editObject.textviewEdit.text;
            break;
        case 0:
            newAccount.s_Email = editObject.texfieldEdit.text;
            break;
        default:
            break;
    }
    [tb_Profile reloadData];
}

#pragma mark DatePicker Events
-(void)onTouchUpDatePicker{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *theDate = [dateFormat stringFromDate:pickerBirthdate.date];
    newAccount.s_birthdayDate = theDate;
    [tb_Profile reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [pickerBirthdate removeFromSuperview];
    isPickerShown = NO;
    [self.tableView reloadData];
}
- (void)dismissKeyboard {
    if (isPickerShown){
        [[self.tableView.gestureRecognizers objectAtIndex:2] setCancelsTouchesInView:isPickerShown];
        [pickerBirthdate removeFromSuperview];
        isPickerShown = NO;
        [self.tableView reloadData];
    }
}
- (void)viewDidUnload {
    [self setLblHeader:nil];
    [self setLblNext:nil];
    [self setTb_Profile:nil];
    [super viewDidUnload];
}

-(BOOL) validateEmail:(NSString*) emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    }
    else
        return YES;
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //ignore segue from cell since we we are calling manually in didSelectRowAtIndexPath
    return (sender == self);
}
-(void)onTouchNext{
    if([self validateEmail:newAccount.s_Email]){
        NSLog(@"Valid email");
        [self performSegueWithIdentifier:@"preferencesView" sender:self];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[@"Error" localize]
		                                                    message:@"Email is invalid"
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
        [alertView localizeAllViews];
		[alertView show];
        NSLog(@"Invalid email");
    }
        
}
@end
