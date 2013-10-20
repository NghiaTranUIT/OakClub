//
//  Line.h
//  ChatTableTest
//
//  Created by Salm on 9/16/13.
//  Copyright (c) 2013 Vu. Luu Quang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject
@property (strong, nonatomic) NSMutableArray * components;
@property CGSize size;

-(void) appendText:(NSString *)str withSize:(CGSize)size andEmotData:(NSArray *)emotData;
@end
