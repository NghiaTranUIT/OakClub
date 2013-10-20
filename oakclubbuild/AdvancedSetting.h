//
//  AdvancedSetting.h
//  OakClub
//
//  Created by VanLuu on 6/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditText.h"
#import "ListForChoose.h"
@interface AdvancedSetting : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,ListForChooseDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *nameScrollList;
@property (weak, nonatomic) IBOutlet UITableView *tb_suggestList;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblBlockList;
@property (weak, nonatomic) IBOutlet UITableView *tb_FindPeople;
@property (weak, nonatomic) IBOutlet UITableView *tb_Email;
@property (weak, nonatomic) IBOutlet UIImageView *blockListBG;
@property (weak, nonatomic) IBOutlet UIScrollView *prioriryScrollList;
@property (weak, nonatomic) IBOutlet UIImageView *priorityListBG;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualFriendPref;
@property (weak, nonatomic) IBOutlet UILabel *lblBlockDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblPriorityList;
@property (weak, nonatomic) IBOutlet UILabel *lblPriorityDetail;

@end
