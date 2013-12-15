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
    Profile *profile;
    UITapGestureRecognizer *dismissKeyboardTap;
}
@property (strong, nonatomic) IBOutlet UIView *explainReportView;
@property (weak, nonatomic) IBOutlet UITextView *reportDescTextView;
@property (strong, nonatomic) IBOutlet UIView *chooseReportView;
@property (strong, nonatomic) IBOutlet UIViewController *explainReportVC;
@property (strong, nonatomic) IBOutlet UIViewController *makeSureReportVC;
@property (strong, nonatomic) IBOutlet UIViewController *makeSureBlockVC;
@property (weak, nonatomic) IBOutlet UILabel *lbMakeSureReport;
@end

@implementation VCReportPopup
{
    NSString *reportContent;
}
@synthesize lbMakeSureReport;
-(id)initWithProfileID:(Profile *)_profile
{
    self = [super init];
    if (self) {
        // Custom initialization
        profile = _profile;
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
    lbMakeSureReport.text = [NSString stringWithFormat:[@"are you sure you want to report %@ for making you uncomfortable?" localize], profile.firstName ];

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
    //[self.navigationController pushViewController:self.makeSureBlockVC animated:YES];
    [self sendBlockReport];
    [self backToChat];
}

- (IBAction)onTouchSendReport:(id)sender
{
    reportContent = [sender title];
    [self makeSureSendReport];
}

- (IBAction)onTouchExplainReport:(id)sender
{
    [self.navigationController pushViewController:self.explainReportVC animated:YES];
    [self.explainReportVC.view localizeAllViews];
    [self.reportDescTextView becomeFirstResponder];
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
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
    reportContent = self.reportDescTextView.text;
    [self makeSureSendReport];
}

- (IBAction)touchCancelExplainReport:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)makeSureSendReport
{
    [self.navigationController pushViewController:self.makeSureReportVC animated:YES];
    [self.makeSureReportVC.view localizeAllViews];
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
}
- (IBAction)onTouchSureReport:(id)sender {
    if (reportContent)
    {
        [self sendReportWithContent:reportContent];
        
        reportContent = nil;
    }
    
    [self backToChat];
}
- (IBAction)onTouchSureBlock:(id)sender {
    [self sendBlockReport];
    [self backToChat];
}

-(void)sendReportWithContent:(NSString *)content
{
    AFHTTPClient *client= [[AFHTTPClient alloc] initWithOakClubAPI:DOMAIN];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:profile.s_ID, key_profileID, content, key_reportContent, nil];
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
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:profile.s_ID,key_profileID, nil];
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

@implementation VCReportMore

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view localizeAllViews];
    
    self.navigationItem.hidesBackButton = YES;
}

@end