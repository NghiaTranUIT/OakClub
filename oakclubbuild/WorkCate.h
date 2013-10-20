//
//  WorkCate.h
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkCate : NSObject<NSCopying>

@property (assign, nonatomic) int cate_id;
@property (strong, nonatomic) NSString *cate_name;
@end
