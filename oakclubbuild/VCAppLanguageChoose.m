//
//  VCAppLanguageChoose.m
//  OakClub
//
//  Created by Salm on 11/26/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCAppLanguageChoose.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"

@interface VCAppLanguageChoose ()
{
    NSDictionary *appLanguages;
    AppDelegate *appDel;
}

@property (weak, nonatomic) IBOutlet UITableView *languageTable;
@end

@implementation VCAppLanguageChoose

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appLanguages = AppLanguageList;
        appDel = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self customBackButtonBarItem];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_HELVETICANEUE_LIGHT(18.0);//[UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:[@"Language" localize]];
    label.textColor = [UIColor blackColor]; // change this color
    //[label setAdjustsFontSizeToFitWidth: YES];
    [label sizeToFit];
    [label setFrame: CGRectMake(0, 0, 150, 80)];//(150, 80)];
    self.navigationItem.titleView = label;
    
    
    [self.view localizeAllViews];
    [self.navigationController.view localizeAllViews];
}

-(void)viewWillDisappear:(BOOL)animated
{
    for(UIView* subview in [self.navigationController.navigationBar subviews]){
        if([subview isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appLanguages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:MyIdentifier];
	}
    
    NSString *langID = [[appLanguages allKeys] objectAtIndex:indexPath.row];
    cell.textLabel.text = [appLanguages valueForKey:langID];
    [cell.textLabel setFont:FONT_HELVETICANEUE_LIGHT(15.0)];
    NSString* appLang = [[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage];
    if ([langID isEqualToString:appLang])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell localizeAllViews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *langID = [[appLanguages allKeys] objectAtIndex:indexPath.row];
    NSString* appLang = [[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage];
    
    if (![langID isEqualToString:appLang])
    {
        [[NSUserDefaults standardUserDefaults] setObject:langID forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDel updateLanguageBundle];
        [appDel loadDataForList:^(NSError *e) {
            if (!e)
            {
                //[appDel parseProfileWithData:data];
                //[appDel popSnapshotQueue];
            }
        }];
        
        [self.view localizeAllViews];
        [self.navigationController.view localizeAllViews];
    }
    
    [tableView reloadData];
}

@end
