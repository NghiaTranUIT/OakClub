//
//  UIGridViewRow.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridViewRowMultipleSection.h"


@implementation UIGridViewRowMultipleSection


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.userInteractionEnabled = YES;
	}
	
    return self;
}





@end
