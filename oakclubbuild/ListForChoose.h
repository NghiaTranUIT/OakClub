//
//  ListForChoose.h
//  oakclubbuild
//
//  Created by VanLuu on 5/8/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "AFHTTPClient+OakClub.h"
#import "Profile.h"
#import "SettingObject.h"
#import "UIViewController+Custom.h"
#import "Ethnicity.h"

@protocol ListForChooseDelegate;
@interface ListForChoose : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSArray *dataSource;
    int type;
    BOOL isMultiChoose;
    AFHTTPClient *request;
    id<ListForChooseDelegate>   _delegate;
    Profile* currentValue;
    SettingObject* settingValue;
    NSString *resultValue;
}
@property(nonatomic,assign) id<ListForChooseDelegate>   delegate;   
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(void)setListType:(int) typeID;
-(int)getType;
-(Profile*)getCurrentValue;
-(SettingObject*)getSettingValue;
-(void)setCityListWithCountryCode:(NSString*)countryCode;
@end

@protocol ListForChooseDelegate<NSObject>

@optional
- (void)ListForChoose:(ListForChoose *)uvcList didSelectRow:(NSInteger)row;
-(Profile *)setDefaultValue:(ListForChoose *)uvcList ;
-(SettingObject*)setDefaultSettingValue:(ListForChoose *)uvcList ;
@end