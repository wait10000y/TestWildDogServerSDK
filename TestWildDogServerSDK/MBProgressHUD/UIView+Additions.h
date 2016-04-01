//
//  UIView+Additions.h
//  chelady
//
//  Created by wsliang on 15/5/4.
//  Copyright (c) 2015年 xor-media. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

//#define HUDViewTagInSuperView 4026
#define alertViewTagInSuperView 4027
#define alertViewInputTagInSuperView 4028
typedef void(^AlertViewSelectBlock)(BOOL isOK);
typedef void(^AlertViewInputSelectBlock)(BOOL isOK,NSString* textStr, NSString *pwdStr);

@interface UIView (Additions)

+(id)loadNibView:(NSString*)theNibName;
//
//- (void)async:(void(^)(void))block;
//- (void)async_main:(void(^)(void))block;
//
//-(BOOL)isLastIOS7;
//-(BOOL)isLastIOS6;
//-(float)getIOSVersion;

-(UIViewAutoresizing)getViewAllResizingMask;

// --------- hud ---------

-(void)showHUDLoading;
-(void)showHUDLoadingTips:(NSString*)theTips;
-(void)showHUDLoadingTips:(NSString*)theTips details:(NSString*)theDetail;
-(MBProgressHUD *)showHUDProgressTips:(NSString *)theTips;

-(void)hideHUDLoading:(NSTimeInterval)delayTime;

-(void)showHUDSuccessTips:(NSString*)theTips hideDelay:(NSTimeInterval)delayTime;
-(void)showHUDFailTips:(NSString*)theTips hideDelay:(NSTimeInterval)delayTime;
-(void)showHUDWarnTips:(NSString*)theTips hideDelay:(NSTimeInterval)delayTime;
-(void)showHUDCustomView:(UIView*)theCustomView withTips:(NSString*)theTips hideDelay:(NSTimeInterval)delayTime;
-(void)showHUDTextTips:(NSString*)theTips detail:(NSString*)theDetail hideDelay:(NSTimeInterval)delayTime;

-(void)showHUDExcuteBlock:(void(^)(MBProgressHUD *hudView))exBlock complete:(void(^)(void))theBlock;
-(void)showHUDProgressBlock:(void(^)(MBProgressHUD *hudView))exBlock complete:(void(^)(void))theBlock;

// -------------------

-(UIAlertView *)showAlertView:(NSString*)title withContent:(NSString*)content;
-(UIAlertView *)showAlertViewSelect:(NSString*)title content:(NSString*)content choseBlock:(AlertViewSelectBlock)theBlock;
-(UIAlertView *)showAlertViewInput:(NSString*)title content:(NSString*)content input:(UIAlertViewStyle)style choseBlock:(AlertViewInputSelectBlock)theBlock;

-(void)showTextView:(NSString*)theContent;
-(void)hideTextView:(UIControl*)theControl;

@end
