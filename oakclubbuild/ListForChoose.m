//
//  ListForChoose.m
//  oakclubbuild
//
//  Created by VanLuu on 5/8/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ListForChoose.h"
#import "AppDelegate.h"
#import "UITableView+Custom.h"
#import "UIView+Localize.h"

@interface ListForChoose (){
        AppDelegate *appDelegate;
}

@end

@implementation ListForChoose
@synthesize tableView, delegate;
NSIndexPath* oldIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
        currentValue = [Profile alloc];
        currentValue.s_location = [Location alloc];
        currentValue.s_gender = [Gender alloc];
        currentValue.a_language = [[NSMutableArray alloc]init];
        currentValue.s_interested = [Gender alloc];
        currentValue.s_relationShip = [RelationShip alloc];
        currentValue.c_ethnicity = [Ethnicity alloc];
    }
    return self;
}
//- (AppDelegate *)appDelegate {
//	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
//}


-(void)setListType:(int) typeID{
    
    switch (typeID) {
        case LISTTYPE_GENDER:
            type = LISTTYPE_GENDER;
            dataSource = appDelegate.genderList;
            break;
        case LISTTYPE_INTERESTED:
            type = LISTTYPE_INTERESTED;
            dataSource = appDelegate.genderList;
            break;
        case LISTTYPE_HERETO:
            type = LISTTYPE_HERETO;
            dataSource = HereToOptionList;
            break;
        case LISTTYPE_EMAILSETTING:
            type = LISTTYPE_EMAILSETTING;
            dataSource = EmailSettingOptionList;
            break;
        case LISTTYPE_WITHWHO:
            type = LISTTYPE_WITHWHO;
            dataSource = WithWhoOptionList;
            break;
        case LISTTYPE_RELATIONSHIP:
            type = LISTTYPE_RELATIONSHIP;
            dataSource = appDelegate.relationshipList;
            break;
        case LISTTYPE_ETHNICITY:
            type = LISTTYPE_ETHNICITY;
            dataSource = appDelegate.ethnicityList;
            break;
        case LISTTYPE_WORK:
            type = LISTTYPE_WORK;
            dataSource = appDelegate.workList;
            break;
        case LISTTYPE_LANGUAGE:
            type = LISTTYPE_LANGUAGE;
            isMultiChoose = YES;
            dataSource = appDelegate.languageList;
            break;
        case LISTTYPE_COUNTRY:
            type = LISTTYPE_COUNTRY;
            if([appDelegate.countryList count] == 0){
                request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
                
                [request getPath:URL_getListCountry parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON)
                 {
                     
                     NSError *e=nil;
                     NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
                     NSMutableArray * data= [dict valueForKey:key_data];
                     appDelegate.countryList =data.copy;
                     dataSource = appDelegate.countryList;
                     [tableView reloadData];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                 }];
            }else{
                dataSource = appDelegate.countryList;
            }
            
            break;
        default:
            break;
    }
    [tableView reloadData];

}

-(int)getType {
     return type;
}
-(Profile*)getCurrentValue{
    return currentValue;
}
-(SettingObject*)getSettingValue{
    return settingValue;
}
-(void)setCityListWithCountryCode:(NSString*)countryCode {
    type = LISTTYPE_CITY;
    [currentValue.s_location setCountryCode:countryCode];
    NSArray *cityList= [appDelegate.cityList objectForKey:countryCode];
    if([cityList  count] == 0){
        request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                                countryCode, @"country",
                                nil
                                ];
        [request getPath:URL_getListCityByCountry parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
         {
             NSError *e=nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
             NSMutableArray * data= [dict valueForKey:key_data];
             NSArray *dataList = data.copy;
             [appDelegate.cityList setObject:dataList forKey:countryCode];
             dataSource = dataList;
             [tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
         }];
    }else{
        dataSource = cityList;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if(delegate){
        if ([delegate respondsToSelector:@selector(setDefaultValue:)])
            currentValue = [delegate setDefaultValue:self];
        if ([delegate respondsToSelector:@selector(setDefaultSettingValue:)])
            settingValue = [delegate setDefaultSettingValue:self];
    }
    [self.navigationController setNavigationBarHidden:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    [self customBackButtonBarItem];
    // Do any additional setup after loading the view from its nib.
    NSString* titleText;
    switch (type) {
        case LISTTYPE_COUNTRY:
//            [self setTitle:@"Country"];
            titleText = @"Country";
            break;
        case LISTTYPE_CITY:
            titleText = @"City";
//            self.navigationItem.title = @"City";
            break;
        case LISTTYPE_ETHNICITY:
            titleText = @"Ethnicity";
//            self.navigationItem.title = @"Ethnicity";
            break;
        case LISTTYPE_WORK:
            titleText = @"Work";
//            self.navigationItem.title = @"Work";
            break;
        case LISTTYPE_LANGUAGE:
            titleText = @"Language";
//            self.navigationItem.title = @"Languages";
            break;
        case LISTTYPE_RELATIONSHIP:
            titleText = @"Relationship";
//            self.navigationItem.title = @"Relationship";
            break;
        case LISTTYPE_GENDER:
            titleText = @"Gender";
//            self.navigationItem.title = @"Gender";
            break;
        case LISTTYPE_INTERESTED:
            titleText = @"Interested In";
//            self.navigationItem.title = @"Interested In";
            break;
        case LISTTYPE_HERETO:
            titleText = @"I'm Here To";
//            self.navigationItem.title = @"I'm Here To";
            break;
        case LISTTYPE_EMAILSETTING:
            titleText = @"Email Setting";
//            self.navigationItem.title = @"Email Setting";
            break;
        case LISTTYPE_WITHWHO:
            titleText = @"With Who";
//            self.navigationItem.title = @"With Who";
            break;
        default:
            break;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_HELVETICANEUE_LIGHT(18.0);//[UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:[titleText localize]];
    label.textColor = [UIColor blackColor]; // change this color
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

//- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
//{
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [dataSource count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.selectedBackgroundView = [self customSelectdBackgroundViewForCell:cell AtIndexPath:indexPath];
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];
    if(type == LISTTYPE_CITY){
//        cell.accessoryType =UITableViewCellAccessoryCheckmark;
         cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"location_name"];
    }
    else{
        
        switch (type) {
            case LISTTYPE_RELATIONSHIP:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"rel_text"];
                if(currentValue.s_relationShip.rel_status_id == [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"rel_status_id"] integerValue]){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    oldIndex = indexPath;
                }
                break;
            case LISTTYPE_WORK:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"cate_name"];
                NSLog(@"%i",[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"cate_id"] integerValue]);
                if(currentValue.i_work.cate_id == [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"cate_id"] integerValue]){
                    oldIndex = indexPath;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                    
                break;
            case LISTTYPE_COUNTRY:
                cell.textLabel.text = [dataSource objectAtIndex:indexPath.row] ;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case LISTTYPE_GENDER:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"];
                if(currentValue.s_gender.ID ==[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue] ){
                    oldIndex = indexPath;
                    currentValue.s_gender.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"] ;
                    currentValue.s_gender.ID = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                    
                break;
            case LISTTYPE_INTERESTED:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"];
                if(currentValue.s_interested.ID ==[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue] ){
                    oldIndex = indexPath;
                    currentValue.s_interested.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"] ;
                    currentValue.s_interested.ID = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
                break;
            case LISTTYPE_EMAILSETTING:{
                cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
                NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"key_EmailSetting"];
                if([value isEqualToString:cell.textLabel.text ] ){
                    oldIndex = indexPath;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            }
            case LISTTYPE_LANGUAGE:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"name"];
                for (Language* item in currentValue.a_language){
                    if(item.ID == [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]){
                        oldIndex = indexPath;
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        break;
                    }
                }
                break;
            case LISTTYPE_ETHNICITY:
                cell.textLabel.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"name"];
                if(currentValue.c_ethnicity.ID ==[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue] ){
                    oldIndex = indexPath;
                    currentValue.c_ethnicity.name = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"name"] ;
                    currentValue.c_ethnicity.ID = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
                
            default:
                break;
        }
    }
    
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    [cell.textLabel setFont: FONT_HELVETICANEUE_LIGHT(17.0)];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(type == LISTTYPE_COUNTRY){
        [currentValue.s_location setCountryCode:[dataSource objectAtIndex:indexPath.row]];
    }
    else{
       
        if(isMultiChoose == YES){
            switch (type) {
                case LISTTYPE_LANGUAGE:
                {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if(cell.accessoryType == UITableViewCellAccessoryNone){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        Language* newLang = [[Language alloc]initWithID:[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue]];
                        [currentValue.a_language addObject:newLang];
                    }
                    else{
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        int currentLangID =[[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
                        for(int i =0; i < [currentValue.a_language count]; i++){
                            Language* oldLang = [currentValue.a_language objectAtIndex:i];
                            if(oldLang.ID == currentLangID){
                                [currentValue.a_language removeObjectAtIndex:i];
                            }
                        }
                    }
                    break;
                }
                default:
                    break;
            }
//            if (delegate) {
//                if ([delegate respondsToSelector:@selector(ListForChoose:didSelectRow:)]) {
//                    [delegate ListForChoose:self didSelectRow:indexPath.row];
//                }
//                
//            }
        }
        else{
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndex];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            oldIndex = indexPath;
            switch (type) {
                case LISTTYPE_RELATIONSHIP:
                    currentValue.s_relationShip.rel_status_id = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"rel_status_id"] integerValue];
                    currentValue.s_relationShip.rel_text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"rel_text"];
                    break;
                case LISTTYPE_CITY:
                    currentValue.s_location.ID = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"location_id"];
                    currentValue.s_location.name = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"location_name"];

                    break;
                case LISTTYPE_ETHNICITY:
                {
                    int index = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
                    NSString* name =[[dataSource objectAtIndex:indexPath.row] valueForKey:@"name"] ;
                    currentValue.c_ethnicity = [[Ethnicity alloc] initWithID:index andName:name];
                    break;
                }
                case LISTTYPE_GENDER:
                    currentValue.s_gender.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"] ;
                    currentValue.s_gender.ID = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue];
                    break;
                case LISTTYPE_INTERESTED:
                    currentValue.s_interested.text = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"text"] ;
                    currentValue.s_interested.ID = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"ID"] integerValue];
                    break;
                case LISTTYPE_EMAILSETTING:
                    [[NSUserDefaults standardUserDefaults] setObject:[dataSource objectAtIndex:indexPath.row] forKey:@"key_EmailSetting"] ;
                    break;
                case LISTTYPE_WORK:
                    currentValue.i_work.cate_id = [[[dataSource objectAtIndex:indexPath.row] valueForKey:@"cate_id"] integerValue];
                    currentValue.i_work.cate_name = [[dataSource objectAtIndex:indexPath.row] valueForKey:@"cate_name"] ;
                    break;
                default:
                    break;
            }
        }
    }
    if (delegate) {
        if ([delegate respondsToSelector:@selector(ListForChoose:didSelectRow:)]) {
            [delegate ListForChoose:self didSelectRow:indexPath.row];
        }
        
    }
}

-(void)chooseLocation:(int)index{
    ListForChoose *locationSubview = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    currentValue.s_location.countryCode = [dataSource objectAtIndex:index];
    [locationSubview setCityListWithCountryCode:currentValue.s_location.countryCode];
    locationSubview.delegate = self;
    [self.navigationController pushViewController:locationSubview animated:YES];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end
