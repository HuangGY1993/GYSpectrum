//
//  ViewController.m
//  GYSpectrum
//
//  Created by 黄国裕 on 16/8/19.
//  Copyright © 2016年 黄国裕. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UILabel *tipLabel;
}

@property (strong, nonatomic) AVAudioSession *audioSession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SpectrumView * spectrumView = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50,120,100, 40.0)];
    spectrumView.text = [NSString stringWithFormat:@"%d",0];
    __weak SpectrumView * weakSpectrum = spectrumView;
    spectrumView.itemLevelCallback = ^() {
        
        [self.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围时-160到0
        float power= [self.audioRecorder averagePowerForChannel:0];
        weakSpectrum.level = power;
    };
    
    [self.view addSubview:spectrumView];
    
    
    SpectrumView * spectrumView1 = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-100,180,200, 50.0)];
    spectrumView1.text = [NSString stringWithFormat:@"%d",0];
    __weak SpectrumView * weakSpectrum1 = spectrumView1;
    spectrumView1.itemLevelCallback = ^() {
        
        [self.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围时-160到0
        float power= [self.audioRecorder averagePowerForChannel:0];
        weakSpectrum1.level = power;
    };
    
    [self.view addSubview:spectrumView1];
    
    
    SpectrumView * spectrumView2 = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-150,240,300, 60.0)];
    spectrumView2.text = [NSString stringWithFormat:@"%d",0];
    __weak SpectrumView * weakSpectrum2 = spectrumView2;
    spectrumView2.itemLevelCallback = ^() {
        
        [self.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围时-160到0
        float power= [self.audioRecorder averagePowerForChannel:0];
        weakSpectrum2.level = power;
    };
    
    [self.view addSubview:spectrumView2];
    
    [self.view addSubview:[self setRecordButton]];
    [self setTipLabel];
    
}

- (UIButton*)setRecordButton
{
    UIButton *recordButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50, CGRectGetMaxY(self.view.frame)-180, 100, 100)];
    
    [recordButton setBackgroundImage:[UIImage imageNamed:@"Recording-default"] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"Recording"] forState:UIControlStateFocused];
    
    // 开始
    [recordButton addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    // 取消
    [recordButton addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchUpOutside];
    //完成
    [recordButton addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
    //移出
    [recordButton addTarget:self action:@selector(recordTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    //移入
    [recordButton addTarget:self action:@selector(recordTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    
    return recordButton;
}

- (void)setTipLabel
{
    tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-240, CGRectGetMaxX(self.view.frame),30)];
    tipLabel.textColor = [UIColor lightGrayColor];
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:tipLabel];
}


- (void)recordStart:(UIButton *)button
{
    
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [_audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
        if(err){
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
        err = nil;
        [_audioSession setActive:YES error:&err];
        if(err){
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    if (![self.audioRecorder isRecording]) {
        
        [self.audioRecorder record];
        tipLabel.text = @"正在录音";
        NSLog(@"录音开始");
        
    }
    
}


- (void)recordCancel:(UIButton *)button
{
    
    if ([self.audioRecorder isRecording]) {
        
        NSLog(@"取消");
        [self.audioRecorder stop];
        tipLabel.text = @"";
        
    }
}

- (void)recordFinish:(UIButton *)button
{
    
    if ([self.audioRecorder isRecording]) {
        
        NSLog(@"完成");
        [self.audioRecorder stop];
        tipLabel.text = @"";
        
    }
    
}

- (void)recordTouchDragExit:(UIButton *)button
{
    if([self.audioRecorder isRecording]){
        tipLabel.text = @"松开取消";
    }
}

- (void)recordTouchDragEnter:(UIButton *)button
{
    if([self.audioRecorder isRecording]){
        tipLabel.text = @"正在录音";
    }
}



/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}


/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    
    //  在Documents目录下创建一个名为FileData的文件夹
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AudioData"];
    NSLog(@"%@",path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    
    path = [path stringByAppendingPathComponent:@"myRecord.aac"];
    NSLog(@"file path:%@",path);
    NSURL *url=[NSURL fileURLWithPath:path];
    return url;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
