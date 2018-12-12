//
//  RPKCrouselPicture.h
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPKCrouselPicture;

typedef enum {
    RPKCrouselPicturePageContolAlimentRight,
    RPKCrouselPicturePageContolAlimentCenter
} RPKCrouselPicturePageContolAliment;

typedef enum {
    RPKCrouselPicturePageContolStyleClassic,        // 系统自带经典样式
    RPKCrouselPicturePageContolStyleAnimated,       // 动画效果pagecontrol
    RPKCrouselPicturePageContolStyleNone            // 不显示pagecontrol
} RPKCrouselPicturePageContolStyle;


@protocol RPKCrouselPictureDelegate <NSObject>


// 点击图片回调
- (void)crouselPicture:(RPKCrouselPicture *)crouselPicture didSelectItemAtIndex:(NSInteger)index;

//图片滚动回调
- (void)crouselPicture:(RPKCrouselPicture *)crouselPicture didScrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RPKCrouselPicture : UIView
// 网络图片/视频
@property(nonatomic, copy) NSArray <NSString *>*imageUrls;
// 本地图片/视频
@property(nonatomic, copy) NSArray <NSString *>*localImageNames;
// 图片/视频文字描述
@property(nonatomic, copy) NSArray <NSString *>*imageDescriptions;
// block方式监听点击
@property(nonatomic, copy) void (^clickItemOperationBlock)(NSInteger currentIndex);
// block方式监听滚动
@property(nonatomic, copy) void (^itemDidScrollOperationBlock)(NSInteger currentIndex);
// block方式监听播放按钮点击
@property(nonatomic, copy) void (^clickItemPlayOperationBlock)(NSInteger currentIndex);
// 委托
@property(nonatomic, assign) id<RPKCrouselPictureDelegate> delegate;
// 是否自动滚动,默认Yes
@property(nonatomic, assign) BOOL autoScroll;
// 是否无限循环 默认YES
@property(nonatomic, assign) BOOL isInfiniteLoop;
// 自动滚动间隔时间,默认2s
@property(nonatomic, assign) CGFloat autoScrollTimeInterval;
// 图片滚动方向，默认为水平滚动
@property(nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
//占位图，用于网络未加载到图片时 */
@property(nonatomic, strong) UIImage *placeholderImage;
//是否显示分页控件 */
@property(nonatomic, assign) BOOL showPageControl;
//是否在只有一张图时隐藏pagecontrol，默认为YES */
@property(nonatomic, assign) BOOL hidesForSinglePage;
//只展示文字轮播 */
@property(nonatomic, assign) BOOL onlyDisplayText;
@property(nonatomic, assign) CGFloat pageControlBottomOffset;
//分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量 */
@property(nonatomic, assign) CGFloat pageControlRightOffset;
//分页控件小圆标大小 */
@property(nonatomic, assign) CGSize pageControlDotSize;
//当前分页控件小圆标颜色 */
@property(nonatomic, strong) UIColor *currentPageDotColor;
//其他分页控件小圆标颜色 */
@property(nonatomic, strong) UIColor *pageDotColor;
//当前分页控件小圆标图片 */
@property(nonatomic, strong) UIImage *currentPageDotImage;
//其他分页控件小圆标图片 */
@property(nonatomic, strong) UIImage *pageDotImage;
//轮播文字label字体颜色 */
@property(nonatomic, strong) UIColor *titleLabelTextColor;
//轮播文字label字体大小 */
@property(nonatomic, strong) UIFont  *titleLabelTextFont;
//轮播文字label背景颜色 */
@property(nonatomic, strong) UIColor *titleLabelBackgroundColor;
//轮播文字label高度 */
@property(nonatomic, assign) CGFloat titleLabelHeight;
//轮播文字label对齐方式 */
@property(nonatomic, assign) NSTextAlignment titleLabelTextAlignment;
// 分页控件位置
@property(nonatomic, assign) RPKCrouselPicturePageContolAliment pageControlAliment;
// pagecontrol 样式，默认为动画样式
@property(nonatomic, assign) RPKCrouselPicturePageContolStyle pageControlStyle;
// 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill
@property(nonatomic, assign) UIViewContentMode bannerImageViewContentMode;
// 第一个是否是视频 default:NO
@property(nonatomic, assign) BOOL firstIsVideo;
// 是否自动播放第一个视频  defualt: YES
@property(nonatomic, assign) BOOL isPlayFirstVideo;

/**
 初始化轮播图（推荐使用）

 @param frame frame
 @param delegate 委托对象
 @param imageUrls 图片数组（可以是网络图片，也可以是本地图片）
 @param placeholderImage 默认图片
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RPKCrouselPictureDelegate>)delegate imageUrls:(NSArray *)imageUrls placeholderImage:(UIImage *)placeholderImage;

/**
 初始化轮播图

 @param frame frame
 @param imageUrls 网络图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame imageUrls:(NSArray <NSString *>*)imageUrls;

/**
 初始化轮播图 本地图片

 @param frame frame
 @param imageNames 本地图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame localImageName:(NSArray <NSString *>*)imageNames;

/**
 初始化轮播图

 @param frame frame
 @param infiniteLoop 是否无限循环
 @param imageUrls 图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop imageUrls:(NSArray <NSString *>*)imageUrls;


/**
 清除图片缓存（此次升级后统一使用SDWebImage管理图片加载和缓存）
 */
+ (void)clearImagesCache;

@end

NS_ASSUME_NONNULL_END
