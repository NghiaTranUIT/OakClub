//
//  SettingObject.h
//  OakClub
//
//  Created by VanLuu on 6/13/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Gender.h"
@interface SettingObject : NSObject{
    NSString* _fb_id;
    NSString* _purpose_of_search;
    NSString* _gender_of_search;
    
    int _range;
    
    int _age_from;
    int _age_to;
    
    bool _interested_new_people;
    bool _interested_friends;
    bool _interested_friend_of_friends;
    
    //    NSString* _location_id;
    //    NSString* _location_name;
    //
    //    NSString* _country;
    //    NSString* _country_code;
    Location* _location;
    float _latitude;
    float _longitude;
}
@property NSString* fb_id;
@property NSString* purpose_of_search;
@property NSString* gender_of_search;

@property int range;

@property int age_from;
@property int age_to;

@property bool interested_new_people;
@property bool interested_friends;
@property bool interested_friend_of_friends;

//@property NSString* location_id;
//@property NSString* location_name;
//
//@property NSString* country;
//@property NSString* country_code;
@property Location* location;
@property float latitude;
@property float longitude;
@end
