//
//  ViewController.m
//  Teleprompter_iOS
//
//  Created by fz on 2022/2/25.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import "AdjustSliderView.h"
#import "PlayscriptTextView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define textSize 30         //初始字号
#define moveSpeed 10         //初始速度

@interface ViewController () <AVPictureInPictureControllerDelegate>
{
    NSInteger speedInt;//速度记录
    NSInteger sizeInt;//字号记录
    UIWindow *firstWindow;//画中画
    
    NSTimer *timer;
    NSTimer *pipTimer;
}
@property (nonatomic, strong) PlayscriptTextView *textView;//页面展示
@property (nonatomic, strong) PlayscriptTextView *pipTextView;//画中画展示
@property (nonatomic, strong) UILabel *placeholderLab;//开启画中画占位
@property (nonatomic, strong) UIButton *startBtn;//开启画中画按钮

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;//播放内容
@property (nonatomic, strong) AVPictureInPictureController *pipVC;//画中画控制器

//字体大小
@property (nonatomic, strong) AdjustSliderView *sizeSlider;
//速度
@property (nonatomic, strong) AdjustSliderView *speedSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self performSelector:@selector(resetTextWithInterval:) withObject:nil afterDelay:0.5f];
    
    //画中画功能
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    self.pipVC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
    self.pipVC.delegate = self;
    [self.pipVC setValue:@1 forKey:@"controlsStyle"];
    
    [self.view addSubview:self.textView];
    
    [self.view addSubview:self.startBtn];
    
    //字号
    [self.view addSubview:self.sizeSlider];
    //速度
    [self.view addSubview:self.speedSlider];
}

//设置、重置滚动速度
- (void)resetTextWithInterval:(float)timeInterval
{
    if (timeInterval == 0 && speedInt == 0) {
        timeInterval = 0.06;
    } else if (timeInterval == 0 && speedInt != 0) {
        timeInterval = 0.6/speedInt;
    }
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval: timeInterval target: self selector:@selector(onTick:) userInfo: nil repeats:YES];
}

- (void)onTick:(NSTimer*)theTimer
{
    CGPoint pt = [self.textView.textV contentOffset];
    CGFloat n = pt.y + 1;
    [self.textView.textV setContentOffset:CGPointMake(pt.x, n)];
    
    if (n > (self.textView.textV.contentSize.height)) {
        [theTimer invalidate];
        theTimer = nil;
        [timer invalidate];
        timer = nil;
        //滚动回顶部重新开始
        [self.textView.textV scrollRangeToVisible:NSMakeRange(0, 1)];
        [self performSelector:@selector(resetTextWithInterval:) withObject:nil afterDelay:0.5f];
    }
}

- (void)resetPipTextWithInterval:(float)timeInterval
{
    if (timeInterval == 0 && speedInt == 0) {
        timeInterval = 0.06;
    } else if (timeInterval == 0 && speedInt != 0) {
        timeInterval = 0.6/speedInt;
    }
    [pipTimer invalidate];
    pipTimer = nil;
    pipTimer = [NSTimer scheduledTimerWithTimeInterval: timeInterval target: self selector:@selector(pipOnTick:) userInfo: nil repeats:YES];
}

- (void)pipOnTick:(NSTimer *)theTimer
{
    CGPoint pipPt = [self.pipTextView.textV contentOffset];
    CGFloat pipN = pipPt.y + 1;
    [self.pipTextView.textV setContentOffset:CGPointMake(pipPt.x, pipN)];
    
    if (pipN > (self.pipTextView.textV.contentSize.height)) {
        [theTimer invalidate];
        theTimer = nil;
        [pipTimer invalidate];
        pipTimer = nil;
        //滚动回顶部重新开始
        [self.pipTextView.textV scrollRangeToVisible:NSMakeRange(0, 1)];
        [self performSelector:@selector(resetPipTextWithInterval:) withObject:nil afterDelay:0.5f];
    }
}

#pragma mark --- button点击事件
- (void)didClickStartBtn
{
    //判断是否支持画中画功能
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        if (self.pipVC.isPictureInPictureActive) {
            [self.startBtn setTitle:@"开始提词" forState:UIControlStateNormal];
            [self.pipVC stopPictureInPicture];
        } else {
            [self.startBtn setTitle:@"结束提词" forState:UIControlStateNormal];
            [self.pipVC startPictureInPicture];
        }
    }
}

#pragma mark --- 画中画代理
// 即将开启画中画
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    //开始计时
    [self performSelector:@selector(resetPipTextWithInterval:) withObject:nil afterDelay:0.5f];
    
    firstWindow = [UIApplication sharedApplication].windows.firstObject;
    //添加KVO监听大小改变
    [firstWindow addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self.pipTextView resetFrame:CGRectMake(0, 0, firstWindow.bounds.size.width, firstWindow.bounds.size.height)];
    [firstWindow addSubview:self.pipTextView];
}
// 已经开启画中画
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    //先加遮盖
    [self.playerLayer addSublayer:self.placeholderLab.layer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 延迟0.2秒隐藏防止有系统页面闪过
        self.textView.hidden = YES;
    });
}
// 开启画中画失败
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    
}
// 即将关闭画中画
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    self.textView.hidden = NO;
}
// 已经关闭画中画
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    [pipTimer invalidate];
    pipTimer = nil;
    //滚动回顶部重新开始
    [self.pipTextView.textV scrollRangeToVisible:NSMakeRange(0, 1)];
}
// 关闭画中画且恢复播放界面
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler
{
    completionHandler(YES);
}

//frame改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // keypath
    if ([keyPath isEqualToString:@"frame"]) {
        [self.pipTextView resetFrame:CGRectMake(0, 0, firstWindow.bounds.size.width, firstWindow.bounds.size.height)];
    }
}

#pragma mark --- slider改变
- (void)valueChanged:(UISlider *)slider
{
    if (slider == self.sizeSlider.stempSlider) {
        //字号
        self.sizeSlider.sliderValue = slider.value;
        sizeInt = slider.value;
        self.textView.textFont = [UIFont systemFontOfSize:sizeInt];
        self.pipTextView.textFont = [UIFont systemFontOfSize:sizeInt];
    } else if (slider == self.speedSlider.stempSlider) {
        //速度
        self.speedSlider.sliderValue = slider.value;
        speedInt = slider.value;
        [self resetTextWithInterval:0.5/slider.value];
        [self resetPipTextWithInterval:0.5/slider.value];
    }
}


#pragma mark --- lazyload
- (PlayscriptTextView *)textView
{
    if (!_textView) {
        _textView = [[PlayscriptTextView alloc]initWithFrame:CGRectMake(30, 60, ScreenWidth-60, (ScreenWidth-60)*0.75)];
        _textView.textString = @"测试文本Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本lly configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本 UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本lly configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本";
        _textView.textFont = [UIFont systemFontOfSize:textSize];
        _textView.layer.cornerRadius = 10.0;
        _textView.layer.masksToBounds = YES;
        _textView.textV.layer.cornerRadius = 10.0;
        _textView.textV.layer.borderWidth = 1;
        _textView.textV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return _textView;
}
- (PlayscriptTextView *)pipTextView
{
    if (!_pipTextView) {
        _pipTextView = [[PlayscriptTextView alloc]init];
        _pipTextView.textString = @"测试文本Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本lly configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本 UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本lly configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.\nUse this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.测试文本测试文本测试文本测试文本测试文本";
        _pipTextView.textFont = [UIFont systemFontOfSize:textSize];
    }
    return _pipTextView;
}
- (UILabel *)placeholderLab
{
    if (!_placeholderLab) {
        _placeholderLab = [[UILabel alloc]initWithFrame:CGRectMake(0, -1, ScreenWidth-60, (ScreenWidth-60)*0.75+2)];
        _placeholderLab.backgroundColor = [UIColor whiteColor];
//        _placeholderLab.text = @"This video is playing in picture in picture.";
        _placeholderLab.textAlignment = NSTextAlignmentCenter;
        _placeholderLab.textColor = [UIColor lightGrayColor];
        _placeholderLab.font = [UIFont systemFontOfSize:13.0];
        _placeholderLab.numberOfLines = 0;
    }
    return _placeholderLab;
}
- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _startBtn.frame = CGRectMake(ScreenWidth/2-60, CGRectGetMaxY(self.textView.frame)+35, 120, 50);
        _startBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _startBtn.layer.borderWidth = 1;
        _startBtn.layer.cornerRadius = 25.0;
        [_startBtn setTitle:@"开始提词" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(didClickStartBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"holder" ofType:@"mp4"];
        NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
        self.avPlayer = [[AVPlayer alloc]initWithURL:sourceMovieUrl];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        _playerLayer.frame = CGRectMake(30, 60, ScreenWidth-60, (ScreenWidth-60)*0.75);
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.cornerRadius = 10.0;
        _playerLayer.masksToBounds = YES;
        [self.view.layer addSublayer:self.playerLayer];
    }
    return _playerLayer;
}

//字体大小
- (AdjustSliderView *)sizeSlider
{
    if (!_sizeSlider) {
        _sizeSlider = [[AdjustSliderView alloc]initWithFrame:CGRectMake(10, ScreenHeight-100, ScreenWidth-20, 30)];
        _sizeSlider.sliderValue = textSize;
        _sizeSlider.maximumValue = 80;
        _sizeSlider.minimumValue = 20;
        _sizeSlider.title = @"字号";
        [_sizeSlider sliderAddTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _sizeSlider;
}

//速度
- (AdjustSliderView *)speedSlider
{
    if (!_speedSlider) {
        _speedSlider = [[AdjustSliderView alloc]initWithFrame:CGRectMake(10, ScreenHeight-140, ScreenWidth-20, 30)];
        _speedSlider.maximumValue = 40;
        _speedSlider.minimumValue = 5;
        _speedSlider.sliderValue = moveSpeed;
        _speedSlider.title = @"速度";
        [_speedSlider sliderAddTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _speedSlider;
}

@end
