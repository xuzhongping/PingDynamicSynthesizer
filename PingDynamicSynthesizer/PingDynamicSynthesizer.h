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
 Implementation the method

 @return @[key1,key2,key3,.....];
 */
+ (NSArray *_Nullable)dynamicProperty;

@end

@interface PingDynamicSynthesizer : NSObject

/**
 Dynamic synthesize the class's setter and getter methods

 @param class_p the class need synthesize methods
 */
+ (void)dynamicPropertyClass:(nonnull Class<DynamicPropertyDataSource>)class_p;
@end
