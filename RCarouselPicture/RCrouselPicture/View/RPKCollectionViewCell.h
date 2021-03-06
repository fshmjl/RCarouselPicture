//
//  RPKCollectionViewCell.h
//  RCarouselPicture
//
//  Created by RPK on 2018/11/24.
//  Copyright © 2018 RPK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPKCollectionViewCell : UICollectionViewCell
@property(weak, nonatomic)   UIImageView *imageView;
@property(copy, nonatomic)   NSString *title;

@property(nonatomic, strong) UIColor *titleLabelTextColor;
@property(nonatomic, strong) UIFont *titleLabelTextFont;
@property(nonatomic, strong) UIColor *titleLabelBackgroundColor;
@property(nonatomic, assign) CGFloat titleLabelHeight;
@property(nonatomic, assign) NSTextAlignment titleLabelTextAlignment;

@property(nonatomic, assign) BOOL hasConfigured;

/** 只展示文字轮播 */
@property(nonatomic, assign) BOOL onlyDisplayText;

@end

NS_ASSUME_NONNULL_END
