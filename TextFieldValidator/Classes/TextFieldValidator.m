//
//  TextFieldValidator.m
//  Textfield Error Handle
//
//  Created by Dhawal Dawar on 22/11/12.
//  Copyright (c) 2012 Dhawal Dawar. All rights reserved.
//

#import "TextFieldValidator.h"

#define IconImageName @"validation_error.png"
#define ColorPopUpBg [UIColor colorWithRed:0.702 green:0.000 blue:0.000 alpha:1.000]
#define MsgValidateLength @"This field cannot be blank"

@interface TextFieldValidatorSupport : NSObject <UITextFieldDelegate>
@property (nonatomic,weak) id<UITextFieldDelegate> delegate;
@property (nonatomic,assign) BOOL validateOnCharacterChanged;
@property (nonatomic,assign) BOOL validateOnResign;
@property (nonatomic,strong) IQPopUp *popUp;
@end

@implementation TextFieldValidatorSupport

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [self.delegate textFieldShouldBeginEditing:textField];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [self.delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [self.delegate textFieldShouldEndEditing:textField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [self.delegate textFieldDidEndEditing:textField];
    [self.popUp removeFromSuperview];
    if(self.validateOnResign)
        [(TextFieldValidator *)textField validate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [(TextFieldValidator *)textField dismissPopup];
    if(self.validateOnCharacterChanged)
        [(TextFieldValidator *)textField performSelector:@selector(validate) withObject:nil afterDelay:0.1];
    else
        [(TextFieldValidator *)textField setRightView:nil];
    if([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [self.delegate textFieldShouldClear:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
        return [self.delegate textFieldShouldReturn:textField];
    return YES;
}
@end

@interface TextFieldValidator()
@property (nonatomic,strong) NSString *strLengthValidationMsg;
@property (nonatomic,strong) TextFieldValidatorSupport *supportObj;
@property (nonatomic,strong) NSString *strMsg;
@property (nonatomic,strong) NSMutableArray *arrRegx;

-(void)tapOnError;

@end

@implementation TextFieldValidator

#pragma mark - Default Methods of UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];    
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

-(void)setDelegate:(id<UITextFieldDelegate>)deleg
{
    self.supportObj.delegate=deleg;
    super.delegate=self.supportObj;
}

-(void)setup
{
    self.arrRegx=[[NSMutableArray alloc] init];
    self.validateOnCharacterChanged=YES;

    self.isMandatory=YES;
    self.validateOnResign=YES;
    self.popUpColor=ColorPopUpBg;
    self.strLengthValidationMsg=[MsgValidateLength copy];
    
    self.supportObj= [[TextFieldValidatorSupport alloc] init];
    self.supportObj.validateOnCharacterChanged= self.validateOnCharacterChanged;
    self.supportObj.validateOnResign= self.validateOnResign;
    self.supportObj.validateOnCharacterChanged=YES;
    self.supportObj.validateOnResign = YES;
    
    NSNotificationCenter *notify=[NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(didHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Public methods

-(void)addRegx:(NSString *)strRegx withMsg:(NSString *)msg
{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:strRegx,@"regx",msg,@"msg", nil];
    [self.arrRegx addObject:dic];
}

-(void)updateLengthValidationMsg:(NSString *)msg
{
    self.strLengthValidationMsg=[msg copy];
}

-(void)addConfirmValidationTo:(TextFieldValidator *)txtConfirm withMsg:(NSString *)msg
{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:txtConfirm,@"confirm",msg,@"msg", nil];
    [self.arrRegx addObject:dic];
}

-(BOOL)validate
{
    if(self.isMandatory){
        if([self.text length]==0){
            [self showErrorIconForMsg:self.strLengthValidationMsg];
            return NO;
        }
    }
    for (int i=0; i<[self.arrRegx count]; i++) {
        NSDictionary *dic=[self.arrRegx objectAtIndex:i];
        if([dic objectForKey:@"confirm"]){
            TextFieldValidator *txtConfirm=[dic objectForKey:@"confirm"];
            if(![txtConfirm.text isEqualToString:self.text]){
                [self showErrorIconForMsg:[dic objectForKey:@"msg"]];
                return NO;
            }
        }else if(![[dic objectForKey:@"regx"] isEqualToString:@""] && [self.text length]!=0 && ![self validateString:self.text withRegex:[dic objectForKey:@"regx"]]){
            [self showErrorIconForMsg:[dic objectForKey:@"msg"]];
            return NO;
        }
    }
    self.rightView=nil;
    return YES;
}

-(void)dismissPopup
{
    [self.popUp removeFromSuperview];
}

#pragma mark - Internal Methods

-(void)didHideKeyboard
{
    [self.popUp removeFromSuperview];
}

-(void)tapOnError
{
    [self showErrorWithMsg:self.strMsg];
}

- (BOOL)validateString:(NSString*)stringToSearch withRegex:(NSString*)regexString
{
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    return [regex evaluateWithObject:stringToSearch];
}

-(void)showErrorIconForMsg:(NSString *)msg
{
    UIButton *btnError=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnError addTarget:self action:@selector(tapOnError) forControlEvents:UIControlEventTouchUpInside];
    [btnError setBackgroundImage:[UIImage imageNamed:IconImageName] forState:UIControlStateNormal];
    self.rightView=btnError;
    self.rightViewMode=UITextFieldViewModeAlways;
    self.strMsg=[msg copy];
}

-(void)showErrorWithMsg:(NSString *)msg
{
    self.popUp = [[IQPopUp alloc] initWithFrame:CGRectZero];
    self.popUp.strMsg=msg;
    self.popUp.popUpColor=self.popUpColor;
    self.popUp.showOnRect=[self convertRect:self.rightView.frame toView:self.presentInView];
    self.popUp.fieldFrame=[self.superview convertRect:self.frame toView:self.presentInView];
    self.popUp.backgroundColor=[UIColor clearColor];
    [self.presentInView addSubview:self.popUp];
    
    self.popUp.translatesAutoresizingMaskIntoConstraints=NO;
    
    [self.popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:@{@"popUp" : self.popUp}]];
    [self.popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:@{@"popUp" : self.popUp}]];
    self.supportObj.popUp=self.popUp;
}

@end
