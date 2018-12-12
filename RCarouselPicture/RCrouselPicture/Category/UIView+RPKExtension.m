//
//  UIView+RPK.m
//  RCarouselPicture
//
//  Created by RPK on 2018/11/24.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "UIView+RPKExtension.h"

@implementation UIView (RPKExtension)
- (void)setRpk_x:(CGFloat)rpk_x
{
    CGRect frame = self.frame;
    frame.origin.x = rpk_x;
    self.frame = frame;
}

- (CGFloat)rpk_x
{
    return self.frame.origin.x;
}

- (void)setRpk_y:(CGFloat)rpk_y
{
    CGRect frame = self.frame;
    frame.origin.y = rpk_y;
    self.frame = frame;
}

- (CGFloat)rpk_y
{
    return self.frame.origin.y;
}

- (void)setRpk_w:(CGFloat)rpk_w
{
    CGRect frame = self.frame;
    frame.size.width = rpk_w;
    self.frame = frame;
}

- (CGFloat)rpk_w
{
    return self.frame.size.width;
}

- (void)setRpk_h:(CGFloat)rpk_h
{
    CGRect frame = self.frame;
    frame.size.height = rpk_h;
    self.frame = frame;
}

- (CGFloat)rpk_h
{
    return self.frame.size.height;
}

- (void)setRpk_size:(CGSize)rpk_size
{
    CGRect frame = self.frame;
    frame.size = rpk_size;
    self.frame = frame;
}

- (CGSize)rpk_size
{
    return self.frame.size;
}

- (void)setRpk_origin:(CGPoint)rpk_origin
{
    CGRect frame = self.frame;
    frame.origin = rpk_origin;
    self.frame = frame;
}

- (CGPoint)rpk_origin
{
    return self.frame.origin;
}

- (CGFloat)rpk_max_x {
    return self.rpk_x + self.rpk_w;
}

- (CGFloat)rpk_max_y {
    return self.rpk_y + self.rpk_h;
}

@end
