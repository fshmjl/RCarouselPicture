//
//  RPKVideoCollectionViewCell.h
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPKVideoCollectionViewCell;
@protocol RPKVideoCollectionViewCellDelegate <NSObject>

- (void)videoCollectionViewCell:(RPKVideoCollectionViewCell *)collectionCell didClickPlay:(UIButton *)play;


@end

NS_ASSUME_NONNULL_BEGIN

@interface RPKVideoCollectionViewCell : UICollectionViewCell
// 是否自动播放
@property (nonatomic, assign) BOOL isAotoPlay;
// 是否处于播放状态
@property (nonatomic, assign) BOOL isPlay;
// 视频播放地址 或 图片地址
@property (nonatomic, strong) NSString *videoUrl;

@property(nonatomic, assign) id<RPKVideoCollectionViewCellDelegate> delegate;

/**
 开始播放
 */
- (void)start;

/**
 暂停播放
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
