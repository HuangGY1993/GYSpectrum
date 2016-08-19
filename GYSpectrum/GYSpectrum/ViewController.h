//
//  ViewController.h
//  GYSpectrum
//
//  Created by 黄国裕 on 16/8/19.
//  Copyright © 2016年 黄国裕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpectrumView.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController : UIViewController<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机

@end

