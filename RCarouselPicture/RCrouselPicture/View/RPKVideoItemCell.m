//
//  RPKVideoItemCell.m
//  RCarouselPicture
//
//  Created by RPK on 2018/12/11.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "RPKVideoItemCell.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RPKVideoItemCell()
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) AVPlayerItem *playerItem;
//@property (strong, nonatomic) RPKFullViewController *fullVc;
@property (strong, nonatomic) UIView *showTime;
@property (strong, nonatomic) UIButton *buttonFull;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIButton *replayBtn;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *allTimeLabel;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) UIButton *playOrPauseBtn;

@end

@implementation RPKVideoItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    // 初始化player 和playerLayer
    self.avPlayer = [[AVPlayer alloc]init];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200.0)];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.imageView];
    
    // imageView上添加playerLayer
    [self.imageView.layer addSublayer:self.avPlayerLayer];
    self.avPlayerLayer.frame = self.imageView.bounds;
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.avPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self.imageView addSubview:self.maskView];
    [self.imageView addSubview:self.showTime];
    
}

/** 全屏按钮 */
- (void)fullScreen:(UIButton *)sender{
    if (sender.selected == NO) {
//        [self presentViewController:self.fullVc animated:NO completion:^{
//            [self.fullVc.view addSubview:self.imageView];
//            self.imageView.center = self.fullVc.view.center;
//
//            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                self.imageView.frame = self.fullVc.view.bounds;
//                [self layoutFrame];
//                [self fullscreenOrNotFullScreen];
//            } completion:nil];
//        }];
    }else{
//        [self.fullVc dismissViewControllerAnimated:NO completion:^{
//            [self addSubview:self.imageView];
//
//            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                self.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200.0);
//                [self layoutFrame];
//                [self fullscreenOrNotFullScreen];
//            } completion:nil];
//        }];
    }
    sender.selected = !sender.selected;
}

/** 点击全屏按钮 */
- (void)fullscreenOrNotFullScreen{
    self.replayBtn.selected = NO;
    [self resetPlay:_replayBtn];
}


/** 播放暂停 */
- (void)player:(UIButton *)sender{
    
    if (sender.selected == YES) {//暂停
        [self.avPlayer pause];
        [self removeProgressTimer];
        self.maskView.hidden = NO;
        self.replayBtn.hidden = NO;
        self.replayBtn.selected = NO;
    }else{
        self.replayBtn.selected = YES;
        self.maskView.hidden = YES;
        self.replayBtn.hidden = YES;
        [self progressTimer];
        [self.avPlayer play];
    }
    sender.selected = !sender.selected;
}


/** 重新播放 */
- (void)resetPlay:(UIButton *)sender{
    if (sender.isSelected) {
        self.slider.value = 0.0;
        self.playOrPauseBtn.selected = YES;
        [self.avPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
        //计算当前slider拖动对应的播放时间
        NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration) * self.slider.value;
        // 播放移动到当前播放时间
        [self.avPlayer seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }else{
        self.playOrPauseBtn.selected = YES;
    }
    [self removeProgressTimer];
    [self.avPlayer play];
    [self progressTimer];
    sender.selected = YES;
    sender.hidden = YES;
    self.maskView.hidden = YES;
}

/** 转换播放时间和总时间的方法 */
-(NSString *)timeToStringWithTimeInterval:(NSTimeInterval)interval;{
    NSInteger Min = interval / 60;
    NSInteger Sec = (NSInteger)interval % 60;
    NSString *intervalString = [NSString stringWithFormat:@"%02ld:%02ld",Min,Sec];
    return intervalString;
}

/** 更新slider和timeLabel */
- (void)updateProgressInfo {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayer.currentTime);
    NSTimeInterval durationTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
    self.allTimeLabel.text = [self timeToStringWithTimeInterval:durationTime];
    self.slider.value = CMTimeGetSeconds(self.avPlayer.currentTime) / CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    
    
    if (self.slider.value == 1) {
        [self removeProgressTimer];
        self.replayBtn.selected = YES;
        self.maskView.hidden = NO;
        self.replayBtn.hidden = NO;
        NSLog(@"播放完了");
    }
    
}

/** slider拖动和点击事件 */
- (void)touchDownSlider:(UISlider *)sender {
    // 按下去 移除监听器
    [self removeProgressTimer];
}
- (void)valueChangedSlider:(UISlider *)sender {
    
    // 计算slider拖动的点对应的播放时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration) * sender.value;
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
}
- (void)touchUpInside:(UISlider *)sender {
    [self progressTimer];
    //计算当前slider拖动对应的播放时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration) * sender.value;
    // 播放移动到当前播放时间
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    //    [self addShowTime];
}

//- (RPKFullViewController *)fullVc {
//    if (_fullVc == nil) {
//        _fullVc = [[RPKFullViewController alloc] init];
//    }
//    return _fullVc;
//}


- (void)layoutFrame{
    self.avPlayerLayer.frame = self.imageView.bounds;
    [self setShowTimeFrame];
}

- (void)setShowTimeFrame{
    self.showTime.frame = CGRectMake(0, self.imageView.frame.size.height-40.0, [UIScreen mainScreen].bounds.size.width, 40);
    self.buttonFull.frame = CGRectMake(_showTime.frame.size.width-30-10, 5, 30, 30);
    self.maskView.frame = self.imageView.bounds;
    self.replayBtn.center = self.maskView.center;
    self.slider.frame = CGRectMake(0, 0, _showTime.frame.size.width, 1);
}


- (UIView *)showTime{
    if (_showTime == nil) {
        _showTime = [[UIView alloc] init];
        _showTime.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"full_play_btn_hl"] forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 5, 30, 30);
        [button setImage:[UIImage imageNamed:@"full_pause_btn"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
        [_showTime addSubview:button];
        _playOrPauseBtn = button;
        
        UIButton *buttonFull = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonFull setImage:[UIImage imageNamed:@"mini_launchFullScreen_btn_hl"] forState:UIControlStateNormal];
        [buttonFull setImage:[UIImage imageNamed:@"full_minimize_btn_hl"] forState:UIControlStateSelected];
        [buttonFull addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_showTime addSubview:buttonFull];
        _buttonFull = buttonFull;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame) + 10.0, 0, 40.0, 40.0)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:14.0];
        [_showTime addSubview:_timeLabel];
        
        _allTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLabel.frame) + 10.0, 0, 40.0, 40.0)];
        _allTimeLabel.textColor = [UIColor whiteColor];
        _allTimeLabel.font = [UIFont systemFontOfSize:14.0];
        [_showTime addSubview:_allTimeLabel];
        
        _slider = [[UISlider alloc] init];
        _slider.tintColor = [UIColor redColor];
        [_slider setThumbImage:[UIImage imageNamed:@"thumbImage"] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(touchDownSlider:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(valueChangedSlider:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_showTime addSubview:_slider];
        
        [self setShowTimeFrame];
    }
    return _showTime;
}

- (UIView *)maskView{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replayBtn setImage:[UIImage imageNamed:@"player"] forState:UIControlStateNormal];
        [_replayBtn setImage:[UIImage imageNamed:@"chongbo"] forState:UIControlStateSelected];
        [_replayBtn addTarget:self action:@selector(resetPlay:) forControlEvents:UIControlEventTouchUpInside];
        _replayBtn.bounds = CGRectMake(0, 0, 50, 50);
        [_maskView addSubview:_replayBtn];
    }
    return _maskView;
}

- (NSTimer *)progressTimer{
    if (_progressTimer == nil) {
        _progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    return _progressTimer;
}

/** 移除定时器 */
-(void)removeProgressTimer{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)dealloc{
    [self removeProgressTimer];
    
}



@end
