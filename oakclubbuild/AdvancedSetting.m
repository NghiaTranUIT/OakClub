//
//  AdvancedSetting.m
//  OakClub
//
//  Created by VanLuu on 6/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "AdvancedSetting.h"
#import "Define.h"
#import "UITableView+Custom.h"
@interface AdvancedSetting (){
    CGPoint insertPosition;
    NSMutableArray *nameFieldList;
    NSMutableArray *priorityList;
    NSMutableArray *suggestList;
    UITextField *currentNameField;
    NSString *emailADD;
}

@end

@implementation AdvancedSetting
@synthesize nameScrollList, tb_suggestList, mainScrollView, lblBlockList, tb_FindPeople, tb_Email, blockListBG, prioriryScrollList,priorityListBG, lblBlockDetail,lblMutualFriendPref,lblPriorityDetail,lblPriorityList;
UITapGestureRecognizer *blockScrollGesture;
UITapGestureRecognizer *priorityScrollGesture;
int isScrollListEditing=-1;
const CGFloat width = 200;
const CGFloat height = 30;
const CGFloat margin = 10;
CGFloat blockList_X = 0;
CGFloat blockList_Y = 8;
CGFloat priorityList_X = 0;
CGFloat priorityList_Y = 8;
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
//    mainScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    nameScrollList.delegate = self;
    tb_suggestList.delegate = self;
    tb_suggestList.dataSource = self;
    nameFieldList = [NSMutableArray array];
    priorityList = [NSMutableArray array];
    suggestList = [NSMutableArray array];
    [nameScrollList setFrame:CGRectMake(10, blockListBG.frame.origin.y + 2, 300, 42)];
    blockScrollGesture = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(onTapBlockScrollView)];
    [blockScrollGesture setCancelsTouchesInView:NO];
    [nameScrollList addGestureRecognizer:blockScrollGesture];
    
    [prioriryScrollList setFrame:CGRectMake(10, priorityListBG.frame.origin.y + 2, 300, 42)];
    priorityScrollGesture = [[UITapGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(onTapPriorityScrollView)];
    [priorityScrollGesture setCancelsTouchesInView:NO];
    [prioriryScrollList addGestureRecognizer:priorityScrollGesture];
    
    [mainScrollView setContentSize:CGSizeMake(320, 480)];
	// Do any additional setup after loading the view.
//    [self addNewItemIntoNameList];
    [lblPriorityList setFont:FONT_NOKIA(18.0)];
    [lblPriorityDetail setFont:FONT_NOKIA(14.0)];
    [lblMutualFriendPref setFont:FONT_NOKIA(20.0)];
    [lblBlockList setFont:FONT_NOKIA(18.0)];
    [lblBlockDetail setFont:FONT_NOKIA(14.0)];
    
    //
    emailADD = @"abcxyz@yahoo.com";
    isScrollListEditing =-1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameScrollList:nil];
    [self setTb_suggestList:nil];
    [self setMainScrollView:nil];
    [self setLblBlockList:nil];
    [self setTb_FindPeople:nil];
    [self setTb_Email:nil];
    [self setBlockListBG:nil];
    [self setPrioriryScrollList:nil];
    [self setPriorityListBG:nil];
    [self setLblMutualFriendPref:nil];
    [self setLblBlockDetail:nil];
    [self setLblPriorityList:nil];
    [self setLblPriorityDetail:nil];
    [super viewDidUnload];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    BOOL result = NO;
    switch (isScrollListEditing) {
        case 0:
            if([nameFieldList indexOfObject:textField] == NSNotFound)
                result =  YES;
            break;
        case 1:
            if([priorityList indexOfObject:textField] == NSNotFound)
                result =  YES;
            break;
        default:
            break;
    }
    return result;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self cancelAddNameFieldFrom:textField];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self cancelAddNameFieldFrom:textField];
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newText;
    if(string.length >0)
        newText = [NSString stringWithFormat:@"%@%@",textField.text,string];
    else
        newText = [textField.text substringToIndex:[textField.text length] - 1];
    
    CGSize size = [newText sizeWithFont:[UIFont systemFontOfSize:17.0]];
    textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y, size.width + 20, size.height) ;
    currentNameField = textField;
    [self reloadTableViewDataSourceSearchByString:newText];
    return YES;
}

-(void)addNewItemIntoScrollList:(UIScrollView*)scrollList{
    UITextField *textField ;
    if(scrollList == nameScrollList)
        textField= [[UITextField alloc] initWithFrame:CGRectMake(blockList_X, 8, 10, height)];
    if(scrollList == prioriryScrollList)
        textField= [[UITextField alloc] initWithFrame:CGRectMake(priorityList_X, 8, 10, height)];
    textField.backgroundColor = [UIColor clearColor];
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    currentNameField = textField;
    [scrollList addSubview:textField];
    
    [scrollList setContentOffset:textField.frame.origin animated:YES];
    [textField becomeFirstResponder];
    if(scrollList == nameScrollList){
        tb_suggestList.frame = CGRectMake(10, blockListBG.frame.origin.y + blockListBG.frame.size.height, tb_suggestList.frame.size.width, tb_suggestList.frame.size.height);
        [mainScrollView setContentOffset:CGPointMake(0, lblBlockList.frame.origin.y)  animated:YES];
        scrollList.contentSize = CGSizeMake(blockList_X - margin > 0?blockList_X - margin:margin,height );
    }
    if(scrollList == prioriryScrollList){
        tb_suggestList.frame = CGRectMake(10, priorityListBG.frame.origin.y + priorityListBG.frame.size.height, tb_suggestList.frame.size.width, tb_suggestList.frame.size.height);
        [mainScrollView setContentOffset:CGPointMake(0, lblPriorityList.frame.origin.y)  animated:YES];
        scrollList.contentSize = CGSizeMake(priorityList_X - margin > 0?priorityList_X - margin:margin,height );
    }
    
}

-(void)reArrangeScrollList:(UIScrollView*)scrollList{
    CGPoint startPoint;
    if (scrollList == nameScrollList) {
        startPoint = CGPointMake(0, blockList_Y);
    }
    if(scrollList == prioriryScrollList){
         startPoint = CGPointMake(0, priorityList_Y);
    }
    
    for(int i = 0; i < [scrollList.subviews count]; i++){
        UITextField *item = [scrollList.subviews objectAtIndex:i];
        if([[scrollList.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]){
            CGRect rect = item.frame;
            [item setFrame:CGRectMake(startPoint.x, startPoint.y, rect.size.width, rect.size.height)];
            startPoint.x += rect.size.width + margin;
        }
    }
    scrollList.contentSize = CGSizeMake(startPoint.x,height );
    if (scrollList == nameScrollList) {
        blockList_X = startPoint.x;
    }
    if(scrollList == prioriryScrollList){
        priorityList_X = startPoint.x;
    }
    
    
}
-(void)reloadTableViewDataSourceSearchByString:(NSString*)text{
    //update suggestList
    [suggestList removeAllObjects];
    for (NSString* item in FriendList)
    {
        if ([item rangeOfString:text options: NSCaseInsensitiveSearch].location != NSNotFound){
            [suggestList addObject:item];
        }
    }
    if([suggestList count]>0){
        tb_suggestList.hidden = NO;
        [tb_suggestList reloadData];
    }
    else
    {
        tb_suggestList.hidden = YES;
    }
    
}
#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if(tableView == tb_suggestList)
        return [suggestList count];
    if (tableView == tb_FindPeople) {
        return [FindPeopleItemList count];
    }
    if(tableView == tb_Email)
        return [EmailSettingItemList count];
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == tb_suggestList)
        return nil;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
//    UIImageView *headerImage = [[UIImageView alloc] init]; //set your image/
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 40)];//set as you need
    headerLbl.backgroundColor = [UIColor clearColor];
    UIFont *newfont = FONT_NOKIA(18.0);
    [headerLbl setFont:newfont];
    if(tableView == tb_FindPeople)
        headerLbl.text = @"Find people with similar";
    if(tableView == tb_Email)
        headerLbl.text = @"Email";
//    [headerImage addSubview:headerLbl];
//    headerImage.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
    [headerView addSubview:headerLbl];
    
    return headerView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == tb_suggestList)
        return 0.0;
    return 40;
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
    cell.selectedBackgroundView = [tableView customSelectdBackgroundViewForCellAtIndexPath:indexPath];
    
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    [cell.textLabel setFont: FONT_NOKIA(17.0)];
    if(tableView == tb_suggestList){
        cell.textLabel.text = [suggestList objectAtIndex:indexPath.row];
    }
    if(tableView == tb_FindPeople){
        cell.textLabel.text = [FindPeopleItemList objectAtIndex:indexPath.row];
    }
    if(tableView == tb_Email){
        cell.textLabel.text = [EmailSettingItemList objectAtIndex:indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = emailADD;
                break;
            case 1:
                cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"key_EmailSetting"];
                break;
            default:
                break;
        }
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(tableView == tb_suggestList){
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [currentNameField setText:cell.textLabel.text];//= cell.textLabel.text;
        [nameFieldList addObject:currentNameField];
        CGSize size = [currentNameField.text sizeWithFont:[UIFont systemFontOfSize:17.0]];
        currentNameField.frame = CGRectMake(currentNameField.frame.origin.x, currentNameField.frame.origin.y, size.width + 30, size.height) ;
        switch (isScrollListEditing) {
            case 0:
                blockList_X += currentNameField.frame.size.width + margin;
                nameScrollList.contentSize = CGSizeMake(blockList_X - margin,height );
                [nameScrollList setNeedsDisplay];
                break;
            case 1:
                priorityList_X += currentNameField.frame.size.width + margin;
                prioriryScrollList.contentSize = CGSizeMake(priorityList_X - margin,height );
                [prioriryScrollList setNeedsDisplay];
                break;
            default:
                break;
        }
        
        [currentNameField resignFirstResponder];
        tb_suggestList.hidden = YES;
        [suggestList removeAllObjects];
        [tb_suggestList reloadData];
    }
    if(tableView == tb_FindPeople){
        if(cell.accessoryType == UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
//        switch (row) {
//            case 0:
//                ;
//                break;
//                
//            default:
//                break;
//        }
    }
    if(tableView == tb_Email){
        switch (row) {
            case 0:
                [self gotoEditEmail];
                break;
            case 1:
                [self gotoChooseNotificationType];
                break;
            default:
                break;
        }
    }
}

-(void) onTapBlockScrollView{
    if(!currentNameField.isEditing){
        isScrollListEditing = 0;
        [self addNewItemIntoScrollList:nameScrollList];
    }
}
-(void)onTapPriorityScrollView{
    if(!currentNameField.isEditing){
        isScrollListEditing = 1;
        [self addNewItemIntoScrollList:prioriryScrollList];
    }
}

-(void)cancelAddNameFieldFrom:(UITextField*)textField{
    [textField removeFromSuperview];
    switch (isScrollListEditing) {
        case 0:
            [nameFieldList removeObject:textField];
            [self reArrangeScrollList:nameScrollList];
            break;
        case 1:
            [priorityList removeObject:textField];
            [self reArrangeScrollList:prioriryScrollList];
            break;
        default:
            break;
    }

    tb_suggestList.hidden = YES;
}

-(void)gotoEditEmail{
    EditText *nameEditView = [[EditText alloc]initWithNibName:@"EditText" bundle:nil];
    [nameEditView initForEditting:emailADD andStyle:0];
    nameEditView.delegate = (id) self;
    [self.navigationController pushViewController:nameEditView animated:YES];
}

-(void)gotoChooseNotificationType{
    ListForChoose *genderView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [genderView setListType:LISTTYPE_EMAILSETTING];
    genderView.delegate=self;
    [self.navigationController pushViewController:genderView animated:YES];
}

- (void)saveChangedEditting:(EditText *)editObject{
    switch (editObject.getStyle) {
        case 0:
            emailADD = editObject.texfieldEdit.text;
            [tb_Email reloadData];
            break;
    }
}

#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
//    Profile* selected = [uvcList getCurrentValue];
//    switch ([uvcList getType]) {
//        case LISTTYPE_EMAILSETTING:
//            profileObj.s_relationShip = selected.s_relationShip;
//            [self updateProfileItemListAtIndex:profileObj.s_relationShip.rel_text andIndex:RELATIONSHIP];
//            break;
//        default:
//            break;
//    }
    [tb_Email reloadData];
}
@end
