
//
//  RPKVideoCollectionViewCell.m
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "RPKVideoCollectionViewCell.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+RPK.h"

#import "RPKMaskView.h"
#import "RPKFullViewController.h"


@interface RPKVideoCollectionViewCell()<AVPlayerViewControllerDelegate>

@property(nonatomic, strong) AVPlayerViewController *videoPlayer;

@property (nonatomic, strong) RPKMaskView *videoMaskView;

@property (nonatomic, strong) id timeObserve;
@property (strong, nonatomic) RPKFullViewController *fullVc;
@end

@implementation RPKVideoCollectionViewCell

- (AVPlayerViewController *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[AVPlayerViewController alloc] init];
        _videoPlayer.view.frame = self.frame;
        _videoPlayer.delegate = self;
        _videoPlayer.showsPlaybackControls = NO;
        _videoPlayer.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.videoUrl]];
    }
    return _videoPlayer;
}

- (RPKMaskView *)videoMaskView {
    if (!_videoMaskView) {
        _videoMaskView = [[RPKMaskView alloc]initWithFrame:self.frame];
    }
    return _videoMaskView;
}

- (RPKFullViewController *)fullVc {
    if (_fullVc == nil) {
        _fullVc = [[RPKFullViewController alloc] init];
    }
    return _fullVc;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    
    [self addSubview:self.videoPlayer.view];
    [self addSubview:self.videoMaskView];
    
    __weak typeof(self) weakSelf = self;
    self.videoMaskView.buttonValue = ^(XQPlayerState state) {
        switch (state) {
            case XQPlayerStateStart: {
                weakSelf.videoMaskView.isStartButton = !weakSelf.videoMaskView.isStartButton;
                weakSelf.isPlay = weakSelf.videoMaskView.isStartButton;
                weakSelf.videoMaskView.isStartButton ? [weakSelf.videoPlayer.player play] : [weakSelf.videoPlayer.player pause];
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoCollectionViewCell:didClickPlay:)]) {
                    [weakSelf.delegate videoCollectionViewCell:weakSelf didClickPlay:nil];
                }
            }
                break;
            case XQPlayerStateReplay: { //重新播放  归0、
                
                weakSelf.videoMaskView.isStartButton = YES;
                weakSelf.isPlay = weakSelf.videoMaskView.isStartButton;
                
                CMTime dragedCMTime = CMTimeMake(0, 1);
                [weakSelf.videoPlayer.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
                    [weakSelf.videoPlayer.player play];
                }];
            }
                break;
                
            default:
                break;
        }
    };
    
    self.videoMaskView.sliderDidChange = ^(NSTimeInterval timeInterval) {
        [weakSelf.videoPlayer.player seekToTime:CMTimeMakeWithSeconds(timeInterval, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    };
    
    self.videoMaskView.clickFullButton = ^(BOOL selected){
        if (selected == NO) {
            UIViewController *currentViewContrller = [UIViewController getCurrentVC];
            [currentViewContrller presentViewController:weakSelf.fullVc animated:NO completion:^{
                [weakSelf.fullVc.view addSubview:weakSelf.videoPlayer.view];
                [weakSelf.fullVc.view addSubview:weakSelf.videoMaskView];
//                self.imageView.center = self.fullVc.view.center;
                
                [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    weakSelf.videoPlayer.view.frame = weakSelf.fullVc.view.bounds;
                    weakSelf.videoMaskView.frame = weakSelf.fullVc.view.bounds;
                    [weakSelf.videoMaskView layoutFrame];
                } completion:nil];
            }];
        }else{
            [weakSelf.fullVc dismissViewControllerAnimated:NO completion:^{
                [weakSelf addSubview:weakSelf.videoPlayer.view];
                [weakSelf addSubview:weakSelf.videoMaskView];
                
                [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    weakSelf.videoPlayer.view.frame = weakSelf.bounds;
                    weakSelf.videoMaskView.frame = weakSelf.bounds;
                    [weakSelf.videoMaskView layoutFrame];
                } completion:nil];
            }];
        }
    };
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        [self createTimer];
    }
}

- (void)setIsAotoPlay:(BOOL)isAotoPlay {
    _isAotoPlay = isAotoPlay;
    self.videoMaskView.isStartButton = isAotoPlay;
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    [_videoPlayer.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]]];
    // ******* 监听player *******
    [self.videoPlayer.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//    _videoPlayer.player = [AVPlayer playerWithURL:[NSURL URLWithString:_videoUrl]];
    //    [self loadSubviews];
}

- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.videoPlayer.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.videoPlayer.player.currentItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.videoMaskView playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

- (void)start {
    [self.videoPlayer.player play];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCollectionViewCell:didClickPlay:)]) {
        [self.delegate videoCollectionViewCell:self didClickPlay:nil];
    }
}

- (void)stop {
    [self.videoPlayer.player pause];
}

- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"------------");
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    NSLog(@"++++++++++++");
}

- (void)dealloc {
    // 移除time观察者
    if (self.timeObserve) {
        [self.videoPlayer.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
}


@end
