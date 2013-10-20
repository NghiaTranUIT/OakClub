//
//  rootViewController.m
//  oakclubbuild
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "rootViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "AppDelegate.h"


@interface rootViewController ()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userToken;

@property (nonatomic, strong) NSMutableData *responseData;
- (IBAction)FletchURL:(id)sender;

@end

@implementation rootViewController

@synthesize responseData = _responseData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(logoutButtonWasPressed:)];
    NSLog(@"viewdidload");

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.responseData appendData:data]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    for(id key in res) {
        
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
    }
    
    // extract specific value...
    NSArray *results = [res objectForKey:@"results"];
    
    for (NSDictionary *result in results) {
        NSString *icon = [result objectForKey:@"icon"];
        NSLog(@"icon: %@", icon);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)logoutButtonWasPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}
- (void)viewDidUnload {
    [self setUserProfileImage:nil];
    [self setUserNameLabel:nil];
    [self setUserToken:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}
- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = user.id;
                 self.userToken.text = [FBSession activeSession].accessTokenData.accessToken;
             }
         }];
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

- (IBAction)FletchURL:(id)sender {
    
    
    NSURL *url = [NSURL URLWithString:@"http://v2.doolik.com/service/me"];
    
	// Create a request 
	// You don't normally need to retain a synchronous request, but we need to in this case because we'll need it later if we reload the table data
//	[self setRequest:[ASIHTTPRequest requestWithURL:url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    
    NSString *s = @"UsernameToken Username=\"";
       s = [s stringByAppendingString:self.userProfileImage.profileID];
        s = [s stringByAppendingString:@"\", AccessToken=\""];
        s = [s stringByAppendingString:self.userToken.text];
        s = [s stringByAppendingString:@"\", Nonce=\"zdnaxd\", Created=\"2013-03-27T10:57:35.978Z\""];
        NSLog(@"%@", s);
    	[request addRequestHeader:@"X-WSSE" value:s];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    request.useCookiePersistence = YES;
    [request setRequestCookies:[NSMutableArray arrayWithArray:cookies]];
    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"responseString : %@", responseString);
        

        
        // Use when fetching binary data
        NSData *responseData = [request responseData];
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"error : %@", error);
    }];
    [request startAsynchronous];

	// Start the request
//    [request setDelegate:self];
//	[request startAsynchronous];
     
    
    
    /*
    NSURL *url = [NSURL URLWithString:@"http://172.29.115.32:44447/test/test.php?p=hoangle"];
//        NSURL *url = [NSURL URLWithString:@"http://google.com"];

    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request addRequestHeader:@"p" value:@"HoangLE"];
    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"responseString : %@", responseString);
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"error : %@", error);
    }];
    [request startAsynchronous];
    */
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSLog(@"ResponseString:%@",responseString);

    NSData *responseData = [request responseData];
    
    //    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //    NSLog(@"ResponseString:%@",[_request]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

@end
