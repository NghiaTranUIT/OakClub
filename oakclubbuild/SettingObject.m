//
//  SettingObject.m
//  OakClub
//
//  Created by VanLuu on 6/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SettingObject.h"
#import "AppDelegate.h"

@implementation SettingObject
-(void)loadSettingUseCompletion:(void(^)(NSError *err))completion
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [request getPath:URL_getSnapshotSetting parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        if (dict)
        {
            NSMutableDictionary * data= [dict valueForKey:key_data];
            self.purpose_of_search = [data valueForKey:key_purpose_of_search];
            self.gender_of_search = [data valueForKey:key_gender_of_search];
            
            self.age_from = [[data valueForKey:key_age_from] integerValue];
            self.age_to = [[data valueForKey:key_age_to] integerValue];
            NSMutableDictionary* status_interested_in = [data valueForKey:key_status_interested_in];
            self.interested_new_people = [[status_interested_in valueForKey:key_new_people] boolValue];
            self.interested_friend_of_friends = [[status_interested_in valueForKey:key_status_fof] boolValue];
            self.interested_friends = [[status_interested_in valueForKey:key_friends] boolValue];
            
            self.range = [[data valueForKey:key_range] integerValue];
            
            NSMutableDictionary *location = [data valueForKey:key_location];
            self.location = [[Location alloc] initWithNSDictionary:location];
            
            self.gender_of_search = self.gender_of_search;
            
            if (completion)
            {
                completion(nil);
            }
        }
        else if (completion)
        {
            completion(e);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"URL_getSnapshotSetting - Error Code: %i - %@",[error code], [error localizedDescription]);
        if (completion)
        {
            completion(error);
        }
    }];
}
@end
