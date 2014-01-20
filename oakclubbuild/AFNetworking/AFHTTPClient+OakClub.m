//
//  AFHTTPClient+OakClub.m
//  oakclubbuild
//
//  Created by VanLuu on 4/16/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "AFHTTPClient+OakClub.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "Define.h"
@implementation AFHTTPClient (OakClub)
-(AFHTTPClient *) initWithOakClubAPI: (NSString *) api{
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    if(![appDelegate checkInternetConnection]) {
        return nil;
    }
    else{
        NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;
        
#if DAN_CHEAT
        accessToken = DAN_ACCESSTOKEN;
#endif
        
        
        if(accessToken == nil)
            return nil;
        NSString *path = DOMAIN;
        int n= random();
        NSString * nonceBase64 = [NSString stringWithFormat:@"%x",n];
        nonceBase64 = [nonceBase64 substringWithRange:NSMakeRange(0, [nonceBase64 length])];
        
        //create Timezone when sent request
        NSDate *currentDate = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS.SSS'Z'"];
        NSString *localDateString = [dateFormatter stringFromDate:currentDate];
        
        //create header string for request
        NSString *s = @"UsernameToken Username=\"";
#if DAN_CHEAT
        s = [s stringByAppendingString:DAN_FACEBOOKID];
#else
        s = [s stringByAppendingString:appDelegate.myFBProfile.id ];
#endif
        s = [s stringByAppendingString:@"\", AccessToken=\""];
        s = [s stringByAppendingString:accessToken];
        s = [s stringByAppendingString:@"\", Nonce=\""];
        s = [s stringByAppendingString:nonceBase64];
        s = [s stringByAppendingString:@"\", Created=\"" ];
        s = [s stringByAppendingString:localDateString];
        s = [s stringByAppendingString:@"\""];
        
        //NSDate *nowDate = [NSDate date];
        //NSNumber *nowLong = [NSNumber numberWithUnsignedLongLong: [nowDate timeIntervalSince1970]];
        //NSString *timeString = [NSString stringWithFormat:@"%llu",[nowLong unsignedLongLongValue]];
        //    api = [api stringByAppendingString:[NSString stringWithFormat:@"?d=%@",timeString]];
        
        path = [path stringByAppendingString:api];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:api]];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        client.parameterEncoding = AFJSONParameterEncoding;
        [client setDefaultHeader:@"Accept" value:@"application/json"];
        [client setDefaultHeader:@"Accept" value:@"text/html"];
        [client setDefaultHeader:@"X-WSSE" value:s];
        //show log
//        NSLog(@"header : %@",client);
        return client;
    }
}
@end
