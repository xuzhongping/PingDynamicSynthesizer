//
//  PingCopyFizz.m
//  PingDynamicSynthesizerDemoTests
//
//  Created by 徐仲平 on 2019/3/25.
//  Copyright © 2019 徐仲平. All rights reserved.
//

#import "PingCopyFizz.h"

@implementation PingCopyFizz

- (id)copyWithZone:(NSZone *)zone{
    return [[PingCopyFizz alloc]init];
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return [[PingCopyFizz alloc]init];
}
@end
