//
//  RPKCrouselPicture.m
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "RPKCrouselPicture.h"

#import "UIView+RPKExtension.h"
#import "UIImageView+WebCache.h"

#import "RPKPageControl.h"
#import "RPKCollectionViewCell.h"
#import "RPKVideoCollectionViewCell.h"


NSString * const videoIdentifier = @"videoCell";
NSString * const imageIdentifier = @"imageCell";
#define kRPKCrouselPicturePageControlDotSize CGSizeMake(10, 10)

@interface RPKCrouselPicture()<UICollectionViewDelegate, UICollectionViewDataSource, RPKVideoCollectionViewCellDelegate>

@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic, weak) UIControl *pageControl;
@property(nonatomic, copy) NSArray *imagePathsGroup;
@property(nonatomic, weak) UICollectionView *mainView; // 显示图片的collectionView
@property(nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, assign) NSInteger totalItemsCount;
@property(nonatomic, strong) UIImageView *backgroundImageView; // 当imageURLs为空时的背景图
@end

@implementation RPKCrouselPicture

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialization];
    [self setupMainView];
}

/**
 初始化轮播图（推荐使用）
 
 @param frame frame
 @param delegate 委托对象
 @param imageUrls 图片数组（可以是网络图片，也可以是本地图片）
 @param placeholderImage 默认图片
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RPKCrouselPictureDelegate>)delegate imageUrls:(NSArray *)imageUrls placeholderImage:(UIImage *)placeholderImage {
    RPKCrouselPicture *crouselPicture = [self initWithFrame:frame];
    self.delegate                     = delegate;
    self.imageUrls                    = imageUrls;
    self.placeholderImage             = placeholderImage;
    return crouselPicture;
}

/**
 初始化轮播图
 
 @param frame frame
 @param imageUrls 网络图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame imageUrls:(NSArray <NSString *>*)imageUrls {
    RPKCrouselPicture *crouselPicture = [self initWithFrame:frame];
    crouselPicture.imageUrls = imageUrls;
    return crouselPicture;
}

/**
 初始化轮播图 本地图片
 
 @param frame frame
 @param imageNames 本地图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame localImageName:(NSArray <NSString *>*)imageNames {
    RPKCrouselPicture *crouselPicture = [self initWithFrame:frame];
    crouselPicture.localImageNames = imageNames;
    return crouselPicture;
}

/**
 初始化轮播图
 
 @param frame frame
 @param isInfiniteLoop isInfiniteLoop:是否无限循环
 @param imageUrls 图片数组
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)isInfiniteLoop imageUrls:(NSArray <NSString *>*)imageUrls {
    RPKCrouselPicture *crouselPicture = [self initWithFrame:frame];
    crouselPicture.isInfiniteLoop = isInfiniteLoop;
    crouselPicture.localImageNames = imageUrls;
    return crouselPicture;
}

- (void)initialization {
    _pageControlAliment        = RPKCrouselPicturePageContolAlimentCenter;
    _autoScrollTimeInterval    = 3.0;
    _titleLabelTextColor       = [UIColor whiteColor];
    _titleLabelTextFont        = [UIFont systemFontOfSize:14];
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabelHeight          = 30;
    _titleLabelTextAlignment   = NSTextAlignmentLeft;
    _autoScroll                = YES;
    _isInfiniteLoop            = YES;
    _showPageControl           = YES;
    _pageControlDotSize        = kRPKCrouselPicturePageControlDotSize;
    _pageControlBottomOffset   = 0;
    _pageControlRightOffset    = 0;
    _pageControlStyle          = RPKCrouselPicturePageContolStyleClassic;
    _hidesForSinglePage        = YES;
    _currentPageDotColor       = [UIColor whiteColor];
    _pageDotColor              = [UIColor lightGrayColor];
    _isPlayFirstVideo          = YES;
    self.backgroundColor       = [UIColor lightGrayColor];
    _bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    
}

/**
 初始化视图
 */
- (void)setupMainView {
    
    UICollectionViewFlowLayout *flowLayout  = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing           = 0;
    flowLayout.scrollDirection              = UICollectionViewScrollDirectionHorizontal;
    _flowLayout                             = flowLayout;
    
    UICollectionView *mainView              = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor                = [UIColor clearColor];
    mainView.pagingEnabled                  = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator   = NO;
    mainView.dataSource                     = self;
    mainView.delegate                       = self;
    mainView.scrollsToTop                   = NO;
    _mainView                               = mainView;
    [self addSubview:mainView];
    [mainView registerClass:[RPKVideoCollectionViewCell class] forCellWithReuseIdentifier:videoIdentifier];
    [mainView registerClass:[RPKCollectionViewCell class] forCellWithReuseIdentifier:imageIdentifier];
    
}


#pragma mark - properties

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView) {
        UIImageView *bgImageView = [UIImageView new];
        
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self insertSubview:bgImageView belowSubview:self.mainView];
        self.backgroundImageView = bgImageView;
    }
    
    self.backgroundImageView.image = placeholderImage;
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setupPageControl];
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageContol = (RPKPageControl *)_pageControl;
        pageContol.dotSize = pageControlDotSize;
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageControl = (RPKPageControl *)_pageControl;
        pageControl.dotColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    
    if (self.pageControlStyle != RPKCrouselPicturePageContolStyleAnimated) {
        self.pageControlStyle = RPKCrouselPicturePageContolStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    
    if (self.pageControlStyle != RPKCrouselPicturePageContolStyleAnimated) {
        self.pageControlStyle = RPKCrouselPicturePageContolStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageControl = (RPKPageControl *)_pageControl;
        if (isCurrentPageDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    }
}

- (void)setIsInfiniteLoop:(BOOL)isInfiniteLoop
{
    _isInfiniteLoop = isInfiniteLoop;
    
    if (self.imagePathsGroup.count) {
        self.imagePathsGroup = self.imagePathsGroup;
    }
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    
    [self invalidateTimer];
    
    if (_autoScroll) {
        if (!self.firstIsVideo) {
            [self setupTimer];
        }
    }
}

- (void)setFirstIsVideo:(BOOL)firstIsVideo {
    _firstIsVideo = firstIsVideo;
    if (firstIsVideo) {
        [self invalidateTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    
    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setAutoScroll:self.autoScroll];
}

- (void)setPageControlStyle:(RPKCrouselPicturePageContolStyle)pageControlStyle
{
    _pageControlStyle = pageControlStyle;
    
    [self setupPageControl];
}

- (void)setImagePathsGroup:(NSArray *)imagePathsGroup
{
    [self invalidateTimer];
    
    _imagePathsGroup = imagePathsGroup;
    
//    _totalItemsCount = self.isInfiniteLoop ? self.imagePathsGroup.count + 2 : self.imagePathsGroup.count;
    _totalItemsCount = self.imagePathsGroup.count + 1;
    if (imagePathsGroup.count != 1) {
        self.mainView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.mainView.scrollEnabled = NO;
    }
    
    [self setupPageControl];
    [self.mainView reloadData];
}

- (void)setImageUrls:(NSArray<NSString *> *)imageUrls
{
    _imageUrls = imageUrls;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageUrls enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setLocalImageNames:(NSArray<NSString *> *)localImageNames
{
    _localImageNames = localImageNames;
    self.imagePathsGroup = [localImageNames copy];
}

- (void)setImageDescriptions:(NSArray<NSString *> *)imageDescriptions
{
    _imageDescriptions = imageDescriptions;
    if (self.onlyDisplayText) {
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < _imageDescriptions.count; i++) {
            [temp addObject:@""];
        }
        self.backgroundColor = [UIColor clearColor];
        self.imageUrls = [temp copy];
    }
}

#pragma mark - actions

- (void)setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)setupPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    
    if (self.imagePathsGroup.count == 0 || self.onlyDisplayText) return;
    
    if ((self.imagePathsGroup.count == 1) && self.hidesForSinglePage) return;
    
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
    
    switch (self.pageControlStyle) {
        case RPKCrouselPicturePageContolStyleAnimated:
        {
            RPKPageControl *pageControl = [[RPKPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        case RPKCrouselPicturePageContolStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            break;
    }
    
    // 重设pagecontroldot图片
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
}


- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= _imagePathsGroup.count) {
        if (self.isInfiniteLoop) {
            targetIndex = targetIndex % _imagePathsGroup.count;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}


- (int)currentIndex
{
    if (_mainView.rpk_w == 0 || _mainView.rpk_h == 0) {
        return 0;
    }
    
    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_mainView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else {
        index = (_mainView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    if (index < self.imagePathsGroup.count) {
        return (int)index % self.imagePathsGroup.count;
    }
    else {
        return (int)self.imagePathsGroup.count - 1;
    }
}

- (void)clearCache
{
    [[self class] clearImagesCache];
}



#pragma mark - life circles

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    
    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
//        if (self.isInfiniteLoop) {
//            targetIndex = (int)(_totalItemsCount % _imagePathsGroup.count);
//        }else{
//            targetIndex = 0;
//        }
        // 第一眼显示的位置
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageControl = (RPKPageControl *)_pageControl;
        if (!(self.pageDotImage && self.currentPageDotImage && CGSizeEqualToSize(kRPKCrouselPicturePageControlDotSize, self.pageControlDotSize))) {
            pageControl.dotSize = self.pageControlDotSize;
        }
        size = [pageControl sizeForNumberOfPages:self.imagePathsGroup.count];
    } else {
        size = CGSizeMake(self.imagePathsGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    }
    CGFloat x = (self.rpk_w - size.width) * 0.5;
    if (self.pageControlAliment == RPKCrouselPicturePageContolAlimentRight) {
        x = self.mainView.rpk_w - size.width - 10;
    }
    CGFloat y = self.mainView.rpk_h - size.height - 10;
    
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageControl = (RPKPageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
    self.pageControl.frame  = pageControlFrame;
    self.pageControl.hidden = !_showPageControl;
    
    if (self.backgroundImageView) {
        self.backgroundImageView.frame = self.bounds;
    }
    
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}

#pragma mark - public actions

- (void)adjustWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < _imagePathsGroup.count) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - collectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    NSString *imagePath = self.imagePathsGroup[itemIndex];
    if (indexPath.row == 0 || indexPath.row == _totalItemsCount - 1) {
        if (self.firstIsVideo) {
            RPKVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoIdentifier forIndexPath:indexPath];
            cell.delegate   = self;
            cell.videoUrl   = imagePath;
            cell.isAotoPlay = self.isPlayFirstVideo;
            if (self.isPlayFirstVideo && indexPath.row == 0) {
                [cell start];
                self.pageControl.hidden = YES;
            }
            self.isPlayFirstVideo = NO;
            return cell;
        }
        else {
            RPKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageIdentifier forIndexPath:indexPath];
            if (!self.onlyDisplayText && [imagePath isKindOfClass:[NSString class]]) {
                if ([imagePath hasPrefix:@"http"]) {
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
                } else {
                    UIImage *image = [UIImage imageNamed:imagePath];
                    if (!image) {
                        [UIImage imageWithContentsOfFile:imagePath];
                    }
                    cell.imageView.image = image;
                }
            } else if (!self.onlyDisplayText && [imagePath isKindOfClass:[UIImage class]]) {
                cell.imageView.image = (UIImage *)imagePath;
            }
            
            if (_imageDescriptions.count && itemIndex < _imageDescriptions.count) {
                cell.title = _imageDescriptions[itemIndex];
            }
            
            if (!cell.hasConfigured) {
                cell.titleLabelBackgroundColor  = self.titleLabelBackgroundColor;
                cell.titleLabelHeight           = self.titleLabelHeight;
                cell.titleLabelTextAlignment    = self.titleLabelTextAlignment;
                cell.titleLabelTextColor        = self.titleLabelTextColor;
                cell.titleLabelTextFont         = self.titleLabelTextFont;
                cell.hasConfigured              = YES;
                cell.imageView.contentMode      = self.bannerImageViewContentMode;
                cell.clipsToBounds              = YES;
                cell.onlyDisplayText            = self.onlyDisplayText;
            }
            
            return cell;
        }
    }
    else {
        RPKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageIdentifier forIndexPath:indexPath];
        if (!self.onlyDisplayText && [imagePath isKindOfClass:[NSString class]]) {
            if ([imagePath hasPrefix:@"http"]) {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
            } else {
                UIImage *image = [UIImage imageNamed:imagePath];
                if (!image) {
                    [UIImage imageWithContentsOfFile:imagePath];
                }
                cell.imageView.image = image;
            }
        } else if (!self.onlyDisplayText && [imagePath isKindOfClass:[UIImage class]]) {
            cell.imageView.image = (UIImage *)imagePath;
        }
        
        if (_imageDescriptions.count && itemIndex < _imageDescriptions.count) {
            cell.title = _imageDescriptions[itemIndex];
        }
        
        if (!cell.hasConfigured) {
            cell.titleLabelBackgroundColor  = self.titleLabelBackgroundColor;
            cell.titleLabelHeight           = self.titleLabelHeight;
            cell.titleLabelTextAlignment    = self.titleLabelTextAlignment;
            cell.titleLabelTextColor        = self.titleLabelTextColor;
            cell.titleLabelTextFont         = self.titleLabelTextFont;
            cell.hasConfigured              = YES;
            cell.imageView.contentMode      = self.bannerImageViewContentMode;
            cell.clipsToBounds              = YES;
            cell.onlyDisplayText            = self.onlyDisplayText;
        }
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(crouselPicture:didSelectItemAtIndex:)]) {
        [self.delegate crouselPicture:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }
    if (self.clickItemOperationBlock) {
        self.clickItemOperationBlock([self pageControlIndexWithCurrentCellIndex:indexPath.item]);
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"contnetOffset3:%@", NSStringFromCGPoint(scrollView.contentOffset));
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.pageControl isKindOfClass:[RPKPageControl class]]) {
        RPKPageControl *pageControl = (RPKPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
    if (itemIndex+1 >= _totalItemsCount) {
        if (self.isInfiniteLoop) {
            itemIndex = itemIndex % _imagePathsGroup.count;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    
    if (scrollView.contentOffset.x < -30) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.imagePathsGroup.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"contnetOffset1:%@", NSStringFromCGPoint(scrollView.contentOffset));
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"contnetOffset2:%@", NSStringFromCGPoint(scrollView.contentOffset));
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:self.mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    if (self.firstIsVideo && indexOnPageControl == 0) {
        RPKVideoCollectionViewCell *cell = (RPKVideoCollectionViewCell *)[_mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexOnPageControl inSection:0]];
        [cell stop];
        cell.isAotoPlay = NO;
    }
//    else {
//        _pageControl.hidden = NO;
//    }
    _pageControl.hidden = NO;
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    
    if ([self.delegate respondsToSelector:@selector(crouselPicture:didScrollToIndex:)]) {
        [self.delegate crouselPicture:self didScrollToIndex:indexOnPageControl];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(indexOnPageControl);
    }
}

- (void)videoCollectionViewCell:(RPKVideoCollectionViewCell *)collectionCell didClickPlay:(UIButton *)play {
    _pageControl.hidden = YES;
    [self invalidateTimer];
}


/**
 清除图片缓存（此次升级后统一使用SDWebImage管理图片加载和缓存）
 */
+ (void)clearImagesCache
{
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
}


@end
