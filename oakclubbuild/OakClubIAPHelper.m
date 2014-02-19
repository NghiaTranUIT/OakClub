//
//  OakClub
//
//  Created by Salm on 12/25/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "OakClubIAPHelper.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"

@implementation OakClubIAPHelper

+ (OakClubIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static OakClubIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.oakclub.testing.vip.free.1monthsubcription",
                                      @"com.oakclub.testing.vip.free.6monthsubcription",
                                      @"com.oakclub.testing.vip.free.1yearsubcription",
                                      nil];
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [super provideContentForProductIdentifier:productIdentifier];
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    NSString* receiptString = [self createEncodedString:transaction.transactionReceipt];
//    NSLog(@"receiptString:%@", receiptString);
    
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:receiptString, key_receipt, nil];
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_verifyReceipt parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
//         NSLog(@"dict: %@", dict);
         BOOL error = [[dict objectForKey:key_errorCode] boolValue];
         if (!error)
         {
             [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
         }
         else
         {
             UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:[@"Error" localize]
                                       message:[@"Purchase Error" localize]
                                       delegate:nil
                                       cancelButtonTitle:[@"OK" localize]
                                       otherButtonTitles:nil];
             [alertView show];
         }
         
         [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
         
     }failure:^(AFHTTPRequestOperation *op, NSError *err)
     {
         UIAlertView *alertView = [[UIAlertView alloc]
                                   initWithTitle:[@"Error" localize]
                                   message:[@"Purchase Error" localize]
                                   delegate:nil
                                   cancelButtonTitle:[@"OK" localize]
                                   otherButtonTitles:nil];
         [alertView show];
         
         [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
         
         NSLog(@"Report error: %@", err);
     }];
    
    [operation start];

}

- (NSString*) createEncodedString:(NSData*)data
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    const int size = ((data.length + 2)/3)*4;
    uint8_t output[size];
    
    const uint8_t* input = (const uint8_t*)[data bytes];
    for (int i = 0; i < data.length; i += 3)
    {
        int value = 0;
        for (int j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < data.length)
                value |= (0xFF & input[j]);
        }
        
        const int index = (i / 3) * 4;
        output[index + 0] =  table[(value >> 18) & 0x3F];
        output[index + 1] =  table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < data.length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < data.length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return  [[NSString alloc] initWithBytes:output length:size encoding:NSASCIIStringEncoding];
}

@end
