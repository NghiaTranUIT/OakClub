//
//  HistoryMessage.h
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 4/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

#import "AFHTTPRequestOperation.h"

@interface HistoryMessage : NSObject
{
    NSString* body;
    long time;
    NSString* timeStr;
    NSString* from;
    NSString* to;
}

@property (strong, nonatomic) NSString* body;
@property (assign, nonatomic) long time;
@property (strong, nonatomic) NSString* timeStr;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSString* to;

+(NSMutableArray*)parseJSONtoHistoryMessages:(NSData *)jsonData;
+(void)getHistoryMessages:(NSString*) hangout_id callback:(void(^)(NSMutableArray*))handler;
+(AFHTTPRequestOperation*)getHistoryMessagesSync:(NSString*) hangout_id callback:(void(^)(NSMutableArray*))handler;

+(void)postMessage:(NSString*)reciever_id messageContent:(NSString*)message;
+(void)deleteChatHistory:(NSString*)hangout_id;
@end
