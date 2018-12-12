//
//  RPKAbstractDotView.m
//  RPKPageControl
//
//  Created by RPKnguy Aladenise on 2015-01-22.
//  Copyright (c) 2015 RPKnguy Aladenise. All rights reserved.
//

#import "RPKAbstractDotView.h"


@implementation RPKAbstractDotView


- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in %@", NSStringFromSelector(_cmd), self.class]
                                 userInfo:nil];
}


- (void)changeActivityState:(BOOL)active
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in %@", NSStringFromSelector(_cmd), self.class]
                                 userInfo:nil];
}

@end
