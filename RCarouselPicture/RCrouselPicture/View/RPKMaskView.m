//
//  RPKMaskView.m
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "RPKMaskView.h"

#import "UIView+RPKExtension.h"

#define rScreenWidth  [UIScreen mainScreen].bounds.size.width
#define rScreenHeight [UIScreen mainScreen].bounds.size.height

static NSInteger oneHour = 60 * 60;

@interface RPKMaskView()
// ******* 开始播放按钮 *******
@property (nonatomic, strong) UIButton *stratButton;
// ******* 单击手势 *******
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
// 当前时间
@property (nonatomic, strong) UILabel  *timeLabel;
// 总时间
@property (nonatomic, strong) UILabel  *allTimeLabel;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) NSTimer  *progressTimer;
@property (strong, nonatomic) UIButton *buttonFull;
// 总时长
@property(nonatomic, assign) NSInteger totalTimeLength;
@end

@implementation RPKMaskView

- (NSTimer *)progressTimer{
    if (_progressTimer == nil) {
        _progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    return _progressTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    [self addSubview:self.stratButton];
    [self createGesture];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.text = @"00:00";
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectMake(5, self.rpk_h - 10 - self.timeLabel.rpk_h, self.timeLabel.rpk_w, self.timeLabel.rpk_h);
    [self addSubview:self.timeLabel];

    self.buttonFull = [[UIButton alloc] initWithFrame:CGRectMake(rScreenWidth - 10 - 20, self.timeLabel.rpk_y + self.timeLabel.rpk_h / 2. - 10, 20, 20)];
    [self.buttonFull setImage:[UIImage imageNamed:@"mini_launchFullScreen_btn_hl"] forState:UIControlStateNormal];
    [self.buttonFull setImage:[UIImage imageNamed:@"full_minimize_btn_hl"] forState:UIControlStateSelected];
    [self.buttonFull addTarget:self action:@selector(buttonFullAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonFull];
    
    _allTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _allTimeLabel.textColor = [UIColor whiteColor];
    _allTimeLabel.font = [UIFont systemFontOfSize:14];
    _allTimeLabel.text = @"00:00";
    [_allTimeLabel sizeToFit];
    _allTimeLabel.frame = CGRectMake(self.buttonFull.rpk_x - 5 - _allTimeLabel.rpk_w, self.rpk_h - 10 - _allTimeLabel.rpk_h, _allTimeLabel.rpk_w, _allTimeLabel.rpk_h);
    [self addSubview:self.allTimeLabel];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(self.timeLabel.rpk_max_x + 5, self.timeLabel.rpk_y + self.timeLabel.rpk_h / 2. - 10, self.allTimeLabel.rpk_x - 10 - self.timeLabel.rpk_max_x, 20)];
    [self addSubview:self.slider];
    _slider.tintColor = [UIColor whiteColor];
    [_slider setThumbImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(touchDownSlider:) forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self action:@selector(valueChangedSlider:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self bottomViewHidden:[NSNumber numberWithBool:YES]];
}

- (UIImage *)createImageWithColor:(UIColor *)color;
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 12.0f, 12.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/** 移除定时器 */
-(void)removeProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)layoutFrame {
    _timeLabel.frame = CGRectMake(5, self.rpk_h - 10 - self.timeLabel.rpk_h, self.timeLabel.rpk_w, self.timeLabel.rpk_h);
    _buttonFull.frame = CGRectMake(rScreenWidth - 10 - 20, self.timeLabel.rpk_y + self.timeLabel.rpk_h / 2. - 10, 20, 20);
    _allTimeLabel.frame = CGRectMake(self.buttonFull.rpk_x - 5 - _allTimeLabel.rpk_w, self.rpk_h - 10 - _allTimeLabel.rpk_h, _allTimeLabel.rpk_w, _allTimeLabel.rpk_h);
    _slider.frame = CGRectMake(self.timeLabel.rpk_max_x + 5, self.timeLabel.rpk_y + self.timeLabel.rpk_h / 2. - 10, self.allTimeLabel.rpk_x - 10 - self.timeLabel.rpk_max_x, 20);
}

/*
 *  创建手势
 */
- (void)createGesture {
    // 单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:self.singleTap];
}



- (void)singleTapAction:(UITapGestureRecognizer *)tap {
    [self bottomViewHidden:[NSNumber numberWithBool:NO]];
    [self performSelector:@selector(bottomViewHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:3];
}

- (void)bottomViewHidden:(NSNumber *)hidden {
    
    self.timeLabel.hidden = [hidden boolValue];
    self.slider.hidden = [hidden boolValue];
    self.allTimeLabel.hidden = [hidden boolValue];
    self.buttonFull.hidden = [hidden boolValue];
}

- (void)setIsStartButton:(BOOL)isStartButton {
    _isStartButton = isStartButton;
    isStartButton ? [self.stratButton setHidden:YES] : [self.stratButton setHidden:NO];
}

- (void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)sliderValue {
    
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectMake(5, self.rpk_h - 10 - self.timeLabel.rpk_h, self.timeLabel.rpk_w, self.timeLabel.rpk_h);
    if (_totalTimeLength == 0) {
        _totalTimeLength = totalTime;
        self.allTimeLabel.text = [self timeToStringWithTimeInterval:totalTime];
        [self.allTimeLabel sizeToFit];
        self.allTimeLabel.frame = CGRectMake(self.buttonFull.rpk_x - 5 - _allTimeLabel.rpk_w, self.rpk_h - 10 - _allTimeLabel.rpk_h, _allTimeLabel.rpk_w, _allTimeLabel.rpk_h);
    }
    self.slider.frame = CGRectMake(self.timeLabel.rpk_max_x + 5, self.timeLabel.rpk_y + self.timeLabel.rpk_h / 2. - 10, self.allTimeLabel.rpk_x - 10 - self.timeLabel.rpk_max_x, 20);
    self.slider.value = sliderValue;
}

- (NSString *)timeToStringWithTimeInterval:(NSInteger)second {
    NSString *time = @"";
    if (second < oneHour) {
        int minute = (int)second / 60;
        int sec = (int)second % 60;
        time = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
    }
    else {
        int hour = (int)second / oneHour;
        int minute = (int)second % oneHour / 60;
        int sec = (int)second % 60;
        time = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, sec];
    }
    return time;
}


- (UIButton *)stratButton {
    if (!_stratButton) {
        _stratButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stratButton.bounds = CGRectMake(0, 0, 40, 40);
        _stratButton.center = self.center;
        [_stratButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_stratButton addTarget:self action:@selector(startButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stratButton;
}

- (void)buttonFullAction:(UIButton *)sender {
    if (self.clickFullButton) {
        sender.selected = !sender.selected;
        self.clickFullButton(sender.selected);
    }
}

- (void)startButtonTaped {
    if (self.buttonValue) {
        self.buttonValue(XQPlayerStateStart);
    }
}

- (void)replayButtonTaped {
    if (self.buttonValue) {
        self.buttonValue(XQPlayerStateReplay);
    }
}

- (void)updateProgressInfo {
    
}

#pragma mark - slider方法
- (void)touchDownSlider:(UISlider *)sender {
    // 按下去 移除监听器
    [self removeProgressTimer];
}

- (void)valueChangedSlider:(UISlider *)sender {
    // 计算slider拖动的点对应的播放时间
    NSTimeInterval currentTime = _totalTimeLength * sender.value;
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
}

- (void)touchUpInside:(UISlider *)sender {
    [self progressTimer];
    //计算当前slider拖动对应的播放时间
    NSTimeInterval currentTime = _totalTimeLength * sender.value;
    if (self.sliderDidChange) {
        self.sliderDidChange(currentTime);
    }
}

@end
