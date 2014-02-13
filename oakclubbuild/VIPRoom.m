//
//  VIPRoom.m
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VIPRoom.h"
#import "AppDelegate.h"
#import "OakClubIAPHelper.h"
#import "VIPRoomCell.h"

#define kVIPRoomCellId @"VIPRoomCell"

@interface VIPRoom ()
{
    AppDelegate *appDel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *vipView;

@end

@implementation VIPRoom

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDel = (id) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:kVIPRoomCellId bundle:nil] forCellReuseIdentifier:kVIPRoomCellId];
    
    if (appDel.myProfile.is_vip) {
        self.tableView.hidden = YES;
        self.vipView.hidden = NO;
    } else {
        self.tableView.hidden = NO;
        self.vipView.hidden = YES;
        
        if (appDel.vipPurchaseList) {
            [self.tableView reloadData];
        } else {
            [self reload];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    appDel.myProfile.is_vip = TRUE;
    
    self.tableView.hidden = YES;
    self.vipView.hidden = NO;
}


- (void)reload {
    appDel.vipPurchaseList = nil;
    
    //show loading
    self.loadingIndicator.hidden = NO;
    
    [[OakClubIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            appDel.vipPurchaseList = products;
            [self.tableView reloadData];
            
            self.loadingIndicator.hidden = YES;
        }
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 5
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (appDel.vipPurchaseList) {
        return appDel.vipPurchaseList.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVIPRoomCellId forIndexPath:indexPath];
    
    SKProduct * product = (SKProduct *) appDel.vipPurchaseList[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = appDel.vipPurchaseList[indexPath.row];
    
    [[OakClubIAPHelper sharedInstance] buyProduct:product];
}

@end
