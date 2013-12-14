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
    UITapGestureRecognizer *dismissKeyboardTap;
}
@property (strong, nonatomic) IBOutlet UIView *explainReportView;
@property (weak, nonatomic) IBOutlet UITextView *reportDescTextView;
@property (strong, nonatomic) IBOutlet UIView *chooseReportView;
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
    
    dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardFromReportDescTextView:)];
    [self.explainReportView addGestureRecognizer:dismissKeyboardTap];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.view localizeAllViews];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTouchCancel:(id)sender
{
    [self backToChat];
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
    self.view = self.explainReportView;
    [self.reportDescTextView becomeFirstResponder];
}

-(void)dismissKeyboardFromReportDescTextView:(id)sender
{
    [self.reportDescTextView resignFirstResponder];
}

-(void)backToChat
{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchSendExplainReport:(id)sender {
    [self sendReportWithContent:self.reportDescTextView.text];
    [self backToChat];
}
- (IBAction)touchCancelExplainReport:(id)sender {
    self.view = self.chooseReportView;
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
