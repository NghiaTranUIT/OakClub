//
//  NavBarOakClub.h
//  oakclubbuild
//
//  Created by hoangle on 4/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBarOakClub : UINavigationBar{
    UIViewController *rightView;
    UIViewController *currentView;
//    BOOL useRightButton;
    NSString *rightButtonClass;
}
@property (strong, nonatomic) UIView *customView;

- (void)menuPressed:(id)sender;
- (void)optionPressed:(id)sender;
- (void) setHeaderName:(NSString *)name;
-(void) setRightViewController:(UIViewController *)view;
-(void) setCurrentViewController:(UIViewController *)view;
-(void)setRightButton:(NSString*)className;
-(void)setNotifications:(int)count;
-(void)addToHeader:(UIView*)subview;

@property (weak, nonatomic) IBOutlet UILabel *labelNotifications;
@property (weak, nonatomic) IBOutlet UIImageView *imageNotifications;
@property (strong, nonatomic) UILabel *badge;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (strong, nonatomic) UILabel *header;
@end
