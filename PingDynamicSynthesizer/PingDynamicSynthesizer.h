//
//  PingDynamicSynthesizer.h
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@protocol DynamicPropertyDataSource<NSObject>

@optional
/**
 implement the method

 @return @[key1,key2,key3,.....];
 */
+ (NSArray *_Nullable)dynamicProperty;

@end

@interface PingDynamicSynthesizer : NSObject

/**
 dynamic synthesize the class's setter getter methods

 @param class_p the class need synthesize methods
 */
+ (void)dynamicPropertyClass:(nonnull Class<DynamicPropertyDataSource>)class_p;
@end
