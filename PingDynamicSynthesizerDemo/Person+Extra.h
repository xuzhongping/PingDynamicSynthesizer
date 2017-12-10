//
//  Person+Extra.h
//  PingDynamicSynthesizerDemo
//
//  Created by JungHsu on 2017/12/10.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "Person.h"
#import "PingDynamicSynthesizer.h"

@interface Person (Extra)<DynamicPropertyDataSource>
@property (nonatomic, copy,readonly) NSString *name;
//@property (nonatomic,assign)NSInteger ss;
@end
