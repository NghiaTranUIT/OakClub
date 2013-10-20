//
//  VCMutualMatch.m
//  OakClub
//
//  Created by VanLuu on 10/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCMutualMatch.h"
#import "AFHTTPClient+OakClub.h"
#import "ODRefreshControl.h"
#import "AppDelegate.h"
@interface VCMutualMatch (){
    __strong NSMutableDictionary *_requestsImage;
    int _selectedSection;
}

@property(strong, nonatomic) NSMutableArray *mutualMatches;
@property(strong, nonatomic) NSMutableArray *unviewed_mutualMatches;
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSMutableArray *ar_selectedCell;

@end

@implementation VCMutualMatch
BOOL isEditing;
@synthesize /*wantToMeetMe,*/ mutualMatches,unviewed_mutualMatches, sections, toolbar;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showNotifications];
    [self loadDataForAllList];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.gridView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    self.gridView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)loadDataForAllList{
    _requestsImage = [[NSMutableDictionary alloc] init];
    _selectedSection = -1;
    self.sections = [[NSMutableDictionary alloc]init];
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];

    [Profile getListPeople:URL_getListWhoWantsToMeetMe handler:^(NSMutableArray *list, int count) {
        self.mutualMatches = list;
        self.unviewed_mutualMatches = list;
        //        [self.sections replaceObjectAtIndex:0 withObject:self.mutualMatches];
        [self.sections setObject:self.unviewed_mutualMatches forKey:@"0"];
        [self.sections setObject:self.mutualMatches forKey:@"1"];
        
        [self.gridView reloadData];
    }];

    self.gridView.uiGridViewDelegate = self;
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
#pragma mark - Grid view delegate
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 5.0;
    [self loadDataForAllList];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (NSInteger) numberOfSections {
    return [self.sections count];
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
           headerName = [NSString stringWithFormat:@"\tNew Mutual Matches (%d)", [self.unviewed_mutualMatches count]];
            break;
        case 1:
            
             headerName = [NSString stringWithFormat:@"\tMutual matches (%d)", [self.mutualMatches count]];
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
        return [[self.sections valueForKey:[NSString stringWithFormat:@"%i",section]] count] + 1;
    }
    else {
        if([[self.sections valueForKey:[NSString stringWithFormat:@"%i",section]] count] <= 8) {
            return [[self.sections valueForKey:[NSString stringWithFormat:@"%i",section]] count];
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
    
    int count = [[self.sections valueForKey:[NSString stringWithFormat:@"%i",section]] count];
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
    
    
    
    Profile *profile = [[self.sections valueForKey:[NSString stringWithFormat:@"%i",section]] objectAtIndex:rowIndex * NUMBER_OF_COLUMN + columnIndex];
    cell.profile = profile;
    
    UIImage *myImage = [UIImage imageNamed:@"Default Avatar.png"];
    //    cell.thumbnail = [[UIImageView alloc] initWithImage:myImage];
    [cell.imageView setImage:myImage];
    
    
    NSString *link = profile.s_Avatar;
    //    NSLog(@"name : %@ --------- link image = %@ ",profile.s_Name, link);
    AFHTTPClient *request;
    if(![_requestsImage objectForKey:profile.s_Avatar]) {
        //       [request downloadImageFromOakclub:profile.s_Avatar andMangeDict:_requestsImage andUpdateImage:cell.imageView ];
        
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
    if(self.gridView.isEditing){
        [cellMyLink.checkedView setHidden:NO];
    }
    else{
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
//                [viewProfile loadProfile:p andImage:cellMyLink.imageView.image];
                [viewProfile loadProfile:p];
                [self.navigationController pushViewController:viewProfile animated:YES];
                NSLog(@"name : %@ \t id : %@", p.s_Name, p.s_ID);
            }
            
        }
    }
    
}

-(IBAction)deleteSelectedCell:(id)sender{
    
    for(int s = 0; s < [self.sections count]; s++){
        NSMutableIndexSet *indexS = [NSMutableIndexSet indexSet];
        for(int i =0 ; i < [self.ar_selectedCell count]; i++){
            NSDictionary *object= [self.ar_selectedCell objectAtIndex:i] ;
            NSString * sectionNum = [object objectForKey:@"section"];
            if([sectionNum integerValue] == s){
                NSString *indexNum = [object objectForKey:@"index"];
                [indexS addIndex:[indexNum integerValue]];
                
            }
        }
        [[self.sections objectForKey:[NSString stringWithFormat:@"%i",s]] removeObjectsAtIndexes:[indexS indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
            return YES;
        }]];
    }    [self.gridView reloadData];
    [self.ar_selectedCell removeAllObjects];
}

@end
