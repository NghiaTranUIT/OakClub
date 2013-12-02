//
//  RelationShip.m
//  oakclubbuild
//
//  Created by VanLuu on 5/14/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "RelationShip.h"
#import "AppDelegate.h"
@implementation RelationShip
-(id) copyWithZone: (NSZone *) zone{
    RelationShip *copyObj = [[RelationShip allocWithZone: zone] init];
    copyObj.rel_status_id = self.rel_status_id;
    copyObj.rel_text = [self.rel_text copyWithZone:zone];
    return copyObj;
}
-(RelationShip*)initWithNSString:(NSString*)relText{
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    RelationShip* rel = [RelationShip alloc];
    rel.rel_text = relText;
    for (int i =0 ; i < [appDel.relationshipList count]; i++) {
//        RelationShip *temp = [RelationShip alloc];
        NSDictionary* temp = [appDel.relationshipList objectAtIndex:i];
        if([relText isEqualToString:[temp objectForKey:@"rel_text"] ])
            rel.rel_status_id = [[temp objectForKey:@"rel_status_id"] integerValue];
    }
    return rel;
}
@end
