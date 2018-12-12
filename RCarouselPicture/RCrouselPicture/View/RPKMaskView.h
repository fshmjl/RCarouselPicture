//
//  RPKMaskView.h
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XQPlayerState) {
    XQPlayerStateStart,
    XQPlayerStateReplay
};

typedef void(^StartButtonTapedBlock)(XQPlayerState state);
typedef void(^SliderDidChange)(NSTimeInterval timeInterval);
typedef void(^ClickFullButton)(BOOL selected);

@interface RPKMaskView : UIView

/*
 * 底部进度条的值
 */
@property (nonatomic, assign) CGFloat progressValue;

/*
 * 开始按钮的状态
 */
@property (nonatomic, assign) BOOL isStartButton;

/*
 * 开始按钮点击Block
 */
@property (nonatomic, copy) StartButtonTapedBlock buttonValue;

@property(nonatomic, copy) SliderDidChange sliderDidChange;

@property(nonatomic, copy) ClickFullButton clickFullButton;

-(void)removeProgressTimer;

- (void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)sliderValue;
- (void)layoutFrame;

@end

NS_ASSUME_NONNULL_END
