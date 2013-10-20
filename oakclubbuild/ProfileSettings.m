//
//  ProfileSettings.m
//  OakClub
//
//  Created by VanLuu on 6/11/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "ProfileSettings.h"
#import "GenderSetting.h"
@interface ProfileSettings ()

@end

@implementation ProfileSettings
@synthesize imgAvatar, tbEditProfile;
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


#pragma mark UITableView-delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did selected row called");
    if(indexPath.row == 2){
        [self gotoChooseCity];
    }

}

- (void)viewDidUnload {
    [self setImgAvatar:nil];
    [self setTbEditProfile:nil];
    [super viewDidUnload];
}
#pragma mark ListForChoose DataSource/Delegate
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row{
    Profile* selected = [uvcList getCurrentValue];
}

- (void)gotoChooseCity {
    ListForChoose *locationView = [[ListForChoose alloc]initWithNibName:@"ListForChoose" bundle:nil];
    [locationView setListType:LISTTYPE_COUNTRY];
    locationView.delegate=self;
    [self.navigationController pushViewController:locationView animated:YES];
    
}
@end
