//
//  menuViewController.m
//  oakclubbuild
//
//  Created by VanLuu on 3/29/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "menuViewController.h"
#import "AppDelegate.h"
#import "menuCell.h"
#import "Define.h"
#import "UIView+Localize.h"
#import "NSString+Utils.h"
#import "VCLogout.h"
#import "Animation.h"

@interface menuViewController ()
{
    AppDelegate *appDel;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *confirmLogoutView;
@property (strong, nonatomic) IBOutlet VCLogout *logoutViewController;

@end

@implementation menuViewController
@synthesize name, numCoins, btnAvatar, avatar;
@synthesize tableView, logoutViewController;


- (IBAction)onTouchAvatar:(id)sender {
    [appDel  showMyProfile];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];


    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
                                                animated:NO];
//    if(IS_OS_7_OR_LATER){
//        [self.view setFrame:[[UIScreen mainScreen]applicationFrame]];
//    }
//    else{
        [self.view setFrame:[[UIScreen mainScreen]applicationFrame]];
//    }
    
    if (self) {
        // Custom initialization
        appDel = (AppDelegate *) [UIApplication sharedApplication].delegate;
        imageNames = [self getListMenuItems];
        // getAccountSetting
        
        NSMutableArray *m_index = [NSMutableArray array];
        numberNotifications = [NSMutableArray array];
        for (int i = 0; i < [imageNames count]; i++)
        {
            [numberNotifications addObject:[NSNumber numberWithUnsignedInt:0]];
            
            [m_index addObject:[NSNumber numberWithUnsignedInt:i]];
        }
             
        NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithArray:m_index] forKeys:imageNames];
        
        nameIndex = [NSDictionary dictionaryWithDictionary:m_dict];
    }
    return self;
}

-(void)setUsername:(NSString *)_name{
    username = _name;
}

-(void) setUIInfo:(Profile*)profile{
    username = profile.s_Name;
    numPoints = [NSString stringWithFormat:@"%@ coins", [profile.num_points stringValue]];
    //[self downloadAvatarImage:profile.s_Avatar ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numCoins.text =  numPoints;
    self.name.text = username;
    [self.avatar setImage:imageAvatar];
    [self.btnAvatar setBackgroundImage:imageAvatar forState:UIControlStateNormal];
    self.tableView.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2.5) ;
}
-(void)viewWillAppear:(BOOL)animated{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage] isEqualToString:value_appLanguage_VI])
    {
        numPoints = [numPoints stringByReplacingOccurrencesOfString:@"coins" withString:@"xu"];
    }
    else
    {
        numPoints = [numPoints stringByReplacingOccurrencesOfString:@"xu" withString:@"coins"];
    }
    
    self.numCoins.text =  numPoints;
    [self.view localizeAllViews];
    
    
    Profile *myProfile = ((AppDelegate *) [UIApplication sharedApplication].delegate).myProfile;
    [appDel.imagePool getImageAtURL:myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
        if (img)
        {
            [self.avatar setImage:img];
        }
    }];
    
    [self.view localizeAllViews];
    
    [tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)goToChat:(id)sender {
//    [appDel showChat];
//}
//
//- (IBAction)goToMyLink:(id)sender {
//    [appDel showMylink];
//}
//
//- (IBAction)goToSnapshoot:(id)sender {
//    [appDel showSnapshoot];
//}
//
//- (IBAction)goToVisitor:(id)sender {
//    [appDel showVisitor];
//}
//
//- (IBAction)logOut:(id)sender {
//    [appDel logOut];
//}
//
//- (IBAction)goToHangOut:(id)sender {
//    [appDel showHangOut];
//}



- (void)viewDidUnload {
    [self setAvatar:nil];
    [self setName:nil];
    [self setNumCoins:nil];
    [self setBtnAvatar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [imageNames count];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;//80;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tbView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"menuCell";
//    for (NSString *name in imageNames) {
        //        menuCell *cel= [[menuCell alloc]init];
        menuCell *cell = nil;
        cell = (menuCell*)[tbView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSString *icon = [imageNames objectAtIndex:indexPath.row];
        NSString *label = [imageNames objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[menuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    UIView *bgColorSelected = [[UIView alloc] init];
    [bgColorSelected setBackgroundColor:[UIColor clearColor]];
    cell.selectedBackgroundView = bgColorSelected;
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%menu_@.png", name]];
        [cell setItemMenu:icon AndlabelName:[NSString localizeString:label]];
//    if(indexPath.row == 3){
//        UIImage* tellFriend_BG = [UIImage imageNamed:@"Menu_btn_Facebook.png"];
//        [cell setItemBackground:tellFriend_BG andHighlight:tellFriend_BG];
//        
//        [cell.labelMenu setFont:[UIFont fontWithName:cell.labelMenu.font.fontName size:18]];
//    }

    Animation *anim = [[Animation alloc] init];
    [anim setView:cell];
    [anim setIndex:0];
    [anim setStep:2];
    
    float duration = 0.1f;
    
    [anim translationX:0 withFromValue:10 * indexPath.row withToValue:-2 * indexPath.row withDuration:duration];
    [anim translationY:1 withFromValue:-2 * indexPath.row withToValue:2 * indexPath.row withDuration:duration];
    [anim translationX:2 withFromValue:-2 * indexPath.row withToValue:0 * indexPath.row withDuration:duration];
    [anim translationY:3 withFromValue:2 * indexPath.row withToValue:0 * indexPath.row withDuration:duration];
    
    //[anim start];
    
    if(indexPath.row == 0){// && self.avatar.image != nil){
        
        [appDel.imagePool getImageAtURL:appDel.myProfile.s_Avatar withSize:PHOTO_SIZE_SMALL asycn:^(UIImage *img, NSError *error, bool isFirstLoad) {
            [cell setItemIcon:img];
        }];
    }
    NSNumber* number = [numberNotifications objectAtIndex:indexPath.row];
    [cell setNotification:[number unsignedIntValue]];
//    }
    
    [cell localizeAllViews];
    
    return cell;
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"selected id %i",indexPath.row);
#if ENABLE_DEMO
    switch (indexPath.row) {
        case 1:
            [appDel  showSimpleSnapshotThenFocus:YES];
            break;
        case 0:
            [appDel  showMyProfile];
            break;
        case 2:
            [appDel  showSnapshotSettings];
            break;
        case 3:
            [self activityAction];
            //            [appDel  logOut];
            break;
        default:
            break;
    }
#else
    switch (indexPath.row) {
        case 0:
            [appDel  showHangOut];
            break;
        case 1:
            [appDel  showSnapshoot];
            break;
        case 2:
            [appDel  showChat];
            break;
        case 3:
            [appDel  showMylink];
            break;
        case 4:
            [appDel  showVisitor];
            break;
        case 5:
            [appDel  showInvite];
            break;
        case 6:
            [appDel showGetPoints];
            break;
        case 7:
            [appDel  logOut];
            break;
        default:
            break;
    }
#endif
    
}

#pragma mark Notification

-(void)setNotificationValue:(int)value atIndex:(NSNumber*)index
{
    uint indexValue = [index unsignedIntValue];
    NSNumber* number = [NSNumber numberWithUnsignedInt:value];
    [numberNotifications removeObjectAtIndex:indexValue];
    [numberNotifications insertObject:number atIndex:indexValue];
    
    [tableView reloadData];
}

-(void)setChatNotification:(int)num
{
//    NSNumber* index = [nameIndex objectForKey:@"Chat"];
//    [self setNotificationValue:num atIndex:index];
}

-(void)setVisitorsNotification:(int)num
{
    NSNumber* index = [nameIndex objectForKey:@"Visitors"];
    [self setNotificationValue:num atIndex:index];
}

-(void)setMyLinksNotification:(int)num
{
    NSNumber* index = [nameIndex objectForKey:@"My Links"];
    [self setNotificationValue:num atIndex:index];
}


- (NSArray *)getListMenuItems{
#if ENABLE_DEMO
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu_simple" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imgNames = [NSPropertyListSerialization propertyListFromData:plistData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:&format
                                                           errorDescription:&error];
#else
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imageNames = [NSPropertyListSerialization propertyListFromData:plistData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:&format
                                                           errorDescription:&error];
#endif
    
    if (!imgNames) {
        NSLog(@"Failed to read image names. Error: %@", error);
    }
    return imgNames;
}


/*
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
*/
#pragma mark handle button touch
-(void)activityAction
{
    NSString* body = [@"Join www.OakClub.com and meet many cool singles nearby. Safe, trustworthy and private." localize];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:body,[UIImage imageNamed:@"Default-image_share"],nil] applicationActivities:nil];
    [activityViewController setValue:[@"I am in OakClub, you?" localize] forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)onTouchLogout:(id)sender {
//    VCLogout* logoutView= [[VCLogout alloc]init];
    
    [logoutViewController.view setFrame:CGRectMake(0, self.view.frame.size.height-logoutViewController.view.frame.size.height, 246, logoutViewController.view.frame.size.height)];
    [logoutViewController.view localizeAllViews];
    [self.view addSubview:logoutViewController.view];
//    [self.navigationController pushViewController:logoutViewController animated:NO];
    [UIView animateWithDuration:0.4
                     animations:^{
                         [logoutViewController.view setFrame:CGRectMake(0, self.view.frame.size.height-logoutViewController.view.frame.size.height, 246, logoutViewController.view.frame.size.height)];
                     }completion:^(BOOL finished) {
                     }];
}


@end
