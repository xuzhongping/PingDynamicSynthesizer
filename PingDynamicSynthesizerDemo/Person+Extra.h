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
@property (atomic, strong) NSObject  *ss;
@property (nonatomic, assign) NSInteger abc;


@end
