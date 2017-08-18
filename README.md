# GYSpectrum
### iOS音频频谱，仿QQ录音频谱


先上效果图：

![image](https://github.com/HuangGY1993/GYSpectrum/blob/master//display.gif)


示例用法：

        SpectrumView * spectrumView = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 100,180,200, 40.0)];
        spectrumView.text = [NSString stringWithFormat:@"%d",0];
        __weak SpectrumView * weakWaver = spectrumView;
        spectrumView.itemLevelCallback = ^() {

        [self.audioRecorder updateMeters];

        //取得第一个通道的音频，音频强度范围是-160到0
        float power = [self.audioRecorder averagePowerForChannel:0];
        weakWaver.level = power;

        };
        [self.view addSubview:spectrumView];


使用前请注意：

        SpectrumView.frame.size.width / SpectrumView.numberOfItems >= 5

        默认SpectrumView.numberOfItems = 20 (可修改，必须为偶数)，所以SpectrumView.frame.size.width默认要大于100
        例如：SpectrumView * spectrumView = [[SpectrumView alloc] initWithFrame:CGRectMake(0,0,100,40)];
