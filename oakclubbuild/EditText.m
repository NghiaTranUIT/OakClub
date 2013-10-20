//
//  EditText.m
//  OakClub
//
//  Created by VanLuu on 6/12/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import "EditText.h"
#import "AppDelegate.h"
@interface EditText (){
    AppDelegate *appDelegate;
}
@property UIButton* buttonBack;
//@property UIButton* buttonEditPressed;
@end

@implementation EditText
@synthesize texfieldEdit,textviewEdit, buttonBack, delegate, btnTextViewThemes, btnThemesTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}
-(void)initForEditting:(NSString*)stext andStyle:(int)style{
    text = stext;
    editStyle = style;
}
-(NSString*)getText{
    return text;
}
-(int)getStyle{
    return editStyle;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = @"Edit";
     [self addTopLeftButtonWithAction:@selector(enterEditing)];
    // Do any additional setup after loading the view from its nib.
    switch (editStyle) {
        case 2:
            textviewEdit.text= text;
            textviewEdit.hidden = NO;
            btnTextViewThemes.hidden = NO;
            texfieldEdit.hidden = YES;
            btnThemesTextField.hidden = YES;
            break;
        default:
            [texfieldEdit setText:text];
            texfieldEdit.hidden = NO;
            btnThemesTextField.hidden = NO;
            textviewEdit.hidden = YES;
            btnTextViewThemes.hidden = YES;
            break;
    }
    
    [texfieldEdit addTarget:self
                       action:@selector(textFieldFinished:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}
- (IBAction)textFieldFinished:(id)sender
{
    
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)viewWillAppear:(BOOL)animated{
//    [self addTopLeftButtonWithAction:@selector(enterEditing)];
//}
- (void)viewDidUnload {
    [self setTextviewEdit:nil];
    [self setTexfieldEdit:nil];
    [self setTexfieldEdit:nil];
    [self setBtnThemesTextField:nil];
    [self setBtnTextViewThemes:nil];
    [super viewDidUnload];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}
-(void)enterEditing
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(saveChangedEditting:)]) {
            [delegate saveChangedEditting:self];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }

    
}
-(void)addTopLeftButtonWithAction:(SEL)action
{
    buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(0, 0, 35, 30);
    [buttonBack addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"header_btn_back.png"] forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"header_btn_back_pressed.png"] forState:UIControlStateHighlighted];

    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
}
@end
