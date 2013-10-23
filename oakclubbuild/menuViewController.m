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

@interface menuViewController () <ImageRequester>
{
    AppDelegate *appDel;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation menuViewController
@synthesize name, numCoins, btnAvatar, avatar;
@synthesize tableView;


- (IBAction)onTouchAvatar:(id)sender {
    [appDel  showMyProfile];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [profile tryGetImageAsync:self];
}

-(void)setImage:(UIImage *)img
{
    imageAvatar = img;
}

-(void) downloadAvatarImage:(NSString*)link{
    AFHTTPClient *request;
    if(![link isEqualToString:@""]){
        if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
        {       // check if this is a valid link
            request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
            [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                imageAvatar = [UIImage imageWithData:JSON];
//                [self.btnAvatar setBackgroundImage:imageAvatar forState:UIControlStateDisabled];
                [self.avatar setImage:imageAvatar];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
            }];
        }
        else{
            request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
            [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                imageAvatar = [UIImage imageWithData:JSON];
                [self.avatar setImage:imageAvatar];
//                [self.btnAvatar setBackgroundImage:imageAvatar forState:UIControlStateDisabled];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
            }];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numCoins.text =  numPoints;
    self.name.text = username;
//    self.avatar.image = imageAvatar;
    [self.avatar setImage:imageAvatar];
    [self.btnAvatar setBackgroundImage:imageAvatar forState:UIControlStateNormal];
}
-(void)viewWillAppear:(BOOL)animated{
    NSString* strCoins;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage] isEqualToString:value_appLanguage_VI])
        strCoins = @"coins";
    else
        strCoins = @"xu";
    numPoints = [numPoints stringByReplacingOccurrencesOfString:strCoins withString:[NSString localizeString:strCoins]];
    self.numCoins.text =  numPoints;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [imageNames count];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"menuCell";
//    for (NSString *name in imageNames) {
        //        menuCell *cel= [[menuCell alloc]init];
        menuCell *cell = nil;
        cell = (menuCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSString *icon = [imageNames objectAtIndex:indexPath.row];
        NSString *label = [imageNames objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[menuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    
//        UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%menu_@.png", name]];
        [cell setItemMenu:icon AndlabelName:[NSString localizeString:label]];
    
    NSNumber* number = [numberNotifications objectAtIndex:indexPath.row];
    [cell setNotification:[number unsignedIntValue]];
//    }
    return cell;
     
}

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
    NSNumber* index = [nameIndex objectForKey:@"Chat"];
    [self setNotificationValue:num atIndex:index];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu_demo" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error; NSPropertyListFormat format;
    NSArray *imageNames = [NSPropertyListSerialization propertyListFromData:plistData
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
    
    if (!imageNames) {
        NSLog(@"Failed to read image names. Error: %@", error);
    }
    return imageNames;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"selected id %i",indexPath.row);
#if ENABLE_DEMO
    switch (indexPath.row) {
        case 0:
            [appDel  showSimpleSnapshot];
            break;
        case 1:
            [appDel  showChat];
            break;
        case 2:
            [appDel  showMutualMatches];
            break;
        case 3:
            [appDel  showSnapshotSettings];
            break;
        case 4:
            [appDel  logOut];
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

/*
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
*/

@end
