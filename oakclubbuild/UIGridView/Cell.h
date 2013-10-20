//
//  Cell.h
//  naivegrid
//
//  Created by Apirom Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewCellMultipleSection.h"
#import "Define.h"
@interface Cell : UIGridViewCellMultipleSection {

}

@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *photoNumber;
@property (weak, nonatomic) IBOutlet UILabel *friendsNumber;
@property (weak, nonatomic) IBOutlet UIImageView *status;

-(void)setMutualFriends:(NSUInteger)number;

@end
