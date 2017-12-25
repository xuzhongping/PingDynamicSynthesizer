//
//  PingDynamicSynthesizer.h
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@protocol DynamicPropertyProtocol<NSObject>

@optional
/**
 Implementation the method

 @return @[key1,key2,key3,.....];
 */
+ (NSArray *_Nullable)dynamicPropertyKeys;

@end

@interface PingDynamicSynthesizer : NSObject

@end
