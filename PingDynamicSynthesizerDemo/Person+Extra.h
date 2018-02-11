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
@property (nonatomic,unsafe_unretained)id safe;
@property (nonatomic,assign)id ID;
@property (nonatomic,assign)CGFloat fnumber;
@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign)CGRect frame;
@property (nonatomic,assign)CGPoint point;
@property (nonatomic,assign)double dnumber;
@property (nonatomic,assign)int inumber;
@property (nonatomic,assign)NSInteger interNumber;
@property (nonatomic,assign)long longNumber;
@property (nonatomic,assign)long long llongNumber;
@end
