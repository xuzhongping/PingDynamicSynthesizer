//
//  PingDynamicSynthesizer.m
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "PingDynamicSynthesizer.h"
#import "PingWeakHelper.h"

#define PingDynamicSynthesizerInquiry @"PingDynamicSynthesizerInquiry"

// type encode
#define PING_NONATOMIC_ENCODE   @"N"
#define PING_ATOMIC_ENCODE      @""
#define PING_STRONG_ENCODE      @"&"
#define PING_COPY_ENCODE        @"C"
#define PING_WEAK_ENCODE        @"W"
#define PING_DYNAMIC_ENCODE     @"D"
#define PING_UNSAFE_UNRETAIN_ENCODE    @""


// define policy magic
#define OBJC_ASSOCIATION_WEAK_NONATOMIC 01555
#define OBJC_ASSOCIATION_WEAK           01556
#define OBJC_ASSOCIATION_UNDEFINE       01557

// method encode
#define SET_METHOD_ENCODE "v@:@"
#define GET_METHOD_ENCODE "@@:"

/*******************************************Macro************************************************/

@implementation PingDynamicSynthesizer

//static CFDictionaryRef


// static inline methods

static inline SEL _ping_synthesize_setsel(NSString *name){
    NSString *setFirstChar = [name substringToIndex:1];
    setFirstChar = [setFirstChar uppercaseString];
    NSString *setLastChars = [name substringFromIndex:1];
    NSString *selName = [NSString stringWithFormat:@"set%@%@:",setFirstChar,setLastChars];
    return NSSelectorFromString(selName);
}

static inline SEL _ping_synthesize_getSel(NSString *name){
    return NSSelectorFromString(name);
}

static inline uintptr_t _ping_analyze_policy(NSString *pty_att){
//    NSLog(@"%@\n",pty_att);
    NSInteger att_length = pty_att.length;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;
    if ([[pty_att substringFromIndex:(att_length - 1)] isEqualToString:PING_NONATOMIC_ENCODE]) {
        if ([pty_att rangeOfString:@"&,"].length) {
            policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        }else if ([pty_att rangeOfString:@"C,"].length){
            policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
        }else if ([pty_att rangeOfString:@"W,"].length){
            policy = OBJC_ASSOCIATION_WEAK_NONATOMIC;
        }
    }else{
        if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:PING_STRONG_ENCODE]) {
            policy = OBJC_ASSOCIATION_RETAIN;
        }else if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:PING_COPY_ENCODE]){
            policy = OBJC_ASSOCIATION_COPY;
        }else if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:PING_WEAK_ENCODE]){
            policy = OBJC_ASSOCIATION_WEAK;
        }
    }
    return policy;
}


/**
 The func serve setter SEL exchange to getter for objectKey,
 when the func input a getter SEL,not exchange.
 */
static inline void * _ping_get_associated_objectKey(SEL setSel){
    NSString *setSelName = NSStringFromSelector(setSel);
    if (![setSelName containsString:@"set"]) {
        return (void *)NSSelectorFromString(setSelName);
    }
    setSelName = [setSelName substringFromIndex:3];
    NSString  *firstGetSelName = [setSelName substringToIndex:1];
    firstGetSelName = [firstGetSelName lowercaseString];
    NSString *lastGetSelName = [setSelName substringFromIndex:1];
    lastGetSelName = [lastGetSelName stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *getSelName = [NSString stringWithFormat:@"%@%@",firstGetSelName,lastGetSelName];
    return (void *)NSSelectorFromString(getSelName);
}

// static methods

// 此处可以判断传进来的类型，然后根据类型来生成
static void _ping_dispense_setget_implementation(uintptr_t policy,
                                                 SEL setSel,SEL getSel,
                                                 __nonnull Class class_p){
    switch (policy) {
        case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN_NONATOMIC, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK,GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_COPY_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY_NONATOMIC, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_WEAK_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK_NONATOMIC, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_RETAIN:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_COPY:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_WEAK:
        {
            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK, SET_METHOD_ENCODE);
            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, GET_METHOD_ENCODE);
        }
            break;
        case OBJC_ASSOCIATION_ASSIGN:
        {
//            class_addMethod(class_p, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_ASSIGN, SET_METHOD_ENCODE);
//            class_addMethod(class_p, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, GET_METHOD_ENCODE);
            class_addMethod(class_p, setSel, (IMP)test,SET_METHOD_ENCODE);
        }
            break;
            
        default:
        {
            NSCAssert(false, @"can't synthesize setter getter methods");
        }
            break;
    }
}

#pragma mark - DynamicSet
static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN_NONATOMIC(id _self,
                                                                          SEL _cmd,
                                                                          id value){
    objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY_NONATOMIC(id _self,
                                                                        SEL _cmd,
                                                                        id value){
    objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK_NONATOMIC(id _self,
                                                                        SEL _cmd,
                                                                        id value){
    objc_setAssociatedObject(_self,  _ping_get_associated_objectKey(_cmd), [PingWeakHelper weakTarget:value], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN(id _self,
                                                                SEL _cmd,
                                                                id value){
    objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN);
}


static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY(id _self,
                                                              SEL _cmd,
                                                              id value){
    objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, OBJC_ASSOCIATION_COPY);
}

static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK(id _self,
                                                              SEL _cmd,
                                                              id value){
    objc_setAssociatedObject(_self,  _ping_get_associated_objectKey(_cmd), [PingWeakHelper weakTarget:value], OBJC_ASSOCIATION_RETAIN);
}

static void _ping_dynamic_setter_method_OBJC_ASSOCIATION_ASSIGN(id _self,
                                                                SEL _cmd,
                                                                id value){
    objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, OBJC_ASSOCIATION_ASSIGN);
}

static void test(id _self,SEL _cmd,void *value){
    NSUInteger a = (NSInteger)value;
    NSLog(@"%x",a);
}


#pragma mark - DynamicGet
static id _ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK(id _self,
                                                                    SEL _cmd){
    return  objc_getAssociatedObject(_self, _cmd);
}

static id _ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK(id _self,
                                                            SEL _cmd){
    PingWeakHelper *helper = (PingWeakHelper *)objc_getAssociatedObject(_self, _cmd);
    
    // lazy set to nil
    if (!objc_getAssociatedObject(_self, _ping_get_associated_objectKey(_cmd))) {
        return nil;
    }
    
    if ([helper getTarget] == nil) {
        objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return nil;
    }
    return [helper getTarget];
}


__attribute__((constructor)) static void _ping_auto_synthesize_entry(){
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    BOOL is_auto = [info[PingDynamicSynthesizerInquiry] boolValue];
    if (is_auto) {
        unsigned int class_count = 0;
        Class *class_list = objc_copyClassList(&class_count);
        unsigned int i = 0;
        while (i < class_count) {
            Class cls = class_list[i];
            if (class_conformsToProtocol(cls, @protocol(DynamicPropertyProtocol))) {
                [PingDynamicSynthesizer ping_dynamicProperty:cls];
            }
            i++;
        }
    }
    
}

/**
 Dynamic synthesize the class's setter and getter methods
 
 @param cls the class need synthesize methods
 */
+ (void)ping_dynamicProperty:(nonnull Class<DynamicPropertyProtocol>)cls{
    NSParameterAssert(cls);
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableArrayRef raw_ptys = CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
    if (!class_respondsToSelector(cls, @selector(dynamicPropertyKeys))) {
        unsigned int pty_count = 0;
        objc_property_t *ptys =  class_copyPropertyList(cls, &pty_count);
        for (int i = 0; i < pty_count; i++) {
            objc_property_t pty = ptys[i];
            const char  *name_c = property_getName(pty);
            NSString *name = [NSString stringWithCString:name_c encoding:NSUTF8StringEncoding];
            SEL setSel = _ping_synthesize_setsel(name);
            SEL getSel = _ping_synthesize_getSel(name);
            Method setMethod = class_getInstanceMethod(cls, setSel);
            Method getMethod = class_getInstanceMethod(cls, getSel);
            if (!(setMethod || getMethod)) {
                const char  *att_c =  property_getAttributes(pty);
                if (att_c[0] == 'T' && att_c[1] == '@') {
                    CFArrayAppendValue(raw_ptys, pty);
                }
            }
        }
    }else{
        NSArray *rawPropertys = [cls dynamicPropertyKeys];
        if (!rawPropertys || rawPropertys.count == 0) {
            return;
        }
        unsigned int pty_count = 0;
        objc_property_t *ptys = class_copyPropertyList(cls, &pty_count);
        for (int i = 0; i < pty_count; i++) {
            objc_property_t pty = ptys[i];
            NSString *ptyName = [NSString stringWithCString:property_getName(pty) encoding:NSUTF8StringEncoding];
            for (NSString *raw_ptyName in rawPropertys) {
                if ([raw_ptyName isEqualToString:ptyName]) {
                    CFArrayAppendValue(raw_ptys, pty);
                    break;
                }
            }
        }
    }

    CFIndex raw_pty_count = CFArrayGetCount(raw_ptys);
    for (int i = 0; i < raw_pty_count; i++) {
        objc_property_t raw_pty = (objc_property_t)CFArrayGetValueAtIndex(raw_ptys, i);
        const char  *att_c =  property_getAttributes(raw_pty);
        const char  *name_c = property_getName(raw_pty);
        NSString *att = [NSString stringWithCString:att_c encoding:NSUTF8StringEncoding];
        NSString *name = [NSString stringWithCString:name_c encoding:NSUTF8StringEncoding];
        SEL setSel = _ping_synthesize_setsel(name);
        SEL getSel = _ping_synthesize_getSel(name);
        uintptr_t policy = _ping_analyze_policy(att);
        _ping_dispense_setget_implementation(policy, setSel, getSel, cls);
    }
    CFRelease(raw_ptys);
}

@end
