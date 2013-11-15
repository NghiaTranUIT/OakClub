//
//  VCReportPopup.m
//  OakClub
//
//  Created by VanLuu on 10/31/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "VCReportPopup.h"
#import "AppDelegate.h"
#import "UIView+Localize.h"

@interface VCReportPopup () <UIAlertViewDelegate>
{
    NSString *profileID;
}
@end

@implementation VCReportPopup

-(id)initWithProfileID:(NSString *)_profileID
{
    self = [super init];
    if (self) {
        // Custom initialization
        profileID = _profileID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view localizeAllViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTouchBlockThisUser:(id)sender
{
    [self sendBlockReport];
    [self backToChat];
}

- (IBAction)onTouchSendReport:(id)sender
{
    [self sendReportWithContent:[sender title]];
    [self backToChat];
}

- (IBAction)onTouchExplainReport:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report" message:@"" delegate:self cancelButtonTitle:@"Report" otherButtonTitles: nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
    [[alertView textFieldAtIndex:0] resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UITextField *reportTxtField = [alertView textFieldAtIndex:0];
    NSString *reportContent = reportTxtField.text;
    
    [self sendReportWithContent:reportContent];
    [self backToChat];
}

-(void)backToChat
{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)sendReportWithContent:(NSString *)content
{
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:profileID, key_profileID, content, key_reportContent, nil];
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_reportInvalid parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id JSON)
     {
         NSError *e;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         NSLog(@"Report result %@", dict); //Lets us know the result including failures
     }failure:^(AFHTTPRequestOperation *op, NSError *err)
     {
         NSLog(@"Report error: %@", err);
     }];
    
    [operation start];
}

-(void)sendBlockReport
{
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:profileID,key_profileID, nil];
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    NSMutableURLRequest *myRequest = [client requestWithMethod:@"POST" path:URL_blockHangoutProfile parameters:params];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:myRequest];
    [operation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *operation, id JSON)
     {
         NSError *e=nil;
         NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&e];
         int status= (int)[dict valueForKey:key_status];
         if(status)
             NSLog(@"URL_blockHangoutProfile Success!");
         else
             NSLog(@"URL_blockHangoutProfile Failed!");
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"URL_blockHangoutProfile Error Code: %i - %@",[error code], [error localizedDescription]);
     }];
    
    [operation start];
}
@end
