//
//  STIMSDKUIHelper.h
//  STIMSDK
//
//  Created by 李露 on 2018/9/29.
//  Copyright © 2018年 STIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STIMSDKUIHelper : NSObject

+ (instancetype)shareInstance;

+ (instancetype)sharedInstanceWithRootNav:(UINavigationController *)nav rootVc:(UIViewController *)rootVc;

//推送点击回调调转会话
- (void)checkUpNotifacationHandle;

//QChat更新应用模版
- (void)updateMicroTourModel;

@end
