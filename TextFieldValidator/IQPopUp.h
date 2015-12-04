//
//  IQPopUp.h
//  TextFieldValidationDemo
//
//  Created by Yevgen Haritonenko on 12/3/15.
//  Copyright © 2015 Dhawal.Dawar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQPopUp : UIView
@property (nonatomic,assign) CGRect showOnRect;
@property (nonatomic,assign) int popWidth;
@property (nonatomic,assign) CGRect fieldFrame;
@property (nonatomic,copy) NSString *strMsg;
@property (nonatomic,strong) UIColor *popUpColor;
@property (nonatomic,strong) UIColor *fontColor;
@property (nonatomic,assign) NSUInteger fontSize;
@property (nonatomic,strong) NSString * fontName;
@property (nonatomic,assign) NSUInteger paddingInErrorPopUp;
@property (nonatomic,strong) NSString * msgValidateLength;
@end