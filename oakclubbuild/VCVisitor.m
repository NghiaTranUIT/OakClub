//
//  VCVisitor.m
//  oakclubbuild
//
//  Created by Hoang on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCVisitor.h"
#import "ODRefreshControl.h"
#import "AppDelegate.h"

@interface VCVisitor (){
    __strong NSMutableDictionary *_requestsImage;
    int _selectedSection;
}
@property(strong, nonatomic) NSMutableArray *ar_visitors;
@property(strong, nonatomic) NSMutableArray *ar_wantToMeetMe;
@property(strong, nonatomic) NSMutableDictionary *dict_sections;
@property UIButton* buttonEditNormal;
@property UIButton* buttonEditPressed;
@property(strong, nonatomic) NSMutableArray *ar_selectedCell;
- (void) initVisitorsGridView;
@end

@implementation VCVisitor
BOOL isEditing;
@synthesize ar_visitors,buttonEditPressed, buttonEditNormal, toolbarControll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(NavBarOakClub*)navBarOakClub
{
    NavConOakClub* navcon = (NavConOakClub*)self.navigationController;
    return (NavBarOakClub*)navcon.navigationBar;
}

-(void)showNotifications
{
    AppDelegate* appDel = [UIApplication sharedApplication].delegate;
    int totalNotifications = [appDel countTotalNotifications];
    
    [[self navBarOakClub] setNotifications:totalNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self showNotifications];
}

-(void)viewDidAppear:(BOOL)animated{
    [self addTopRightButtonWithAction:@selector(enterEditing)];
    self.ar_selectedCell = [[NSMutableArray alloc]init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initVisitorsGridView];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.gv_Visitors];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    self.gv_Visitors.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
//    self.gv_Visitors.allowsMultipleSelectionDuringEditing = YES;
//    [self.gv_Visitors setEditing:YES animated:YES];
}
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 5.0;
    [self initVisitorsGridView];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (void) initVisitorsGridView{
    _requestsImage = [[NSMutableDictionary alloc] init];
    _selectedSection =-1;
    self.dict_sections = [[NSMutableDictionary alloc]init];
    
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    // ========> WhoWantsToMeetMe List
    NSDictionary *params_wantMeetMe = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"999",@"limit", nil];
    [request getPath:URL_getListWhoWantsToMeetMe parameters:params_wantMeetMe success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        self.ar_wantToMeetMe = [Profile parseProfileToArrayByJSON:JSON];
//        [self.dict_sections addObject:self.ar_wantToMeetMe];
        [self.dict_sections setObject:self.ar_wantToMeetMe forKey:@"1"];
        [self.gv_Visitors reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
    //========> WhoCheckedMeOut List
    NSDictionary *params_checkedmeout = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"999",@"limit", nil];
    [request getPath:URL_getListWhoCheckedMeOut parameters:params_checkedmeout success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        self.ar_visitors = [Profile parseProfileToArrayByJSON:JSON];
//        [self.dict_sections addObject:self.ar_visitors];
        [self.dict_sections setObject:self.ar_visitors forKey:@"0"];
        [self.gv_Visitors reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
     self.gv_Visitors.uiGridViewDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGv_Visitors:nil];
    [self setToolbarControll:nil];
    [super viewDidUnload];
}

#pragma mark - Grid view delegate
- (NSInteger) numberOfSections {
    return [self.dict_sections count];
}

- (CGFloat) heightForHeaderAtSection:(NSInteger)section {
    return 30;
}

- (CGFloat) gridView:(UIGridViewMultipleSection *)grid widthForColumnAtIndexPath:(NSIndexPath *)columnIndex
{
	return 80;
}

- (CGFloat) gridView:(UIGridViewMultipleSection *)grid heightForRowAtIndexPath:(NSIndexPath *)rowIndex
{
	return 80;
}

- (NSString *) gridView:(UIGridViewMultipleSection *)grid titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Header %d", section];
}

- (UIView *) gridView:(UIGridViewMultipleSection *)grid viewForHeaderInSection:(NSInteger)section {
    NSString *headerName = [NSString stringWithFormat:@"Header %d", section];
    switch (section) {
        case 0:
            headerName = [NSString stringWithFormat:@"\tWho checked me out (%d)", [self.ar_visitors count]];
            break;
        case 1:
            headerName = [NSString stringWithFormat:@"\tWho wanted to meet me (%d)", [self.ar_wantToMeetMe count]];
            break;
        default:
            NSLog(@"Bug here, there is no section : %d", section);
            break;
    }

    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bar.png"]]];
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 310, 30)];
    [name setText:headerName];
    [name setFont:FONT_NOKIA(17.0)];
    [name setTextColor:[UIColor whiteColor]];
    [name setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:name];
    return headerView;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridViewMultipleSection *) grid
{
	return NUMBER_OF_COLUMN;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridViewMultipleSection *)grid atSection:(NSInteger)section
{
    if(section == _selectedSection) {
        return [[self.dict_sections valueForKey:[NSString stringWithFormat:@"%i",section]] count] + 1;
    }
    else {
        if([[self.dict_sections valueForKey:[NSString stringWithFormat:@"%i",section]] count] <= 8) {
            return [[self.dict_sections valueForKey:[NSString stringWithFormat:@"%i",section]] count];
        }
        else {
            return 8;
        }
    }
}

- (UIGridViewCellMultipleSection *) gridView:(UIGridViewMultipleSection *)grid
                                cellForRowAt:(int)rowIndex
                                 AndColumnAt:(int)columnIndex
                                   inSection:(NSInteger)section
{
    
	ViewCellMyLink *cell = (ViewCellMyLink *)[grid dequeueReusableCell];
	
	if (cell == nil) {
		cell = [[ViewCellMyLink alloc] init];
        //        [cell setImage:[UIImage imageNamed:@"Default Avatar.png"] forState:UIControlStateHighlighted];
	}
    cell.isMinus = cell.isPlus = NO;
    
    int count = [[self.dict_sections valueForKey:[NSString stringWithFormat:@"%i",section]] count];
    if(section != _selectedSection) {   // if this cell is inside selected section
        if(count >= 8){             // if the section has >= 8 record
            if(rowIndex * NUMBER_OF_COLUMN + columnIndex == 7) {      // if the calculated index is 7 means that we should draw the + sign, not to draw a profile
                [cell.imageView setImage:[UIImage imageNamed:@"plus_sign"]];
                cell.isPlus = YES;
                return cell;
            }
        }
    }
    else {
        if(rowIndex * NUMBER_OF_COLUMN + columnIndex == count ) { // if the calculated index is the last one means that we should draw the - sign, not to draw a profile
            [cell.imageView setImage:[UIImage imageNamed:@"minus_sign"]];
            cell.isMinus = YES;
            return cell;
        }
    }
    
    Profile *profile = [self.ar_visitors objectAtIndex:rowIndex * NUMBER_OF_COLUMN + columnIndex];
    cell.profile = profile;
    
    UIImage *myImage = [UIImage imageNamed:@"Default Avatar.png"];
    //    cell.thumbnail = [[UIImageView alloc] initWithImage:myImage];
    [cell.imageView setImage:myImage];
    [cell.checkedView setHidden:YES];
    
    NSString *link = profile.s_Avatar;
    AFHTTPClient *request;
    if(![_requestsImage objectForKey:profile.s_Avatar]) {
        if(![link isEqualToString:@""]){
            if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
            {       // check if this is a valid link
                request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
                [request getPath:profile.s_Avatar parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                    UIImage *avatar = [UIImage imageWithData:JSON];
                    [cell.imageView setImage:avatar];
                    [_requestsImage setObject:avatar forKey:profile.s_Avatar];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                }];
            }
            else{
                request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
                [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                    UIImage *avatar = [UIImage imageWithData:JSON];
                    [cell.imageView setImage:avatar];
                    [_requestsImage setObject:avatar forKey:profile.s_Avatar];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                }];
            }
            
        }
    }else {
        UIImage *image = [_requestsImage objectForKey:profile.s_Avatar];
        if(image != nil && [image isKindOfClass:[UIImage class]] && cell.imageView.image  != image) {
            [cell.imageView setImage:image];
        }
    }
   	return  cell;
}

- (void) gridView:(UIGridViewMultipleSection *)grid
   didSelectRowAt:(int)rowIndex
      AndColumnAt:(int)colIndex
   atSectionIndex:(int)section
     selectedCell:(UIGridViewCellMultipleSection *)cell
{
    
    NSLog(@"%d, %d at section %d clicked", rowIndex, colIndex, section);
    ViewCellMyLink *cellMyLink = (ViewCellMyLink *) cell;
    
    if(cellMyLink.isMinus) {
        _selectedSection = -1;
        [grid reloadData];
    }
    else if(cellMyLink.isPlus) {
        _selectedSection = section;
        [_requestsImage removeAllObjects];
        [grid reloadData];
    }
    else {
        if(isEditing){
            [cellMyLink.checkedView setHidden:!cellMyLink.checkedView.isHidden];
            if(cellMyLink.checkedView.isHidden){
                NSIndexSet *deleteIDs =[self.ar_selectedCell indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary * object= [self.ar_selectedCell objectAtIndex:idx];
                    if([[object valueForKey:@"section"] isEqual:[NSString stringWithFormat:@"%i",section]]  && [[object valueForKey:@"index"] isEqual:[NSString stringWithFormat:@"%i",colIndex+(rowIndex*NUMBER_OF_COLUMN)]])
                        return YES;
                    else
                        return NO;
                }];
                [self.ar_selectedCell removeObjectsAtIndexes:deleteIDs];
            }
            else{
                [self.ar_selectedCell addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",section],@"section",[NSString stringWithFormat:@"%i",colIndex+(rowIndex*NUMBER_OF_COLUMN)],@"index", nil]];
            }
            
        }
        else{
            Profile *p = cellMyLink.profile;
            VCProfile *viewProfile = [[VCProfile alloc] initWithNibName:@"VCProfile" bundle:nil];
            [viewProfile loadProfile:p andImage:cellMyLink.imageView.image];
            [self.navigationController pushViewController:viewProfile animated:YES];
            NSLog(@"name : %@ \t id : %@", p.s_Name, p.s_ID);
        }
        
    }
}

-(void)addTopRightButtonWithAction:(SEL)action
{
    buttonEditNormal = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonEditNormal.frame = CGRectMake(0, 0, 35, 30);
    [buttonEditNormal addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonEditNormal setBackgroundImage:[UIImage imageNamed:@"header_btn_setting.png"] forState:UIControlStateNormal];
    [buttonEditNormal setBackgroundImage:[UIImage imageNamed:@"header_btn_setting_pressed.png"] forState:UIControlStateHighlighted];
    
    buttonEditPressed = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonEditPressed.frame = CGRectMake(0, 0, 35, 30);
    [buttonEditPressed addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonEditPressed setBackgroundImage:[UIImage imageNamed:@"header_btn_setting_pressed.png"] forState:UIControlStateNormal];
    [buttonEditPressed setBackgroundImage:[UIImage imageNamed:@"header_btn_setting.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditNormal];
    
    self.navigationItem.rightBarButtonItem = buttonItem;
}

-(void)enterEditing
{
//    [self.tableView setEditing:!tableView.editing animated:YES];
    //[buttonEdit setSelected:!buttonEdit.selected];
    //[tableView reloadData];
    isEditing = !isEditing;
    [toolbarControll  setHidden:!isEditing];
    NSLog(@"enterEditing");
    
    UIBarButtonItem *buttonItem;
    
    if(isEditing)
    {
        buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditPressed];
    }
    else
    {
        buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonEditNormal];
    }
    
    self.navigationItem.rightBarButtonItem = buttonItem;
}

-(IBAction)deleteSelectedCell:(id)sender{
    for(int s = 0; s < [self.dict_sections count]; s++){
        NSMutableIndexSet *indexS = [NSMutableIndexSet indexSet];
        for(int i =0 ; i < [self.ar_selectedCell count]; i++){
            NSDictionary *object= [self.ar_selectedCell objectAtIndex:i] ;
            NSString * sectionNum = [object objectForKey:@"section"];
            if([sectionNum integerValue] == s){
                NSString *indexNum = [object objectForKey:@"index"];
                [indexS addIndex:[indexNum integerValue]];
                
            }
        }
        [[self.dict_sections objectForKey:[NSString stringWithFormat:@"%i",s]] removeObjectsAtIndexes:[indexS indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
            return YES;
        }]];
    }
    
    [self.gv_Visitors reloadData];
    [self.ar_selectedCell removeAllObjects];
}
@end
