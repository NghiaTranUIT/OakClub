//
//  Language.m
//  OakClub
//
//  Created by VanLuu on 11/3/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Language.h"
#import "AppDelegate.h"
@implementation Language
-(id) copyWithZone: (NSZone *) zone{
    Language *copyObj = [[Language allocWithZone: zone] init];
    copyObj.ID = self.ID;
    copyObj.name = [self.name copyWithZone:zone];
    return copyObj;
}

-(Language*) initWithID:(int)languageID{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    Language* lang = [Language alloc];
    lang.ID = languageID;
    for (int i = 0; i < [appDel.languageList count]; i++){
        if(languageID == [[[appDel.languageList objectAtIndex:i] valueForKey:@"id"]integerValue]){
            NSString* name  = [[appDel.languageList objectAtIndex:i] valueForKey:@"name"]  ;
            lang.name = name;
            return lang;
        }
    }
    return nil;
}
+(NSMutableArray*)initArrayLanguageWithArray:(NSArray*)langList{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (int i =0 ; i< langList.count; i++){
        Language *newLang = [[Language alloc]initWithID:[[langList objectAtIndex:i] integerValue]];
        if(newLang != nil)
            [result addObject:newLang];
    }
    return result;
}

-(void) localizeNameOfLanguage{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    for (int i = 0; i < [appDel.languageList count]; i++){
        if(self.ID == [[[appDel.languageList objectAtIndex:i] valueForKey:@"id"]integerValue]){
            NSString* name  =[[appDel.languageList objectAtIndex:i] valueForKey:@"name"]  ;
            self.name = name;
        }
    }
}
@end
