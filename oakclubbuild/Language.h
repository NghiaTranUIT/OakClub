//
//  Language.h
//  OakClub
//
//  Created by VanLuu on 11/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject

@property (assign, nonatomic) int ID;
@property (strong, nonatomic) NSString *name;

-(Language*) initWithID:(int)languageID;
+(NSMutableArray*)initArrayLanguageWithArray:(NSArray*)langList;
-(void) localizeNameOfLanguage;
@end
