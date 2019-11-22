//
//  STIMVoiceOperator.h
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//
//  用于音频录制相关操作，可以给出音频要存储的文件名来录制音频，通过签订STIMVoiceOperatorFinishedRecordDelegate来得到录制完成后的文件名和存储路径以及音频时长。通过签订STIMVoiceOperatorUpdateViewDalegate协议来得到录制过程中峰值的变化和剩余时间的提醒  －－》剩余时间提醒已取消  15/5/4


#import "STIMCommonUIFramework.h"
#import <AVFoundation/AVFoundation.h>

@protocol STIMVoiceOperatorDelegate <NSObject>

- (void)voiceOperatorFinishedRecordWithFilepath:(NSString *)filePath andFilename:(NSString *)fileName andTimeCount:(CGFloat)timeCount;

- (void)updateVoiceViewHeightWithPower:(float)power;
//- (void)updateViewToAlertUserWithRemainTime:(float)remainTime;
@end

@interface STIMVoiceOperator : NSObject

@property (nonatomic, weak) id<STIMVoiceOperatorDelegate> voiceOperatorDelegate;

- (void)doVoiceRecordByFilename:(NSString *)filename;
- (void)finishRecoderWithSave:(BOOL)ifSave;

+ (NSDictionary *)getAudioRecorderSettingDic;

@end
