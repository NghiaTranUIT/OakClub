//
//  AppLifeCycleDelegate.h
//  OakClub
//
//  Created by Salm on 11/5/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppLifeCycleDelegate <NSObject>
- (void)applicationDidBecomeActive:(UIApplication *)application;
@end