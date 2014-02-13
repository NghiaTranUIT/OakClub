//
//  HistoryMessage.m
//  oakclubbuild
//
//  Created by Nguyen Vu Hai on 4/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "HistoryMessage.h"

#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient+OakClub.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "NSString+Base64.h"

#import "NSString+Utils.h"

@implementation HistoryMessage

@synthesize body, time, timeStr, from, to;

-(id)init {
    self = [super init];
    return self;
}

+(NSMutableArray*)parseJSONtoHistoryMessages:(NSData *)jsonData
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSError *e=nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    int status= (int)[dict valueForKey:@"status"];
    
    //if( [status isEqualToString:@"1"] || [status isEqualToString:@"true"])
    if(status)
    {
        NSMutableArray * data= [dict valueForKey:key_data];
        
        if(data != nil)
        {
            for (int i = 0; i < [data count]; i++)
            {
                NSMutableDictionary *objectData = [data objectAtIndex:i];
                
                HistoryMessage* item = [ [HistoryMessage alloc] init];
                
                item.body = [objectData valueForKey:@"body"];
                item.time = (long)[objectData valueForKey:@"time"];
                item.timeStr = [objectData valueForKey:@"time_string"];
                item.from = [objectData valueForKey:@"from"];
                item.to = [objectData valueForKey:@"to"];
                
                [array addObject:item];
            }
        }
        
    }
    
    return array;
}

+(NSOperation*) getHistoryMessages:(NSString*)hangout_id callback:(void(^)(NSMutableArray*))handler
{
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:hangout_id,key_profileID,
                                                                        @"0",key_index, nil];
    
    NSURLRequest *request = [client requestWithMethod:@"GET" path:URL_getHistoryMessages parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray* array = [HistoryMessage parseJSONtoHistoryMessages:JSON];
        
        [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             HistoryMessage *p1 = (HistoryMessage*)obj1;
             HistoryMessage *p2 = (HistoryMessage*)obj2;
             
             NSDate* date1 = [NSString getDateWithString:[p1 timeStr]];
             NSDate* date2 = [NSString getDateWithString:[p2 timeStr]];
             
             
             return [date1 compare:date2];
         }];
        
        if(handler != nil)
            handler(array);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get History Msg Error Code: %i - %@",[error code], [error localizedDescription]);
        handler(nil);
    }];
    
    return operation;
}

+(AFHTTPRequestOperation*)getHistoryMessagesSync:(NSString*) hangout_id callback:(void(^)(NSMutableArray*))handler
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:hangout_id,@"hangout_id",
                            @"3M",@"time", nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:URL_getHistoryMessages
                                                      parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableArray* array = [HistoryMessage parseJSONtoHistoryMessages:responseObject];
         
         [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
          {
              HistoryMessage *p1 = (HistoryMessage*)obj1;
              HistoryMessage *p2 = (HistoryMessage*)obj2;
              
              NSDate* date1 = [NSString getDateWithString:[p1 timeStr]];
              NSDate* date2 = [NSString getDateWithString:[p2 timeStr]];
              
              
              return [date1 compare:date2];
          }];
         
         if(handler != nil)
             handler(array);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Get History Message Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
    return operation;
}


+(void)postMessage:(NSString*)reciever_id messageContent:(NSString*)message
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    //NSDictionary *params = @{@"to":reciever_id, @"message":message};
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:reciever_id,@"to", message, @"message", nil];
    
    NSMutableURLRequest *jsonRequest = [httpClient requestWithMethod:@"POST"
                                                                path:URL_chat_post
                                                          parameters:params];
    
    NSLog(@"request {%@} {%@} {%@}", [jsonRequest HTTPMethod], [jsonRequest description], [NSString stringWithUTF8String:[[jsonRequest HTTPBody] bytes]]);
    NSLog(@"Chat post request %@", jsonRequest);
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:jsonRequest
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

                                                        NSMutableDictionary *dict= JSON;
                                                        
                                                        bool status= (bool)[dict valueForKey:@"status"];
                                                        if(status == true)
                                                        {
                                                            NSString *msg= [dict valueForKey:@"msg"];
                                                            NSLog(@"! Post message %@", msg);
                                                        }
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"%@", error);
                                                    }];
    
    [operation start];
}

+(void)deleteChatHistory:(NSString*)hangout_id
{
    AFHTTPClient *request = [[AFHTTPClient alloc]initWithOakClubAPI:DOMAIN];
    
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:hangout_id,key_profileID, nil];
    [request setParameterEncoding:AFFormURLParameterEncoding];
    [request postPath:URL_deleteChat parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Api: %@ execution Error Code: %i - %@", URL_deleteChat, [error code], [error localizedDescription]);
     }];

}

@end
