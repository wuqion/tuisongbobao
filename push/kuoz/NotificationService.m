//
//  NotificationService.m
//  MyNotification
//
//  Created by 吴琼 on 2019/5/7.
//  Copyright © 2019年 lcWorld. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationService ()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) AVSpeechSynthesizer    * synthesizer;
@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    //嗓音
    AVSpeechSynthesisVoice * voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    //内容配置
    AVSpeechUtterance      * utterance = [[AVSpeechUtterance alloc]initWithString:self.bestAttemptContent.title];
    utterance.voice = voice;
    utterance.rate  = 0.5;
    
    //合成器
    _synthesizer = [[AVSpeechSynthesizer alloc]init];
    _synthesizer.delegate = self;
    //朗读
    [_synthesizer speakUtterance:utterance];
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    //在这执行保证每条都能,朗读到
    self.contentHandler(self.bestAttemptContent);
    
}
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
