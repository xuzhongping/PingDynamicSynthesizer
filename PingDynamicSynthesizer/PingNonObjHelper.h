//
//  PingNonObjHelper.h
//  PingDynamicSynthesizerDemo
//
//  Created by 徐仲平 on 2019/1/30.
//  Copyright © 2019 徐仲平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define     ping_variable(type) type _##type##V

typedef long long _ping_llong;
typedef unsigned char _ping_uchar;
typedef unsigned short _ping_ushort;
typedef unsigned int _ping_uint;
typedef unsigned long _ping_ulong;
typedef unsigned long long _ping_ullong;
typedef char * _ping_str;
typedef void * _ping_ptr;


@interface PingNonObjHelper : NSObject
{
    @public
    ping_variable(BOOL);
    ping_variable(char);
    ping_variable(short);
    ping_variable(int);
    ping_variable(long);
    ping_variable(float);
    ping_variable(double);
    ping_variable(_ping_llong);
    
    ping_variable(_ping_uchar);
    ping_variable(_ping_ushort);
    ping_variable(_ping_uint);
    ping_variable(_ping_ulong);
    ping_variable(_ping_ullong);
    ping_variable(_ping_str);
    ping_variable(_ping_ptr);
}
@end

NS_ASSUME_NONNULL_END
