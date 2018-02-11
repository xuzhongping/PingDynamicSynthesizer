//
//  PingDynamicSynthesizer.h
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>

/**
 *  You need to add the following fields in your 'info.plist' and set the value:
 *  PingDynamicSynthesizerInquiry:(BOOL)
 */

@protocol DynamicPropertyProtocol<NSObject>

@optional
/**
 Implementation the method

 @return @[key1,key2,key3,.....];
 */
+ (NSArray *_Nullable)dynamicPropertyKeys;

@end

@interface PingDynamicSynthesizer : NSObject
+ (void)ping_dynamicProperty:(nonnull Class<DynamicPropertyProtocol>)cls;
@end
