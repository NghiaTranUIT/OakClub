//
//  Profile.m
//  oakclubbuild
//
//  Created by VanLuu on 4/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "Profile.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "ImageInfo.h"

@interface Profile()
{
    NSMutableArray *requester;
}
//@property (strong, nonatomic) NSString *s_Avatar;
//@property (weak, nonatomic) UIImage *img_Avatar;
@end

@implementation Profile

@synthesize s_Name, img_Avatar, i_Points, s_ProfileStatus, s_FB_id, s_ID, dic_Roster,num_Photos, s_gender, num_points,/* num_unreadMessage,*/ s_passwordXMPP, s_usenameXMPP, arr_photos, s_aboutMe, s_birthdayDate, s_interested,a_language, s_location,s_relationShip, c_ethnicity, s_age, s_meetType, s_popularity, s_interestedStatus, s_snapshotID, a_favorites, s_user_id,s_school,i_work, i_height,i_weight, num_MutualFriends, num_Liked,num_Viewed, s_Email, distance, active, s_video;
@synthesize is_deleted;
@synthesize is_blocked;
@synthesize is_available;
@synthesize is_match;
@synthesize unread_message;
@synthesize status;
@synthesize s_Avatar = _s_avatar;
-(id)init {
    self = [super init];
    self.i_weight=0;
    self.i_height=0;
    self.img_Avatar = [[UIImage alloc] init];
    return self;
}

-(void)setS_Avatar:(NSString *)avatar
{
    if (![avatar isEqualToString:_s_avatar])
    {
        _s_avatar = avatar;
        [self downloadAvatarImage];
    }
}

-(Profile*) parseProfile:(NSString *)responeString{
    Profile *_profile = [[Profile alloc] init];
    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSMutableArray * data= [dict valueForKey:key_data];
    if(data!= nil && [data count] > 0){
        NSMutableDictionary *objectData = [data objectAtIndex:0];
        _profile.s_Name = [objectData valueForKey:key_name];
        _profile.s_Avatar = [objectData valueForKey:key_avatar];
        _profile.s_FB_id = [objectData valueForKey:key_facebookID];
        _profile.s_ID = [objectData valueForKey:key_profileID];
        _profile.s_ProfileStatus = [objectData valueForKey:key_online];
        _profile.num_Photos =[objectData valueForKey:key_countPhotos];
    }
    return _profile;
}

+(void) getListPeople:(NSString*)service andParams:(NSDictionary*)params handler:(void(^)(NSMutableArray*,int))resultHandler
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    [request getPath:service parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        
        
        if(![data isKindOfClass:[NSNull class]])
        {
            int count = 0;
            NSMutableArray* list = [[NSMutableArray alloc] init];
            for (int i = 0; i < [data count]; i++)
            {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                Profile *_profile = [[Profile alloc] init];
//                _profile.s_Name = [objectData valueForKey:key_name];
//                _profile.s_Avatar = [objectData valueForKey:key_avatar];
                _profile.s_FB_id = [objectData valueForKey:key_facebookID];
                _profile.s_ID = [objectData valueForKey:key_profileID];
//                int is_viewed = [[objectData valueForKey:@"is_viewed"] intValue];
//                if(is_viewed == 0){
//                    _profile.is_match = true;
//                }
//                _profile.s_ProfileStatus = [objectData valueForKey:key_online];
////                _profile.num_Photos =[objectData valueForKey:key_countPhotos];
//                int is_viewed = [[objectData valueForKey:@"is_viewed"] intValue];
//                
//                if( is_viewed == 0)
//                {
//                    count++;
//                }
                
                [list addObject:_profile];
            }
            
            if(resultHandler != nil)
                resultHandler(list, count);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ Error Code: %i - %@", service, [error code], [error localizedDescription]);
    }];
    
}

+(void) getListPeople:(NSString*)service handler:(void(^)(NSMutableArray*,int))resultHandler
{
    AFHTTPClient *request = [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    
    NSDictionary *params_checkedmeout = [[NSDictionary alloc]initWithObjectsAndKeys:@"0",@"start",@"999",@"limit", nil];
    [request getPath:service parameters:params_checkedmeout success:^(__unused AFHTTPRequestOperation *operation, id JSON) {

        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        
        
        if(![data isKindOfClass:[NSNull class]])
        {
            int count = 0;
            NSMutableArray* list = [[NSMutableArray alloc] init];
            for (int i = 0; i < [data count]; i++)
            {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                Profile *_profile = [[Profile alloc] init];
                _profile.s_Name = [objectData valueForKey:key_name];
                _profile.s_Avatar = [objectData valueForKey:key_avatar];
                _profile.s_FB_id = [objectData valueForKey:key_facebookID];
                _profile.s_ID = [objectData valueForKey:key_profileID];
                _profile.s_ProfileStatus = [objectData valueForKey:key_status];
                _profile.num_Photos =[objectData valueForKey:key_countPhotos];
                int is_viewed = [[objectData valueForKey:@"is_viewed"] intValue];
                
                if( is_viewed == 0)
                {
                    count++;
                }
                
                [list addObject:_profile];
            }
            
            if(resultHandler != nil)
                resultHandler(list, count);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ Error Code: %i - %@", service, [error code], [error localizedDescription]);
    }];

}


+(NSMutableArray*) parseProfileToArrayByJSON:(NSData *)jsonData{
    NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
//    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSMutableArray * data= [dict valueForKey:key_data];
    if(![data isKindOfClass:[NSNull class]]){
        for (int i = 0; i < [data count]; i++) {
            Profile *_profile = [[Profile alloc] init];
            NSMutableDictionary *objectData = [data objectAtIndex:i];
            _profile.s_Name = [objectData valueForKey:key_name];
            _profile.s_Avatar = [objectData valueForKey:key_avatar];
            _profile.s_FB_id = [objectData valueForKey:key_facebookID];
            _profile.s_ID = [objectData valueForKey:key_profileID];
            _profile.s_ProfileStatus = [objectData valueForKey:key_online];
            _profile.num_Photos =[objectData valueForKey:key_countPhotos];
            
            [_arrProfile addObject:_profile];
            
        }
    }
    else{
        data = nil;
    }

    return _arrProfile;
}


+(NSMutableArray*) parseProfileToArray:(NSString *)responeString{
    NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
    
    
    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSMutableArray * data= [dict valueForKey:key_data];
    
    for (int i = 0; i < [data count]; i++) {
        Profile *_profile = [[Profile alloc] init];
        NSMutableDictionary *objectData = [data objectAtIndex:i];
        _profile.s_Name = [objectData valueForKey:key_name];
        _profile.s_Avatar = [objectData valueForKey:key_avatar];
        _profile.s_FB_id = [objectData valueForKey:key_facebookID];
        _profile.s_ID = [objectData valueForKey:key_profileID];
        _profile.s_ProfileStatus = [objectData valueForKey:key_online];
        _profile.num_Photos =[objectData valueForKey:key_countPhotos];
        [_arrProfile addObject:_profile];
        
    }
    
    return _arrProfile;
}

-(NSMutableArray*) parseForGetFeatureList:(NSData *)jsonData{
//    if([responeString length] == 0)
//        return nil;
    NSMutableArray *_arrProfile = [[NSMutableArray alloc] init];
    
//    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSMutableArray * data= [dict valueForKey:key_data];
    
    
    for (int i = 0; ![data isKindOfClass:[NSNull class]] && i < [data count]; i++)
    {
        Profile *_profile = [[Profile alloc] init];
        NSMutableDictionary *objectData = [data objectAtIndex:i];
        _profile.s_Name = [objectData valueForKey:key_name];
        _profile.s_Avatar = [objectData valueForKey:key_avatar];
        _profile.s_FB_id = [objectData valueForKey:key_facebookID];
        _profile.s_ID = [objectData valueForKey:key_profileID];
        _profile.num_Photos =[objectData valueForKey:key_countPhotos];
        [_arrProfile addObject:_profile];
        
    }
    
    return _arrProfile;
}
/*
 // Vanancy - unused
-(ProfileSetting*) parseForGetAccountSetting:(NSData *)jsonData{
//    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    NSMutableDictionary * data= [dict valueForKey:key_data];
    self.s_Name = [data valueForKey:key_name];
    self.s_Avatar = [data valueForKey:key_avatar];
    self.num_points = [data valueForKey:key_points];
    self.s_ID = [data valueForKey:key_profileID];
    
    NSMutableDictionary* search_condition = [data valueForKey:@"search_condition"];
    
    ProfileSetting* setting = [[ProfileSetting alloc] init];
    setting.purpose_of_search = [search_condition valueForKey:@"purpose_of_search"];
    setting.gender_of_search = [search_condition valueForKey:@"gender_of_search"];
    setting.range = [[search_condition valueForKey:@"range"] intValue];
    setting.age_from = [[search_condition valueForKey:@"age_from"] intValue];
    setting.age_to = [[search_condition valueForKey:@"age_to"] intValue];
    
    NSMutableDictionary* dict_StatusInterestedIn = [search_condition valueForKey:@"status_interested_in"];
    setting.interested_new_people = [[dict_StatusInterestedIn valueForKey:@"new_people"] boolValue];
    setting.interested_friends = [[dict_StatusInterestedIn valueForKey:@"friends"] boolValue];
    setting.interested_friend_of_friends = [[dict_StatusInterestedIn valueForKey:@"status_fof"] boolValue];
    
    NSMutableDictionary* dict_Location = [search_condition valueForKey:@"location"];
    setting.location= [Location alloc];
    [setting.location setID:[dict_Location valueForKey:@"id"]];
    [setting.location setName:[dict_Location valueForKey:@"name"]];
    [setting.location setCountry:[dict_Location valueForKey:@"country"]];
    [setting.location setCountryCode:[dict_Location valueForKey:@"country_code"]];

//    setting.latitude = [[dict_Location valueForKey:@"latitude"] floatValue];
//    setting.longitude = [[dict_Location valueForKey:@"longitude"] floatValue];
    
    return setting;
    
}
 */

-(NSMutableArray*) parseMutualList:(NSMutableArray *)jsonData
{
    NSMutableArray* friends = [[NSMutableArray alloc] init];
    
    for(int i = 0 ; i < [jsonData count]; i++)
    {
        NSMutableDictionary* x = [jsonData objectAtIndex:i];
        ImageInfo* p = [[ImageInfo alloc] init];
        
        p.name = [x valueForKey:key_name];
        if([p.name isKindOfClass:[NSNull class]])
            p.name = @"";
        p.avatar = [x valueForKey:key_avatar];
        if([p.avatar isKindOfClass:[NSNull class]])
            p.avatar = @"";
        p.s_ID = [x valueForKey:@"id"];
        
        [friends addObject:p];
    }
    /*
    //add data for test
    ImageInfo* p = [[ImageInfo alloc] init];
    
    p.avatar =@"https://graph.facebook.com/119186158094085/picture";
    p.name =  @"Ngô Quỳnh Anh";
    p.s_ID = @"119186158094085";
    
    [friends addObject:p];
    */
    return friends;
}

+(NSMutableArray*) parseListPhotos:(NSData *)jsonData
{
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSMutableDictionary *data= [dict valueForKey:key_data];
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    
    if(data != nil)
    {
        NSMutableArray *photosData = [data valueForKey:key_data];
        
        if(photosData != nil && ![photosData isKindOfClass:[NSNull class]])
        {
            for(int i = 0 ; i < [photosData count]; i++)
            {
                NSMutableDictionary* photo = [photosData objectAtIndex:i];
                NSString* photoLink = [photo valueForKey:@"tweet_image_link"];
                //don't import avatar into photo list
                int is_avatar =[[photo valueForKey:@"is_profile_picture"] integerValue];
                if(photoLink != nil && !is_avatar)
                    [ photos addObject: photoLink];
            }
        }
    
    }

    
    return photos;
}

+(NSMutableDictionary*) parseListPhotosIncludeID:(NSData *)jsonData
{
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSMutableDictionary *data= [dict valueForKey:key_data];
    NSMutableDictionary* photos = [[NSMutableDictionary alloc] init];
    
    if(data != nil)
    {
        NSMutableArray *photosData = [data valueForKey:key_data];
        
        if(photosData != nil && ![photosData isKindOfClass:[NSNull class]])
        {
            for(int i = 0 ; i < [photosData count]; i++)
            {
                NSMutableDictionary* photo = [photosData objectAtIndex:i];
                NSString* photoLink = [photo valueForKey:@"tweet_image_link"];
                NSString* photoID = [photo valueForKey:@"id"];
                if(photoLink != nil)
                {
                    [photos setValue:photoLink forKey:photoID];
                }
            }
        }
        
    }
    
    
    return photos;
}

-(void) parseProfileWithDictionary:(NSMutableDictionary*)data
{
    self.s_Name = [data valueForKey:key_name];
    self.s_Avatar = [data valueForKey:key_avatar];
    int ethnicityIndex =[[data valueForKey:key_ethnicity] integerValue];
    self.c_ethnicity= [[Ethnicity alloc]initWithID:ethnicityIndex];
    self.s_birthdayDate =[data valueForKey:key_birthday];
    self.s_age = [self  pareAgeFromDateString:self.s_birthdayDate];
//    self.s_meetType = [data valueForKey:key_meet_type];
    self.s_popularity = [self parsePopolarityFromInt:[[data valueForKey:key_popularity] integerValue]];
    self.s_interested = [Gender alloc];// [self parseGender:[data valueForKey:key_interested]] ;
    self.s_interested = [self parseGender:[data valueForKey:key_interested]] ;
    self.a_language = [Language initArrayLanguageWithArray:[data valueForKey:key_language]];// [data valueForKey:key_language];
    if(a_language == nil || [a_language count]==0)
    {
        Language* langDefault = [[Language alloc]initWithID:0];
        a_language = [[NSMutableArray alloc] initWithObjects:langDefault , nil];
    }
    self.i_work = [[WorkCate alloc]initWithID:[[data valueForKey:key_work] integerValue]];
//    self.i_work.cate_id = [[data valueForKey:key_work] integerValue];
    self.i_weight =MAX([[data valueForKey:key_weight] integerValue], 0);
    self.i_height = MAX([[data valueForKey:key_height] integerValue], 0);
    self.s_school = [data valueForKey:key_school];
    self.s_Email = [data valueForKey:key_email];
    
    NSMutableDictionary *dict_Location = [data valueForKey:key_location];
    self.s_location = [[Location alloc] initWithNSDictionary:dict_Location];
    self.s_relationShip = [RelationShip alloc];
    self.s_relationShip = [self parseRelationShip:[data valueForKey:key_relationship]] ;
    self.s_gender = [Gender alloc];
    self.s_gender = [self parseGender:[data valueForKey:key_gender]];
    self.s_aboutMe = [data valueForKey:key_aboutMe];
    self.s_video = [data valueForKey:key_video];
    if([self.s_aboutMe isKindOfClass:[NSNull class]]){
        self.s_aboutMe = @"";
    }
    //load photos of profile
    self.arr_photos = [[NSMutableArray alloc] init];
    NSMutableArray *_arrTemp = [[NSMutableArray alloc] init];
    _arrTemp = [data valueForKey:key_photos];
    self.num_Photos = [_arrTemp count];
    for (int i = 0; i < self.num_Photos; i++) {
        NSMutableDictionary *photoItem = [_arrTemp objectAtIndex:i];
        if ([[photoItem valueForKey:key_isProfilePicture] integerValue]) {
            self.s_Avatar =[photoItem valueForKey:key_photoLink];
        }
        [self.arr_photos addObject: [photoItem valueForKey:key_photoLink]];
    }
    if(self.s_Avatar == nil){
        self.s_Avatar = [data valueForKey:key_avatar];
    }

    //load favorite list
    NSMutableArray *dict_Fav = [data valueForKey:@"fav"];
    
    if (dict_Fav) {
        NSMutableArray* a = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [dict_Fav count]; i++)
        {
            NSMutableDictionary* favourite = [dict_Fav objectAtIndex:i];
            
            [a addObject:[favourite objectForKey:@"fav_name"]];
        }
        
        self.a_favorites = [NSArray arrayWithArray:a];
    }
}
-(void) parseForGetProfileInfo:(NSData *)jsonData{
    //    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSMutableDictionary * data= [dict valueForKey:key_data];
    
    self.s_ID = [data valueForKey:key_profileID];
    
    [self parseProfileWithDictionary:data];
    
    self.s_usenameXMPP = [data valueForKey:key_usernameXMPP];
    self.s_passwordXMPP = [data valueForKey:key_passwordXMPP];
    
    [self getRosterListIDSync:^(void){
    }];
}
-(void) parseForGetHangOutProfile:(NSData *)jsonData{
//    NSData *jsonData = [responeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSMutableDictionary * data= [dict valueForKey:key_data];
    
    self.s_ID = [data valueForKey:key_profileID];
    
    [self parseProfileWithDictionary:data];
    
    self.s_usenameXMPP = [data valueForKey:key_usernameXMPP];
    self.s_passwordXMPP = [data valueForKey:key_passwordXMPP];
    
    [self getRosterListIDSync:^(void){
    }];
}

- (void) parseRoster:(NSArray *)rosterList
{
    NSMutableDictionary *rosterDict = [[NSMutableDictionary alloc] init];

    self.unread_message = 0;
    self.new_mutual_attractions = 0;
    for (int i = 0; rosterList!=nil && i < [rosterList count]; i++) {
        NSMutableDictionary *objectData = [rosterList objectAtIndex:i];
        
        NSLog(@"%@", objectData);
        
        if(objectData != nil)
        {
            NSString* profile_id = [objectData valueForKey:key_profileID];
            bool deleted = [[objectData valueForKey:@"is_deleted"] boolValue];
            bool blocked = [[objectData valueForKey:@"is_blocked"] boolValue];
            //bool deleted_by = [[objectData valueForKey:@"is_deleted_by_user"] boolValue];
            bool blocked_by = [[objectData valueForKey:@"is_blocked_by_user"] boolValue];
            // vanancyLuu : cheat for crash
            if(!deleted && !blocked && !blocked_by )
            {
                bool isMatch = [[objectData valueForKey:key_match] boolValue];
                BOOL isViewMatch =[[objectData valueForKey:@"status"] intValue] == MatchUnViewed?YES:NO;
                if(isViewMatch){
                   self.new_mutual_attractions ++;
                }
                int unread_count = [[objectData valueForKey:@"unread_count"] intValue];
                
                Profile *profile = [[Profile alloc] init];
                profile.s_ID =profile_id;
                profile.unread_message = unread_count;
                profile.is_deleted = deleted;
                profile.is_blocked = blocked;
                profile.is_match = isMatch;
                profile.status =[[objectData valueForKey:@"status"] intValue];
                profile.s_Name =[objectData valueForKey:@"name"];
                profile.s_Avatar = [objectData valueForKey:@"avatar"];
                [rosterDict setObject:profile forKey:profile.s_ID];
                NSLog(@"%d. unread message: %d", i, unread_count);
                
                self.unread_message += unread_count;
            }
        }
    }
    
    NSLog(@"unread message: %d", self.unread_message);
    
    self.dic_Roster = rosterDict;//[NSDictionary dictionaryWithDictionary:rosterDict];
    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
    [appDel loadFriendsList];
}

- (void) getRosterListIDSync:(void(^)(void))handler
{
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
//                                                                path:URL_getListChat
//                                                          parameters:nil];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    [httpClient getPath:URL_getListChat parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
        NSError *err;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&err];
        NSLog(@"%@", @"getRosterListIDSync");
        [self parseRoster:[dict valueForKey:key_data]];
        if(handler != nil){
            handler();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get list chat Error: %@", error);
    }];
    
    // sync
//    [queue addOperation:operation];
//    [queue waitUntilAllOperationsAreFinished];
    NSLog(@"Get chat list completed");
}

-(void) parseGetSnapshotToProfile:(NSData*)jsonData{
    NSMutableDictionary * data;
    if([jsonData isKindOfClass:[NSDictionary class]]){
        data=jsonData;
    }else{
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        data= [dict valueForKey:key_data];
    }

//    self.s_Name = [NSString stringWithFormat:@"%@ %@",[data valueForKey:key_last_name],[data valueForKey:key_first_name]] ;
    self.s_Name = [data valueForKey:key_name];
    self.s_ID = [data valueForKey:key_profileID];
    self.s_age = [data valueForKey:key_age];
    self.s_snapshotID =[data valueForKey:key_snapshotID];
    //load photos of profile
    self.arr_photos = [[NSMutableArray alloc] init];
    NSMutableArray *_arrTemp = [[NSMutableArray alloc] init];
    _arrTemp = [data valueForKey:key_photos];
    self.num_Photos = [_arrTemp count];
    for (int i = 0; i < self.num_Photos; i++) {
        NSMutableDictionary *photoItem = [_arrTemp objectAtIndex:i];
        if ([[photoItem valueForKey:key_isProfilePicture] integerValue]) {
            self.s_Avatar =[photoItem valueForKey:key_photoLink];
        }
        [self.arr_photos addObject: [photoItem valueForKey:key_photoLink]];
    }
    if(self.s_Avatar == nil){
        self.s_Avatar = [data valueForKey:key_avatar];
    }
    //load mutual friends list
    self.arr_MutualFriends = [[NSMutableArray alloc]init];
    self.arr_MutualFriends = [self parseMutualList:[data valueForKey:key_MutualFriends]];

    //load mutual interest list
    self.arr_MutualInterests = [[NSMutableArray alloc]init];
    self.arr_MutualInterests = [self parseMutualList:[data valueForKey:key_ShareInterests]];

    self.num_Viewed =[[data valueForKey:key_viewed] integerValue];
    self.num_Liked =[[data valueForKey:key_liked] integerValue];
    self.distance = [[data valueForKey:key_distance] integerValue];
    self.active = [[data valueForKey:key_active] integerValue];
}

-(Gender*) parseGender:(NSNumber *)genderCode{
    Gender* gender = [Gender alloc];
    gender.ID = -1;
    gender.text = @"";
    if([genderCode isKindOfClass:[NSNull class]])
        return gender;
    switch ([genderCode intValue]) {
        case 0:
            gender.ID = 0;
            gender.text = @"Female";
            break;
        case 1:
            gender.ID = 1;
            gender.text = @"Male";
            break;
        case 2:
            gender.ID = 2;
            gender.text = @"Both";
            break;
        default:
            break;
    }
    return gender;
}
-(RelationShip *)parseRelationShip:(NSNumber *)relationShip{
    if([relationShip  isKindOfClass:[NSNull class]]){
        return nil;
    }
    RelationShip *rel = [RelationShip alloc];
    rel.rel_status_id = [relationShip integerValue];
    
//    NSString *relation=@"N/A";
    switch ([relationShip intValue]) {
        case single:
            rel.rel_text = RELATIOSHIP_SINGLE;
            break;
        case complicated:
            rel.rel_text = RELATIOSHIP_COMPLICATED;
            break;
        case married:
            rel.rel_text = RELATIOSHIP_MARRIED;
            break;
        case inRelationship:
            rel.rel_text = RELATIOSHIP_INRELATIONSHIP;
            break;
        case engaged:
            rel.rel_text = RELATIOSHIP_ENGAGED;
            break;
        case openRelationship:
            rel.rel_text = RELATIOSHIP_OPENRELATIONSHIP;
            break;
        case widowed:
            rel.rel_text = RELATIOSHIP_WIDOWED;
            break;
        case separated:
            rel.rel_text = RELATIOSHIP_SEPARATED;
            break;
        case divorced:
            rel.rel_text = RELATIOSHIP_DIVORCED;
            break;
        default:
            rel.rel_text = @"";
            break;
    }
    return rel;
}
-(NSString *)pareAgeFromDateString:(NSString *)s_dateOfBirth {
//    NSString *myString = 3-3-2011;
    if([s_dateOfBirth isKindOfClass:[NSNull class]])
        return @"";
    NSString *result=@"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/DD/YYYY"];
    NSDate *dateOfBirth = [dateFormatter dateFromString:s_dateOfBirth];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day])))
    {
        result =[@([dateComponentsNow year] - [dateComponentsBirth year] - 1) stringValue];
        
    } else {
        
        result = [@([dateComponentsNow year] - [dateComponentsBirth year]) stringValue];
    }
    return result;
}

-(NSString *)parsePopolarityFromInt:(int) popular{
    NSString * result=@"";
    switch (popular) {
        case verylow :
            result = POPULARITY_VERY_LOW_TEXT;
            break;
        case low:
            result = POPULARITY_LOW_TEXT;
            break;
        case average:
            result = POPULARITY_AVERAGE_TEXT;
            break;
        case high:
            result = POPULARITY_HIGHT_TEXT;
            break;
        case veryhigh:
            result = POPULARITY_VERY_HIGHT_TEXT;
            break;
        default:
            break;
    }
    return result;
}

+(AFHTTPRequestOperation*)getAvatarSync:(NSString*)url callback:(void(^)(UIImage*))handler
{
    AFHTTPClient *httpClient;
    
    if(!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]))
    {       // check if this is a valid link
        httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
    }
    else{
        httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
    }
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:url
                                                      parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *avatar = [UIImage imageWithData:responseObject];
        
         if(handler != nil)
             handler(avatar);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Download image Error: %@", error);
     }];
    
    return operation;
}


+(AFHTTPRequestOperation*)getAvatarSyncWithOperation:(NSString*)url callback:(void(^)(AFHTTPRequestOperation*, UIImage*))handler
{
    AFHTTPClient *httpClient;
    
    if(!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]))
    {       // check if this is a valid link
        httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
    }
    else{
        httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
    }
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:url
                                                      parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *avatar = [UIImage imageWithData:responseObject];
         
         if(handler != nil)
             handler(operation, avatar);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Download image Error: %@", error);
     }];
    
    return operation;
}
/*
+(void) countMutualFriends:(NSString*)profileID callback:(void(^)(NSString*))handler
{
    NSLog(@"profileID : %@",profileID);
    AFHTTPClient* httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:profileID,key_profileID, nil];
    [httpClient getPath:URL_getDetailMutualFriends parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        
        if(data != nil)
        {
            NSString *mutualCount = [NSString stringWithFormat:@"%i",[data count]];
            handler(mutualCount);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
}
*/
- (void) SaveSetting{
    NSString * name = self.s_Name;
    NSString *gender = [NSString stringWithFormat:@"%i",self.s_gender.ID];
    NSString *birthday = self.s_birthdayDate;
    NSString *interested = [NSString stringWithFormat:@"%i",self.s_interested.ID];
    NSString *relationship = [NSString stringWithFormat:@"%i",self.s_relationShip.rel_status_id];
    NSString *height = [NSString stringWithFormat:@"%i",self.i_height];
    NSString *weight= [NSString stringWithFormat:@"%i",self.i_weight];
    NSString *school = self.s_school;
    NSString *ethnicity = [NSString stringWithFormat:@"%i",self.c_ethnicity.ID];
    NSString *lang = @"";
    for(Language* langItem in self.a_language){
        lang = [lang stringByAppendingString:[NSString stringWithFormat:@"%i,",langItem.ID]];
    }
    if([lang length] >0)
        lang = [lang substringToIndex:[lang length]-1];
//    NSString *lang = [self.a_language componentsJoinedByString:@","];
    NSString *loc = [NSString stringWithFormat:@"%@",self.s_location.ID];
    NSString *work = [NSString stringWithFormat:@"%i",self.i_work.cate_id];
    NSString *email = self.s_Email;
    
    AFHTTPClient* httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:
                            name,@"name",// < 20 characters
                            gender,@"gender",// 0/1
                            birthday,@"birthday",// dd/mm/yyyy
                            email,@
                            "email",
                            interested,@"interested",// 0/1
                            relationship,@"relationship_status",//rel_status_id
                            height,@"height",//100 < h <300
                            weight,@"weight",//30 < w < 120
                            school,@"school",
                            ethnicity,@"ethnicity",// string value
                            lang,@"language",
                            loc,@"location_id",//location_id
                            work,@"work",
                            self.s_aboutMe,@"about_me",//< 256 characters
                            nil
                            ];
    
    NSLog(@"Set hangout profile params: %@", params);
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    [httpClient postPath:URL_setProfileInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        NSMutableArray * data= [dict valueForKey:key_data];
        NSLog(@"Set Hangout profile result: %@", data);
//        return YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" SaveSetting Profile Error Code: %i - %@",[error code], [error localizedDescription]);
//        return NO;
    }];
//    return YES;
}
-(id) copyWithZone: (NSZone *) zone
{
    Profile *accountCopy = [[Profile allocWithZone: zone] init];
    accountCopy.img_Avatar = img_Avatar;
    accountCopy.s_ID = [s_ID copyWithZone:zone];
    accountCopy.s_school = [s_school copyWithZone:zone];
    accountCopy.s_Name = [s_Name copyWithZone:zone];
    accountCopy.s_Email = [s_Email copyWithZone:zone];
    accountCopy.s_Avatar = [s_Avatar copyWithZone:zone];
    accountCopy.s_ProfileStatus = [s_ProfileStatus copyWithZone:zone];
    accountCopy.i_Points = i_Points;
    accountCopy.s_FB_id = [s_FB_id copyWithZone:zone];
    accountCopy.num_Photos = num_Photos;
    accountCopy.arr_photos = [arr_photos copyWithZone:zone];
    accountCopy.num_points = [num_points copyWithZone:zone];
    accountCopy.s_gender = [s_gender copy];
//    accountCopy.num_unreadMessage = [num_unreadMessage copyWithZone:zone];
    accountCopy.s_birthdayDate = [s_birthdayDate copyWithZone:zone];
    accountCopy.s_age = [s_age copyWithZone:zone];
    accountCopy.s_interested = s_interested;
    accountCopy.s_relationShip = [s_relationShip copy];
    accountCopy.i_work = [i_work copy];
    accountCopy.i_weight = i_weight;
    accountCopy.i_height = i_height;
    accountCopy.s_location = [s_location copy];
    accountCopy.a_language = [a_language mutableCopy];
    accountCopy.s_aboutMe = [s_aboutMe copyWithZone:zone];
    accountCopy.c_ethnicity = [c_ethnicity copy];
    accountCopy.s_meetType = [s_meetType copyWithZone:zone];
    accountCopy.s_popularity = [s_popularity copyWithZone:zone];
    accountCopy.s_snapshotID = [s_snapshotID copyWithZone:zone];
    accountCopy.s_interestedStatus = [s_interestedStatus copyWithZone:zone];
    accountCopy.s_passwordXMPP = [s_passwordXMPP copyWithZone:zone];
    accountCopy.s_usenameXMPP = [s_usenameXMPP copyWithZone:zone];
    accountCopy.dic_Roster = [dic_Roster copyWithZone:zone];
    accountCopy.a_favorites = [a_favorites copyWithZone:zone];
    accountCopy.s_user_id = [s_user_id copyWithZone:zone];
    accountCopy.num_MutualFriends = num_MutualFriends ;
    accountCopy.arr_MutualFriends = [arr_MutualFriends copyWithZone:zone];
    accountCopy.arr_MutualInterests = [arr_MutualInterests copyWithZone:zone];
    accountCopy.is_deleted = is_deleted;
    accountCopy.is_blocked = is_blocked ;
    accountCopy.is_available = is_available ;
    accountCopy.is_match = is_match;
    accountCopy.status = status;
    accountCopy.unread_message = unread_message;
    accountCopy.distance = distance;
    accountCopy.active = active;
    
    return accountCopy;
}


-(int) countTotalNotifications
{
#if ENABLE_DEMO
    return self.new_mutual_attractions + self.unread_message;
#else
    return self.new_mutual_attractions + self.unread_message;
#endif
    
}


-(void)loadPhotosByProfile:(void(^)(NSMutableArray*))handler{
    AFHTTPClient* request;
    for (int proIndex=0; proIndex < [self.arr_photos count]; proIndex++) {
        if(![self.arr_photos[proIndex] isKindOfClass:[UIImageView class]]) {
            NSString *link = [self.arr_photos objectAtIndex:proIndex];
            if(![link isEqualToString:@""]){
                if(!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]))
                {       // check if this is a valid link
                    request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:DOMAIN_DATA]];
                    [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                        UIImage *image = [UIImage imageWithData:JSON];
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
//                        CGRect frame = self.sv_photos.frame;
//                        frame.origin.x = CGRectGetWidth(frame) * proIndex;
//                        frame.origin.y = 0;
//                        imageView.frame = frame;
                        [imageView setContentMode:UIViewContentModeScaleAspectFit];
                        [self.arr_photos replaceObjectAtIndex:proIndex withObject:imageView];
                        if((proIndex == [self.arr_photos count]-1) && handler != nil)
                            handler(self.arr_photos);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                    }];
                }
                else{
                    request = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@""]];
                    [request getPath:link parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                        UIImage *image = [UIImage imageWithData:JSON];
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
//                        CGRect frame = self.sv_photos.frame;
//                        frame.origin.x = CGRectGetWidth(frame) * proIndex;
//                        frame.origin.y = 0;
//                        imageView.frame = frame;
                        [imageView setContentMode:UIViewContentModeScaleAspectFit];
                        [self.arr_photos replaceObjectAtIndex:proIndex withObject:imageView];
                        if((proIndex == [self.arr_photos count]-1) && handler != nil)
                            handler(self.arr_photos);

                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
                    }];
                }
            }
        }
    }
}

-(void)downloadAvatarImage
{
    AFHTTPRequestOperation* operation = [Profile getAvatarSync:self.s_Avatar callback:^(UIImage *avatar)
    {
        self.img_Avatar = avatar;
        
        [self dispatchAvatar];
    }];
    [operation start];
}

-(void)tryGetImageAsync:(id<ImageRequester>)_requester
{
    if (self.img_Avatar == nil)
    {
        if (!requester)
        {
            requester = [[NSMutableArray alloc] init];
        }
        
        if (![requester containsObject:_requester])
        {
            [requester addObject:_requester];
        }
    }
    else
    {
        [_requester setImage:self.img_Avatar];
    }
}

-(void)trySetImageSync:(UIImage *)img
{
    self.img_Avatar = img;
    [self dispatchAvatar];
}

-(void)dispatchAvatar
{
    for (id<ImageRequester> _requester in requester)
    {
        [_requester setImage:self.img_Avatar];
    }
}
-(NSInteger)age
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDate = [[NSDate alloc] init];
    birthDate = [dateFormatter dateFromString:self.s_birthdayDate];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthDate
                                       toDate:now
                                       options:0];
    return [ageComponents year];
}

-(NSString*)languagesDescription
{
//    AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
//    NSArray *languagesList = appDel.languageList;
    NSMutableArray *langDesc = [[NSMutableArray alloc] init];
    for (Language *lang in self.a_language)
    {
        [langDesc addObject:lang.name];
    }
    
    return [langDesc componentsJoinedByString:@","];
}
#pragma mark request API
-(void)resetUnreadMessageWithFriend:(Profile*)friend{
    AFHTTPClient* httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:friend.s_ID,key_profileID, nil];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    [httpClient postPath:URL_setReadMessages parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            self.unread_message -= friend.unread_message;
            friend.unread_message = 0;
            AppDelegate *appDel = (id) [UIApplication sharedApplication].delegate;
            [appDel updateNavigationWithNotification];
            NSLog(@"POST READ-MESSAGES SUCCESS!!!");
        }
        else
            NSLog(@"POST READ-MESSAGES FAIL...");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];

}

-(void)setViewedMatchMutualWithFriend:(Profile*)friend{
    AFHTTPClient* httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:friend.s_ID,key_profileID, nil];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    [httpClient postPath:URL_setViewedMutualMatch parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSError *e=nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
        BOOL status= [[dict valueForKey:key_status] boolValue];
        if(status){
            friend.status = MatchViewed;
            self.new_mutual_attractions --;
            NSLog(@"setViewedMatchMutualWithFriend SUCCESS!!!");
        }
        else
            NSLog(@"setViewedMatchMutualWithFriend FAIL...");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
    }];
    
}

-(void)getProfileInfo:(void(^)(void))handler{
    AFHTTPClient* request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
     NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:self.s_ID,key_profileID,@"true",@"is_full", nil];
    [request getPath:URL_getProfileInfo parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        [self parseForGetHangOutProfile:JSON];
        if(handler)
            handler();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error Code: %i - %@",[error code], [error localizedDescription]);
        
     }];

}

@end