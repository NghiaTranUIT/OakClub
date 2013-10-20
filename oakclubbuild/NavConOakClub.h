//
//  NCOakClub.h
//  oakclubbuild
//
//  Created by hoangle on 4/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavConOakClub : UINavigationController<UINavigationControllerDelegate>
@property (strong   , nonatomic) NSString *headerName;
-(void)customBackButtonBarItem;
@end
