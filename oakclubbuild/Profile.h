//
//  Profile.h
//  oakclubbuild
//
//  Created by VanLuu on 4/1/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

#import "AFHTTPClient+OakClub.h"
#import "AFHTTPRequestOperation.h"

#import "ProfileSetting.h"
#import "Location.h"
#import "WorkCate.h"
#import "RelationShip.h"
#import "Gender.h"

@protocol ImageRequester <NSObject>

-(void)setImage:(UIImage *)img;

@end

@interface Profile : NSObject <NSCopying> {
    NSString *s_Name; // name of profile. < 20 characters
    NSString *s_ID; // profile ID.
    NSString *s_Avatar; // image link.
    UIImage *img_Avatar; //avatar image
    NSString *s_ProfileStatus; // "Online".
    int i_Points; // points of profile.
    NSString * s_FB_id; // Facebook ID
    NSNumber *num_Photos;
    NSMutableArray *arr_photos;
    NSNumber *num_points;
    Gender *s_gender; // 0 - 1
    NSNumber *num_unreadMessage;
    NSString *s_birthdayDate; // dd/mm/yyyy
    NSString *s_age;
    Gender *s_interested;
    RelationShip *s_relationShip; //rel_status_id
    WorkCate *i_work; // cate_id
    int i_weight; // 30 < w < 120
    int i_height; // 100 < h < 300
    NSString *s_school;
    Location *s_location; //location_id
    NSMutableArray *a_language;
    NSString *s_aboutMe; // 256 characters
    NSString *s_ethnicity; // string
    NSString *s_meetType;
    NSString *s_popularity;
    NSString *s_snapshotID;
    NSString *s_interestedStatus;
    NSString *s_passwordXMPP;
    NSString *s_usenameXMPP;
    NSDictionary *dic_Roster; // list chat with Friends.
    
    NSArray* a_favorites;
    NSString* s_user_id;
    NSString* s_Email;
    int numberMutualFriends;
    bool is_deleted;
    bool is_blocked;
    bool is_available;
    bool is_newMutualMatch;
    
    int unread_message;
    int new_visitors;
    int new_gifts;
    int new_mutual_attractions;
}

@property (strong, nonatomic) NSString *s_Name;
@property (strong, nonatomic) NSString *s_Email;
@property (strong, nonatomic) NSString *s_ID; 
@property (strong, nonatomic) NSString *s_Avatar;
@property (strong, nonatomic) UIImage *img_Avatar;
@property (strong, nonatomic) NSString *s_ProfileStatus;
@property (strong, nonatomic) NSString *s_birthdayDate;
@property (strong, nonatomic) NSString *s_age;
@property (strong, nonatomic) Gender *s_interested;
@property (strong, nonatomic) RelationShip *s_relationShip;
@property (strong, nonatomic) WorkCate *i_work;
@property (assign, nonatomic) int i_weight;
@property (assign, nonatomic) int i_height;
@property (strong, nonatomic) NSString *s_school;
@property (strong, nonatomic) Location *s_location;
@property (strong, nonatomic) NSMutableArray *a_language;
@property (strong, nonatomic) NSString *s_aboutMe;
@property (strong, nonatomic) NSString *s_ethnicity;
@property (strong, nonatomic) NSString *s_meetType;
@property (strong, nonatomic) NSString *s_popularity;
@property (strong, nonatomic) NSString *s_interestedStatus;
@property (strong, nonatomic) NSString *s_snapshotID;
@property (strong, nonatomic) NSString *s_passwordXMPP;
@property (strong, nonatomic) NSString *s_usenameXMPP; 
@property (assign, nonatomic) int i_Points; 
@property (strong, nonatomic) NSString *s_FB_id;
@property (strong, nonatomic) NSNumber *num_Photos;
@property (strong, nonatomic) NSMutableArray *arr_photos;
@property (strong, nonatomic) NSNumber *num_points;
@property (strong, nonatomic) Gender *s_gender;
@property (strong, nonatomic) NSNumber *num_unreadMessage;

@property (strong, nonatomic) NSDictionary *dic_Roster;
@property NSArray* a_favorites;
@property NSString* s_user_id;
@property (assign, nonatomic) int numberMutualFriends;
@property (assign, nonatomic) bool is_deleted;
@property (assign, nonatomic) bool is_blocked;
@property (assign, nonatomic) bool is_available;
@property (assign, nonatomic) bool is_newMutualMatch;
@property int unread_message;
@property int new_visitors;
@property int new_gifts;
@property int new_mutual_attractions;

+(NSMutableArray*) parseMutualFriends:(NSData *)jsonData;
+(NSMutableArray*) parseProfileToArray:(NSString *)responeString;
+(NSMutableArray*) parseProfileToArrayByJSON:(NSData *)jsonData;
-(NSMutableArray*) parseForGetFeatureList:(NSData *)jsonData;
-(ProfileSetting*) parseForGetAccountSetting:(NSData *)jsonData;
+(Gender*) parseGender:(NSNumber *)genderCode;
-(void) parseProfileWithDictionary:(NSMutableDictionary*)data;
-(void) parseForGetHangOutProfile:(NSData *)jsonData;
-(void) parseGetSnapshotToProfile:(NSData *)jsonData;
- (void) SaveSetting;
+(NSMutableArray*) parseListPhotos:(NSData *)jsonData;

+(void) countMutualFriends:(NSString*)profileID callback:(void(^)(NSString*))handler;
+(AFHTTPRequestOperation*)getAvatarSync:(NSString*)url callback:(void(^)(UIImage*))handler;

+(void) getListPeople:(NSString*)service handler:(void(^)(NSMutableArray*,int))resultHandler;
+(void) getListPeople:(NSString*)service andParams:(NSDictionary*)params handler:(void(^)(NSMutableArray*,int))resultHandler;
-(int) countTotalNotifications;

-(void)loadPhotosByProfile:(void(^)(NSMutableArray*))handler;

-(void)tryGetImageAsync:(id<ImageRequester>)requester;
-(void)trySetImageSync:(UIImage *)img;
-(void)dispatchAvatar;
@end