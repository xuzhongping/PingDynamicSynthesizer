//
//  Person+Extra.h
//  PingDynamicSynthesizerDemo
//
//  Created by JungHsu on 2017/12/10.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "Person.h"
#import "PingDynamicSynthesizer.h"

@interface Person (Extra)<DynamicPropertyProtocol>
@property (nonatomic,   copy) NSString  *name;
@property (nonatomic, strong) NSObject  *ss;
@end
