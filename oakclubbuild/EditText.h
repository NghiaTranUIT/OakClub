//
//  EditText.h
//  OakClub
//
//  Created by VanLuu on 6/12/13.
//  Copyright (c) 2013 VanLuu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditTextViewDelegate;
@interface EditText : UIViewController{
    NSString *text;
    int editStyle;
    id<EditTextViewDelegate>   _delegate;
}
@property(nonatomic,assign) id<EditTextViewDelegate>   delegate;
@property (strong, nonatomic) IBOutlet UITextField *texfieldEdit;
@property (strong, nonatomic) IBOutlet UITextView *textviewEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnThemesTextField;
@property (strong, nonatomic) IBOutlet UIButton *btnTextViewThemes;
-(void)initForEditting:(NSString*)stext andStyle:(int)style;
-(NSString*)getText;
-(int)getStyle;
@end

@protocol EditTextViewDelegate<NSObject>

@optional
- (void)saveChangedEditting:(EditText *)editObject;
@end