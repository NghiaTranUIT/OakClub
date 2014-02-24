//
//  Define.h
//  oakclubbuild
//
//  Created by VanLuu on 4/2/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#ifndef oakclubbuild_Define_h
#define oakclubbuild_Define_h

//demo version FLAG
#define ENABLE_DEMO true
#define USE_STAGING false
#define USE_LOCALTEST false
#define USE_MAINHOST true
#define USE_STAGING_MB false
#define USE_STAGING_IOS false

#define DAN_CHEAT false
//#define DAN_ACCESSTOKEN @"537613816294876|a7c00e11b3c816d4b6d9edad86fc16c6"
#define DAN_ACCESSTOKEN @"CAAHo9PiL7dwBABLVeIqWTGFwC5BPfjl8zq66SIufQLO39WhamZB76h2Ku5TmZB79f6SJnSXJK1j8ksVOYKJwZB9TT9dTiRXtYsn2kgnEOwZCNkdbitnDqHgZCul3Ez5LIzJeuofWWAFCZAAQBsUkzFCB7oZChE1uC7tZAdRvYJkY98SZAubpMrxjG"
//#define DAN_FACEBOOKID @"1640117326"
#define DAN_FACEBOOKID @"511391007"

//===============FLAG FOR ENABLE/DISABLE FEATURES============
//disable hereTo and show me in Snapshot Settings
#define DISABLE_HERETO_SHOWME

//disable policty
#define DISABLE_POCLICY true

// enable Select location manually
//#define ENABLE_LOCATION_MANUALLY

//view other's profile with full data
#define VIEWPROFILE_FULLDATA true

//show matchmaker in leftmenu
#define ENABLE_MATCHMAKER false

//show viproom in leftmenu
#define ENABLE_VIPROOM false

//show verification in leftmenu
#define ENABLE_VERIFICATION true

//add include facebook friends in snapshot settings
#define ENABLE_INCLUDE_FACEBOOKFRIEND true

//check lastest version of the app
#define ENABLE_CHECK_APP_VERSION true
#define APPSTORE_LINK @"https://itunes.apple.com/app/id788399950?mt=8"
#define IOS_PLATFORM @"2"

//Hangout
#define sOnline @"Online"
#define LOG_HTTP false

// Snapshot
#define answerYES @"YES"
#define answerNO @"NO"
#define answerMAYBE @"MAYBE"

//================ service API link ================
//#define DOMAIN @"http://staging.oakclub.com/app_dev.php"

#define PHOTO_SIZE_LARGE CGSizeMake(320, 320)
#define PHOTO_SIZE_320 CGSizeMake(320, 320)
#define PHOTO_SIZE_SMALL CGSizeMake(100, 100)

#undef DOMAIN
#if USE_LOCALTEST
#define HOSTNAME @"local.oakclub.com"
#define DOMAIN @"http://local.oakclub.com"
#define DOMAIN_DATA @"http://data1.oakclub.com/"
#define DOMAIN_VIDEO @"http://local.oakclub.com/oakclub_upload/"
#define MAX_UPLOAD_PHOTO_SIZE 8192000 //~8MB
#define MAX_UPLOAD_VIDEO_SIZE 81920000 //~8MB
#define URL_PHOTO @"http://staging.oakclub.com/load_photo.php"
#endif
#if USE_STAGING
#define HOSTNAME @"staging.oakclub.com"
#define DOMAIN @"http://staging.oakclub.com"
#define DOMAIN_DATA @"http://data1.oakclub.com/"
#define DOMAIN_VIDEO @"http://staging.oakclub.com/oakclub_upload/"
#define MAX_UPLOAD_PHOTO_SIZE 8192000 //~8MB
#define MAX_UPLOAD_VIDEO_SIZE 81920000 //~8MB
#define URL_PHOTO @"http://staging.oakclub.com/load_photo.php"
#endif
#if USE_MAINHOST
#define HOSTNAME @"xmpp.oakclub.com"
#define DOMAIN @"https://oakclub.com"
#define DOMAIN_DATA @"http://data2.oakclub.com/" //data2
#define DOMAIN_VIDEO @"http://oakclub.com/datanew/"
#define MAX_UPLOAD_PHOTO_SIZE 3072000 //~3MB
#define MAX_UPLOAD_VIDEO_SIZE 3072000 //~3MB
#define URL_PHOTO @"http://oakclub.com/load_photo.php"
#endif
#if USE_STAGING_MB
#define HOSTNAME @"staging.oakclub.com"
#define DOMAIN @"http://staging-mb.oakclub.com"
#define DOMAIN_DATA @"http://data1.oakclub.com/"
#define DOMAIN_VIDEO @"http://staging-mb.oakclub.com/oakclub_upload/"
#define MAX_UPLOAD_PHOTO_SIZE 8192000 //~8MB
#define MAX_UPLOAD_VIDEO_SIZE 81920000 //~8MB
#define URL_PHOTO @"http://staging.oakclub.com/load_photo.php"
#endif
#if USE_STAGING_IOS
#define HOSTNAME @"staging.oakclub.com"
#define DOMAIN @"http://staging-ios.oakclub.com"
#define DOMAIN_DATA @"http://data1.oakclub.com/"
#define MAX_UPLOAD_PHOTO_SIZE 8192000 //~8MB
#define MAX_UPLOAD_VIDEO_SIZE 81920000 //~8MB
#define URL_PHOTO @"http://staging.oakclub.com/load_photo.php"
#endif
//============== application key =============
#define key_appLanguage @"appLanguage"
#define key_ChosenLanguage @"appChosenLanguage"
//============== application value =============
#define flagLanguage true

#define value_appLanguage_EN @"en" //English
#define value_appLanguage_VI @"vi" //Vietnamese
#define value_appLanguage_DE @"de" //Germany
#define value_appLanguage_ID @"id" //Indonesia
#define value_appLanguage_TH @"th" //Thai
#define value_appLanguage_RU @"ru" //Russian
#define value_appLanguage_ES @"es" //Spanish
#define value_appLanguage_FR @"fr" //French
#define value_appLanguage_TR @"tr" //Turkish
#define value_appLanguage_DA @"da" //Danish
#define value_appLanguage_NB @"nb" //Norwegian
#define value_appLanguage_SV @"sv" //Swedish
#define value_appLanguage_RO @"ro" //Romanian
#define value_appLanguage_PL @"pl" //Polish
#define value_appLanguage_BG @"bg" //Bulgarian
#define value_appLanguage_HU @"hu" //Hungarian
#define value_appLanguage_HR @"hr" //Croatian
#define value_appLanguage_EL @"el" //Greek
#define value_appLanguage_NL @"nl" //Neitherlands
#define value_appLanguage_AR @"ar" //Arabic
#define value_appLanguage_KO @"ko" //Korean

#define AppLanguageKeyList ([NSArray arrayWithObjects:\
    value_appLanguage_EN,\
    value_appLanguage_VI,\
    value_appLanguage_DE,\
    value_appLanguage_ID,\
    value_appLanguage_TH,\
    value_appLanguage_RU,\
    value_appLanguage_ES,\
    value_appLanguage_FR,\
    value_appLanguage_TR,\
    value_appLanguage_DA,\
    value_appLanguage_NB,\
    value_appLanguage_SV,\
    value_appLanguage_RO,\
    value_appLanguage_PL,\
    value_appLanguage_BG,\
    value_appLanguage_HU,\
    value_appLanguage_HR,\
    value_appLanguage_EL,\
    value_appLanguage_NL,\
    value_appLanguage_AR,\
    value_appLanguage_KO,\
    nil])

#define AppLanguageList ([NSDictionary dictionaryWithObjectsAndKeys:\
                                @"English", value_appLanguage_EN,\
                                @"Tiếng Việt", value_appLanguage_VI,\
                                @"Deutsch", value_appLanguage_DE,\
                                @"Bahasa Indonesia", value_appLanguage_ID,\
                                @"ภาษาไทย", value_appLanguage_TH,\
                                @"Russian", value_appLanguage_RU,\
                                @"Español", value_appLanguage_ES,\
                                @"Français", value_appLanguage_FR,\
                                @"Türkce", value_appLanguage_TR,\
                                @"Dansk", value_appLanguage_DA,\
                                @"Norwegian", value_appLanguage_NB,\
                                @"Swedish", value_appLanguage_SV,\
                                @"Romanian", value_appLanguage_RO,\
                                @"Polish", value_appLanguage_PL,\
                                @"Bulgarian", value_appLanguage_BG,\
                                @"Hungarian", value_appLanguage_HU,\
                                @"Croatian", value_appLanguage_HR,\
                                @"Greek", value_appLanguage_EL,\
                                @"Nederlands", value_appLanguage_NL,\
                                                        @"العربية", value_appLanguage_AR,\
                                @"한국어", value_appLanguage_KO,\
                                nil])
//============== APIs =============
#define DOMAIN_AT @"@oakclub.com"
#define DOMAIN_AT_FMT @"%@@oakclub.com"
#define URL_getProfileInfo @"service/getProfileInfo"
#define URL_setProfileInfo @"service/setProfileInfo"
#define URL_me @"service/me"    //unused
#define URL_searchByLocation @"service/searchByLocation" //unused
#define URL_setBidFeature @"service/setBidFeature"//unused
#define URL_getAccountSetting @"service/getAccountSetting"
#define URL_getListWhoFavoritedMe @"service/getListWhoFavoritedMe" // unused
#define URL_getListWhoWantsToMeetMe @"service/getListWhoWantsToMeetMe" // unused
#define URL_getListWhoCheckedMeOut @"service/getListWhoCheckedMeOut" // unused
#define URL_getListMyFavorites @"service/getListMyFavorites" // unused
#define URL_getListFeature @"service/getListFeature" // unused
//#define URL_getListMutualMatch @"service/getListMutualAttractions"
#define URL_getListIWantToMeet @"service/getListIWantToMeet"    //unused
#define URL_getSnapShot @"service/getSnapshot"
#define URL_setLikedSnapshot @"service/setLikedSnapshot"//@"service/setFavorite"
#define URL_setListLikedSnapshot @"service/setListLikedSnapshot"
#define URL_getSnapshotSetting @"service/getSnapshotSetting"
#define URL_setSnapshotSetting @"service/setSnapshotSetting"
#define URL_chat_post @"service/chat/post"
#define URL_getHistoryMessages @"service/getHistoryMessages"
#define URL_deleteChat @"service/deleteChat"//@"service/deleteHangoutProfile" // delete history chatting messages.
#define URL_getDetailMutualFriends @"service/getDetailMutualFriends" // unused
#define URL_getMutualInfo @"service/getMutualInfo"// unused
#define URL_getListCountry @"service/getListCountry"    //unused
#define URL_getListPhotos @"service/getListPhotos"
#define URL_getListCityByCountry @"service/getListCityByCountry"
#define URL_getListLangRelWrkEth @"service/getDataLanguage"//@"service/getListLangRelWrkEth"
#define URL_getListMaybeIWantToMeet @"service/getListMaybe" // unused
#define URL_addToMyFavorite @"service/addToMyFavorite" //unused
#define URL_removeMyFavorite @"service/removeMyFavorite" //unsed
#define URL_unBlockHangoutProfile @"service/unBlockHangoutProfile" //unused
#define URL_blockHangoutProfile @"service/blockHangoutProfile"
#define URL_setIWantToMeet @"service/setIWantToMeet" // unused
#define URL_getListBlocking @"service/getListBlocking" //unused
#define URL_getListChat @"service/getListChat"
#define URL_getListWhoLikeMe @"service/getListWhoLikeMe"
#define URL_getListMutualMatch @"service/getListMutualMatch"    //unused
#define URL_setLocationUser @"service/setLocation"
#define URL_sendRegister @"service/sendRegister"
#define URL_uploadPhoto @"service/uploadPhoto"
#define URL_deletePhoto @"service/deletePhoto"
#define URL_deleteVideo @"service/deleteVideo"
#define URL_setReadMessages @"service/setReadMessages"
#define URL_setViewedMutualMatch @"service/setViewedMutualMatch"
#define URL_reportInvalid @"service/reportUser"
#define URL_uploadVideo @"service/uploadVideo"
#define URL_updateProfileFirstTime @"service/updateProfileFirstTime"
#define URL_ping @"service/pingActivities"
#define URL_getMatchmakerFriendList @"service/matchMarkerInit"
#define URL_sendMatchmaker @"service/makeMatching"
#define URL_reportIOSProblemToOakClub @"service/reportIOSProblemToOakClub"
#define URL_verifyReceipt @"service/verifyAppleReceipt"
#define URL_verifyUser @"service/verifyUser"
#define URL_updateIOSLanguage @"service/updateLanguage"
//================ service API keys ================
//root
#define key_status @"status"
#define key_errorStatus @"error_status"
#define key_errorCode @"error_code"
#define key_data @"data"
//profile
#define key_msg @"msg"
#define key_aboutMe @"about_me"
#define key_birthday @"birthday_date"
#define key_avatar @"avatar"
#define key_video @"video_link"
#define key_name @"name"
#define key_profileID @"profile_id"
#define key_profileStatus @"profile_status"
#define key_gender @"gender"
#define key_interested @"interested"
#define key_language @"language"
#define key_points @"points"
#define key_facebookID @"fb_id"
#define key_online @"online"
#define key_relationship @"relationship_status"
#define key_snapshotID @"snapshot_id"
#define key_ethnicity @"ethnicity"
#define key_work @"work"
#define key_school @"school"
#define key_email @"email"
#define key_weight @"weight"
#define key_height @"height"
#define key_meet_type @"meet_type"
#define key_popularity @"popularity"
#define key_interestedStatus @"interested_status"
#define key_countPhotos @"count_photos"
#define key_passwordXMPP @"xmpp_password"
#define key_usernameXMPP @"xmpp_username"
//location of profile
#define key_location @"location"
//#define key_locationID @"id"
#define key_isLike @"is_like"
#define key_likeTime @"like_time"
#define key_isVip @"is_vip"
#define key_isForceVerify @"force_verify"
#define key_isVerified @"is_verified"
#define key_statusTime @"time"
#define key_matchTime @"match_time"
#define key_lastMessage @"last_message"
#define key_lastMessageTime @"last_message_time"
#define key_locationName @"name"
#define key_locationCountry @"country"
#define key_locationCountryCode @"country_code"
#define key_locationCoordinates @"coordinates"
#define key_coordinatesLatitude @"latitude"
#define key_coordinatesLongitude @"longitude"
#define key_purpose_of_search @"purpose_of_search"
#define key_gender_of_search @"gender_of_search"
#define key_age_from @"age_from"
#define key_age_to @"age_to"
#define key_is_interests @"is_interests"
#define key_is_likes @"is_likes"
#define key_is_work @"is_work"
#define key_is_school @"is_school"
#define key_show_fof @"show_fof"
#define key_status_interested_in @"status_interested_in"
#define key_new_people @"new_people"
#define key_friends @"friends"
#define key_status_fof @"status_fof"
#define key_range @"range"
#define key_new_people_status @"status_interested_in.new_people"
#define key_FOF_status @"status_interested_in.fof"
#define key_locationID @"id"
#define key_includeFBFriend @"include_friend"
#define key_BlockList @"block_list"
#define key_PriorityList @"priority_list"
#define key_StrProfileID @"str_profile_id"
#define key_MutualFriends @"mutual_friends"
#define key_MutualLikes @"mutualLikes"
#define key_ShareInterests @"share_interests"
#define key_URL @"URL"
// list chat of profile
#define key_rosters @"rosters"
#define key_match @"matches"

#define key_platform @"platform"
#define key_OSVersion @"os_version"
#define key_DeviceName @"device_name"
#define key_DeviceToken @"device_token"
#define key_appVersion @"app_version"

#define key_reportContent @"content"
#define key_index @"index"

#define key_snapshotQueue @"snapshotQueueByProfileID"

#define key_receipt @"receipt"

#define DATE_FORMAT @"MM/dd/yyyy"
#define DATETIME_FORMAT @"MM/dd/yyyy HH:mm:ss"
//================ service API values ================
#define value_online @"Online"
#define value_offline @"Offline"
//purpose_of_search
#define value_Date @"date"
#define value_MakeFriend @"make_friend"
#define value_Chat @"chat"
//gender_of_search
#define value_Male @"male"
#define value_Female @"female"
#define value_All @"all"
//
#define value_TRUE @"true"
#define value_FALSE @"false"

//================ Notification keys =============
#define Notification_ApplicationDidBecomeActive @"ApplicationDidBecomeActive"
#define Notification_ChatFriendChanged_Format @"ChatFriendChanged:%@"

//================ Hangout View ==================
#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 75
#define THUMB_V_PADDING 2
#define THUMB_H_PADDING 2
#define CREDIT_LABEL_HEIGHT 20
#define START_X 77

#define AUTOSCROLL_THRESHOLD 30
#define NUMBER_COLUMN_HANGOUT 3
// ============= NearNow View===================
#define NearByCellWidth 104
#define NearByCellHeight 104
#define NearByPaddingTop 3.0
#define NearByPaddingLeft 3.0
#define NearByMargin 2.0
//================ MyLink/Visitors View ==================
#define NUMBER_OF_COLUMN 4 

//================ SnapShot ==================
#define key_first_name @"first_name"
#define key_last_name @"last_name"
#define key_age @"age"
#define key_avatar @"avatar"
#define key_photos @"photos"
#define key_photoID @"id"
#define key_photoLink @"tweet_image_link"
#define key_isProfilePicture @"is_profile_picture"
#define key_distance @"distance"
#define key_active @"active"
#define key_liked @"like"
#define key_viewed @"viewed"
#define MAX_FREE_SNAPSHOT 100

//============= Popularity =================
#define POPULARITY_VERY_LOW_TEXT  @"Very Low";
#define POPULARITY_LOW_TEXT  @"Low";
#define POPULARITY_AVERAGE_TEXT @"Average";
#define POPULARITY_HIGHT_TEXT @"High";
#define POPULARITY_VERY_HIGHT_TEXT @"Very High";

//=================Interested status==================
#define interestedStatusNO 3
#define interestedStatusYES 1
#define interestedStatusMAYBE 2

//=================Relationship status==================
#define RELATIOSHIP_SINGLE @"Single"
#define RELATIOSHIP_COMPLICATED @"Complicated"
#define RELATIOSHIP_MARRIED @"Married"
#define RELATIOSHIP_INRELATIONSHIP @"In RelationShip"
#define RELATIOSHIP_ENGAGED @"Engaged"
#define RELATIOSHIP_OPENRELATIONSHIP @"Open Relationship"
#define RELATIOSHIP_WIDOWED @"Widowed"
#define RELATIOSHIP_SEPARATED @"Separated"
#define RELATIOSHIP_DIVORCED @"Divorced"
// =================Type List=============================
#define LISTTYPE_RELATIONSHIP 0
#define LISTTYPE_LOCATION 1
#define LISTTYPE_CITY 2
#define LISTTYPE_COUNTRY 3
#define LISTTYPE_LANGUAGE 4
#define LISTTYPE_WORK 5
#define LISTTYPE_ETHNICITY 6
#define LISTTYPE_GENDER 7
#define LISTTYPE_HERETO 8
#define LISTTYPE_WANTTOSEE 9
#define LISTTYPE_WITHWHO 10
#define LISTTYPE_EMAILSETTING 11
#define LISTTYPE_INTERESTED 12 

#define key_WorkCate @"work_cate"



#define RelationshipList ([NSArray arrayWithObjects:RELATIOSHIP_SINGLE,RELATIOSHIP_COMPLICATED,RELATIOSHIP_MARRIED,RELATIOSHIP_INRELATIONSHIP,RELATIOSHIP_ENGAGED,RELATIOSHIP_OPENRELATIONSHIP,RELATIOSHIP_WIDOWED,RELATIOSHIP_SEPARATED,RELATIOSHIP_DIVORCED, nil])

#define LocationList  ([NSArray arrayWithObjects:@"Country", @"City", nil])

#define GenderList ([[NSArray alloc]initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"Female",@"text",@"0",@"ID", nil],[[NSDictionary alloc] initWithObjectsAndKeys:@"Male",@"text",@"1",@"ID", nil], nil])
#define GenderList_vi ([[NSArray alloc]initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"Nữ",@"text",@"0",@"ID", nil],[[NSDictionary alloc] initWithObjectsAndKeys:@"Nam",@"text",@"1",@"ID", nil], nil])
#define WithWhoOptionList  ([NSArray arrayWithObjects:value_Male, value_Female,@"Both", nil])

#define HereToOptionList  ([[NSArray alloc]initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"Date",@"text",value_Date,@"key", nil],[[NSDictionary alloc] initWithObjectsAndKeys:@"Make New Friends",@"text",value_MakeFriend,@"key", nil],[[NSDictionary alloc] initWithObjectsAndKeys:@"Chat",@"text",value_Chat,@"key", nil], nil])

#define value_Frequent @"Frequent"
#define value_Regular @"Regular"
#define value_Rare @"Rare"
#define value_Never @"Never"
#define EmailSettingOptionList  ([NSArray arrayWithObjects:value_Frequent,value_Regular,value_Rare, value_Never, nil])

#define WantToSeeOptionList  ([NSArray arrayWithObjects:@"New People", @"Friends",@"Friends of Friends", nil])

#define ProfileItems  ([NSArray arrayWithObjects:@"Name", @"Birthdate",@"Interested In", @"Gender",@"Relationship",@"Location",@"Height",@"Weight",@"Ethnicity",@"School",@"Language",@"Work",@"About me",@"Popularity",  nil])
#ifdef ENABLE_LOCATION_MANUALLY
#define MyProfileItemList  ([NSArray arrayWithObjects:@"Name", @"Birthdate",@"Email",@"Gender", @"Relationship",@"Height",@"Weight", @"Interested In",@"Update location automatically", @"Location",@"Ethnicity",@"School",@"Language",@"Work",@"About me", nil])
#else
#define MyProfileItemList  ([NSArray arrayWithObjects:@"Name", @"Birthdate",@"Email",@"Gender", @"Relationship",@"Height",@"Weight", @"Interested In", @"Location",@"Ethnicity",@"School",@"Language",@"Work",@"About me", nil])
#endif
#define UpdateProfileItemList  ([NSArray arrayWithObjects:@"Name", @"Birthdate",@"Email",@"Gender", @"Interested In", nil])
#define SnapshotSettingItemList  ([NSArray arrayWithObjects:@"I'm here to", @"I want to see",@"With who", @"Age around",@"Nearby GPS",@"Where",@"Range", nil])
//==============================
#define MAXLENGTH_NAME 20
#define MAXLENGTH_ABOUT 256

#define MIN_WEIGHT 30 //kg
#define MAX_WEIGHT 200 //kg

#define MIN_HEIGHT 100 //cm
#define MAX_HEIGHT 300 //cm

#define MIN_AGE 17
#define MAX_AGE 80



#define COLOR_BLUE_CELLTEXT [UIColor colorWithRed:(56/255.0) green:(84/255.0) blue:(135/255.0) alpha:1]
#define COLOR_BLUE_CELLBG [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1]
#define CGCOLOR_BLUE_CELLBG [UIColor colorWithRed:(190/255.0) green:(237/255.0) blue:(248/255.0) alpha:1].CGColor
#define COLOR_PURPLE [UIColor colorWithRed:(121/255.0) green:(1/255.0) blue:(88/255.0) alpha:1]
#define CGCOLOR_PURPLE ([UIColor colorWithRed:(121/255.0) green:(1/255.0) blue:(88/255.0) alpha:1].CGColor)

#define key_isUseGPS @"useGPS"
#define key_isFirstSnapshot @"isFirstSnapshot"
#define key_hasFirstSnapshot @"hasFirstSnapshot"
//=============== Advanced setting=============
#define FriendList  ([NSArray arrayWithObjects:@"Tran Van Quy", @"Vanancy Luu",@"Van Khanh", @"Thu Ha",@"RuaCon ChayCham",@"Phuong Lovely Nguyen",@"Mai Xuan Tham", nil])

#define FindPeopleItemList  ([NSArray arrayWithObjects:@"Interests", @"Likes",@"Work network", @"School network", nil])
#define EmailSettingItemList  ([NSArray arrayWithObjects:@"Preferred", @"Notifications", nil])

// =============== registers setting ================
#define ProfileConfirmItems  ([NSArray arrayWithObjects:@"Email", @"Gender",@"Interested In",@"Relationship status",@"Birthdate",@"Location",@"Ethnicity",@"About me",nil])



//=============== FUNCTIONS ================
//====== Fonts =====
#define FONT_NOKIA(s) [UIFont fontWithName:@"UTM Nokia Standard" size:s]
#define FONT_NOKIA_BOLD [UIFont fontWithName:@"UTM Nokia Standard Bold" size:17.0]
//#define FONT_NOKIA_BOLD(s) [UIFont fontWithName:@"UTM Nokia Standard Bold" size:s]

#define FONT_HELVETICANEUE_LIGHT(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]

//====== Strings =====
#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

//=======detect screen size============
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#endif
typedef enum {
    NAME,
    BIRTHDATE,
    EMAIL,
    GENDER,
    RELATIONSHIP,
    HEIGHT,
    WEIGHT,
    INTERESTED_IN,
#ifdef ENABLE_LOCATION_MANUALLY
    AUTO_LOCATION,
#endif
    LOCATION,
    ETHNICITY,
    SCHOOL,
    LANGUAGE,
    WORK,
    ABOUT_ME
} EditItems;

typedef enum {
    verylow,
    low,
    average,
    high,
    veryhigh
} Popularity;

typedef enum {
    None,
    single,
    complicated,
    married,
    inRelationship,
    engaged,
    openRelationship,
    widowed,
    separated,
    divorced
} RelationEnum;

typedef enum {
    HERETO,
    WANTTOSEE,
    WITHWHO,
    AGEAROUND,
    NEARBY,
    WHERE,
    RANGE
} SnapshotEditItems;

typedef enum{
    FEMALE,
    MALE
}GenderEnum;

typedef enum {
    LanguageGroup               = 0,
    GenderSearchGroup           = 1,
#ifndef DISABLE_HERETO_SHOWME
    HereToGroup                 = 2,
    ShowMeGroup                 = 3,
    AgeGroup                    = 4,
    DistanceGroup               = 5,
    MoreGroup                   = 6,
    NumOfSettingGroup           = 7,
#else
    AgeGroup                    = 2,
    DistanceGroup               = 3,
    MoreGroup                   = 4,
    NumOfSettingGroup           = 5,
#endif
} SettingGroup;

typedef enum{
    MatchUnViewed,
    MatchViewed,
    ChatUnviewed,
    ChatViewed,
}ListChatStatus;