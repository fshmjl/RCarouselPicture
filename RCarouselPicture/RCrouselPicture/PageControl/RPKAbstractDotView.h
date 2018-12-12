//
//  RPKAbstractDotView.h
//  RPKPageControl
//
//  Created by RPKnguy Aladenise on 2015-01-22.
//  Copyright (c) 2015 RPKnguy Aladenise. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RPKAbstractDotView : UIView


/**
 *  A method call let view know which state appearance it should RPKke. Active meaning it's current page. Inactive not the current page.
 *
 *  @param active BOOL to tell if view is active or not
 */
- (void)changeActivityState:(BOOL)active;


@end

