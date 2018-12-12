//
//  UIView+RPK.h
//  RCarouselPicture
//
//  Created by RPK on 2018/11/24.
//  Copyright © 2018 RPK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RPKExtension)
@property (assign, nonatomic) CGFloat rpk_x;
@property (assign, nonatomic) CGFloat rpk_y;
@property (assign, nonatomic) CGFloat rpk_w;
@property (assign, nonatomic) CGFloat rpk_h;
@property (assign, nonatomic) CGSize  rpk_size;
@property (assign, nonatomic) CGPoint rpk_origin;
@property (assign, nonatomic, readonly) CGFloat rpk_max_x;
@property (assign, nonatomic, readonly) CGFloat rpk_max_y;
@end

NS_ASSUME_NONNULL_END
