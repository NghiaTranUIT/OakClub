    //
//  SCLoginViewController.m
//  OakClub
//
//  Created by VanLuu on 3/27/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "SCLoginViewController.h"
#import "AppDelegate.h"
#import "CycleScrollView.h"
#import "UAModelPanelEx.h"
#import "UIView+Localize.h"
#import "VCPrivacy.h"
#import "TutorialViewController.h"

@interface SCLoginViewController (){
    AppDelegate* appDelegate;
    NSDictionary *appLanguages;
    NSArray *descText;
}
@property (weak, nonatomic) IBOutlet UIView *pickingView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
- (IBAction)performLogin:(id)sender;
@property (weak, nonatomic) UITableView *tBView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)onTouchDown:(id)sender;

@end



@implementation SCLoginViewController
@synthesize spinner,btnLogin,pageControl, pickerView, pickingView, btnInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    NSString* language = [[NSUserDefaults standardUserDefaults] objectForKey:key_language];
//    NSString* path= [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
//    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (id) [UIApplication sharedApplication].delegate;
        appLanguages = AppLanguageList;
    }

    return self;
}

//-(void)viewDidLayoutSubviews{
//    [self.view setFrame:CGRectMake(0, 0, 320, 480)];
//    CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
//    self.view.center = CGPointMake(screenBounds.size.width/2 + screenBounds.origin.x,screenBounds.size.height/2 + screenBounds.origin.y);
//    
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showMenuLanguage];
    
    descText = [[NSArray alloc] initWithObjects:
                @"Anonymouly \"like\" or \"pass\" on people OakClub suggests",
                @"Chat with your matches inside the app",
                @"if someone you've liked happen to like you as well ...",
                nil];
    
    // Do any additional setup after loading the view from its nib.
    NSArray* pageImages = [NSArray arrayWithObjects:
                  [UIImage imageNamed:@"intropage_snap"],
                  [UIImage imageNamed:@"intropage_chat"],
                  [UIImage imageNamed:@"intropage_match"],
                  nil];
    CGRect mainFrame = [[UIScreen mainScreen]applicationFrame];
    CycleScrollView *cycle;
    if(IS_OS_7_OR_LATER){
        cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 5, mainFrame.size.width, mainFrame.size.height)
                                        cycleDirection:CycleDirectionLandscape
                                              pictures:pageImages];
    }
    else{
        cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, mainFrame.size.width, mainFrame.size.height)
                                        cycleDirection:CycleDirectionLandscape
                                              pictures:pageImages];
        
    }
    
    cycle.delegate = self;
    [cycle setBackgroundColor:[UIColor whiteColor]];
    [cycle refreshScrollView];
//    cycle.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
//                                                          UIViewAutoresizingFlexibleLeftMargin |
//                                                          UIViewAutoresizingFlexibleRightMargin);
//    [cycle autoresizingMask]
    [self.view addSubview:cycle];
    [self.view sendSubviewToBack:cycle];
    
    //init for pageControl
    pageControl.numberOfPages = pageImages.count;
    pageControl.currentPage = 0;
    
    [self.view localizeAllViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view localizeAllViews];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startSpinner{
    [self.spinner startAnimating];
    [btnLogin setEnabled:NO];
    self.btnInfo.enabled = NO;
}
- (void)stopSpinner{
    [self.spinner stopAnimating];
    [btnLogin setEnabled:YES];
    self.btnInfo.enabled = YES;
}

- (IBAction)performLogin:(id)sender
{
    if(btnLogin.selected)
        return;
    
    if (appDelegate.isFacebookActivated || DISABLE_POCLICY)
    {
        [self startSpinner];
        [self tryLogin];
    }
    else
    {
        UAModalPanel *popup = [[VCPrivacy alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andLoginPage:self];
        [self.view addSubview:popup];
        
        [popup showFromPoint:[self.view center]];
    }
}

- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self stopSpinner];
}

- (void)viewDidUnload {
    [self setBtnLogin:nil];
    [super viewDidUnload];
}

#pragma mark delegate for CyclescrollView
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index{
    pageControl.currentPage = index-1;
}

- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView customizeImageView:(TapDetectingImageView *)imageView atIndex:(int)index
{
    NSLog(@"Customize cycle view at index: %d", index);
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:FONT_HELVETICANEUE_LIGHT(16)];//[UIFont systemFontOfSize:16]];
    [lbl setTextColor:[UIColor darkTextColor]];
    [lbl setShadowColor:[UIColor lightTextColor]];
    [lbl setLineBreakMode:NSLineBreakByWordWrapping];
    lbl.numberOfLines = 2;
    lbl.textAlignment = NSTextAlignmentCenter;
    [lbl setFrame:CGRectMake(0, 5, 300, 50)];
    if (IS_HEIGHT_GTE_568)
    {
        [lbl setFrame:CGRectMake(0, 50, 300, 50)];
    }
    [lbl setText:[descText objectAtIndex:index]];
    [lbl localizeAllViews];
    [lbl setFrame:CGRectMake((imageView.frame.size.width - lbl.frame.size.width) / 2, lbl.frame.origin.y, lbl.frame.size.width, lbl.frame.size.height)];
    
    [imageView addSubview:lbl];
}

#pragma mark Facebook Login
- (void)tryLogin
{
    [appDelegate tryLoginWithSuccess:^(int status)
     {
         [self stopSpinner];
        if (status == 0)
        {
            [appDelegate showConfirm];
        }
        else if (status == 2 || status == -1)
        {
            [appDelegate gotoVCAtCompleteLogin];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:key_ChosenLanguage];
     } failure:^{
        [self stopSpinner];
        NSLog(@"LOGIN FAIL.....");
         
         //Msg popup can't login
    }];
}

- (IBAction)showInfoPanel:(id)sender
{
    float padding = 0;
    if (IS_OS_7_OR_LATER)
    {
        padding = 10;
    }
    UAModalPanel *popup = [[UAModelPanelEx alloc] initWithFrame:CGRectMake(0, padding, self.view.frame.size.width, self.view.frame.size.height - padding) andLoginPage:self];
    [self.view addSubview:popup];
    
    [popup showFromPoint:[self.view center]];
}

#pragma mark Language
-(void) showMenuLanguage{
    BOOL isSetLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:key_ChosenLanguage] boolValue];
    NSString* language = [[NSUserDefaults standardUserDefaults] objectForKey:key_appLanguage];
    if(language != nil)
    {
        [appDelegate updateLanguageBundle];
        [self.view localizeAllViews];
        //[appDelegate loadAllViewControllers];
    }
    
    if (!isSetLanguage)
    {
        if(flagLanguage)
        {
            [pickingView setFrame: CGRectMake(0, 0, pickingView.frame.size.width, pickingView.frame.size.height)];
            pickingView.tag = 7;
            [self.view addSubview:pickingView];
            [pickerView setHidden: NO];
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:0 animated:YES];
             [self disableAll: YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[@"Choose your language" localize]
                                  message:@""
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Tiếng Việt", @"English", @"Deutsch", @"Indonesia", nil];
            [alert show];
        }
    }
    else
    {
        if (appDelegate.isFacebookActivated)
        {
            [self startSpinner];
            [self tryLogin];
        }
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pkView numberOfRowsInComponent:(NSInteger)component
{
    return [appLanguages count];
}

- (NSString *)pickerView:(UIPickerView *)pkView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *langID = [[appLanguages allKeys] objectAtIndex:row];
    return [appLanguages valueForKey:langID];
    
}
- (void)pickerView:(UIPickerView *)pkView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *langID = [[appLanguages allKeys] objectAtIndex:row];
    NSLog(@"abc: %@", langID);
    [[NSUserDefaults standardUserDefaults] setObject: langID forKey:key_appLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [appDelegate updateLanguageBundle];
    NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
    NSLog(@"%@ %@",langID, str);
    //[self.view localizeAllViews];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Tiếng Việt"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_VI forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString* selectedLanguage =[[NSUserDefaults standardUserDefaults] stringForKey:key_appLanguage];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"Vietnamese %@",str);
    }
    else if([title isEqualToString:@"English"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_EN forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"English %@",str);
    }
    else if([title isEqualToString:@"Deutsch"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_DE forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"German %@",str);
    }
    else if([title isEqualToString:@"Indonesia"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_ID forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"Indonesia %@",str);
    }
    else if([title isEqualToString:@"ภาษาไทย"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_TH forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"ภาษาไทย %@",str);
    }
    else if([title isEqualToString:@"Türk"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:value_appLanguage_TR forKey:key_appLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate updateLanguageBundle];
        NSString* str=[appDelegate.languageBundle localizedStringForKey:@"was selected" value:@"" table:nil];
        NSLog(@"Türk %@",str);
    }
    
    [self.view localizeAllViews];
    //[appDelegate loadAllViewControllers];
}

-(void) disableAll: (BOOL) value
{
    btnLogin.userInteractionEnabled = !value;
    btnInfo.userInteractionEnabled = !value;
    pageControl.userInteractionEnabled = !value;
}

#pragma mark Load TEXT for all control
-(void) localizeAllText{
    for(UIView* view in [self.view subviews]){
        [view localizeText];
    }
}
- (IBAction)onTouchDown:(id)sender
{
    [self.view localizeAllViews];
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == 7) {
            [subview removeFromSuperview];
        }
    }
    [self disableAll: NO];
}
@end