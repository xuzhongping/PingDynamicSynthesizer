//
//  PingDynamicSynthesizer.m
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "PingDynamicSynthesizer.h"
#import "PingWeakHelper.h"

#define NONATOMIC   @"N"
#define ATOMIC      @""
#define STRONG      @"&"
#define COPY        @"C"
#define WEAK        @"W"

#define OBJC_ASSOCIATION_WEAK_NONATOMIC 01555
#define OBJC_ASSOCIATION_WEAK           01556
#define OBJC_ASSOCIATION_UNDEFINE       01557

@implementation PingDynamicSynthesizer


// static inline methods

static inline SEL synthesizeSetSel(NSString *name){
    NSString *setFirstChar = [name substringToIndex:1];
    setFirstChar = [setFirstChar uppercaseString];
    NSString *setLastChars = [name substringFromIndex:1];
    NSString *selName = [NSString stringWithFormat:@"set%@%@:",setFirstChar,setLastChars];
    return NSSelectorFromString(selName);
}

static inline SEL synthesizeGetSel(NSString *name){
    return NSSelectorFromString(name);
}

static inline uintptr_t analyzePolicy(NSString *pty_att){
    NSInteger att_length = pty_att.length;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_UNDEFINE;
    if ([[pty_att substringFromIndex:(att_length - 1)] isEqualToString:NONATOMIC]) {
        if ([pty_att rangeOfString:@"&,"].length) {
            policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        }else if ([pty_att rangeOfString:@"C,"].length){
            policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
        }else if ([pty_att rangeOfString:@"W,"].length){
            policy = OBJC_ASSOCIATION_WEAK_NONATOMIC;
        }
    }else{
        if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:STRONG]) {
            policy = OBJC_ASSOCIATION_RETAIN;
        }else if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:COPY]){
            policy = OBJC_ASSOCIATION_COPY;
        }else if ([[pty_att substringFromIndex:att_length - 1] isEqualToString:WEAK]){
            policy = OBJC_ASSOCIATION_WEAK;
        }
    }
    return policy;
}

static inline void * getAssociatedObjectKey(SEL setSel){
    NSString *setSelName = NSStringFromSelector(setSel);
    setSelName = [setSelName substringFromIndex:3];
    NSString  *firstGetSelName = [setSelName substringToIndex:1];
    firstGetSelName = [firstGetSelName lowercaseString];
    NSString *lastGetSelName = [setSelName substringFromIndex:1];
    lastGetSelName = [lastGetSelName stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *getSelName = [NSString stringWithFormat:@"%@%@",firstGetSelName,lastGetSelName];
    return (void *)NSSelectorFromString(getSelName);
}

// static methods

static void dispenseSetGetImplementation(uintptr_t policy, SEL setSel,SEL getSel,__nonnull Class class_p){
    switch (policy) {
        case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_RETAIN_NONATOMIC, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
        }
            break;
        case OBJC_ASSOCIATION_COPY_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_COPY_NONATOMIC, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
        }
            break;
        case OBJC_ASSOCIATION_WEAK_NONATOMIC:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_WEAK_NONATOMIC, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
        }
            break;
        case OBJC_ASSOCIATION_RETAIN:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_RETAIN, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
        }
            break;
        case OBJC_ASSOCIATION_COPY:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_COPY, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
        }
            break;
        case OBJC_ASSOCIATION_WEAK:
        {
            class_addMethod(class_p, setSel, (IMP)dynamicSetMethod_OBJC_ASSOCIATION_WEAK, "v@:@");
            class_addMethod(class_p, getSel, (IMP)dynamicGetMethod_OBJC_ASSOCIATION_AUTO, "@@:");
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
void dynamicSetMethod_OBJC_ASSOCIATION_RETAIN_NONATOMIC(id _self,SEL _cmd,id value){
    objc_setAssociatedObject(_self, getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void dynamicSetMethod_OBJC_ASSOCIATION_COPY_NONATOMIC(id _self,SEL _cmd,id value){
    objc_setAssociatedObject(_self, getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

void dynamicSetMethod_OBJC_ASSOCIATION_WEAK_NONATOMIC(id _self,SEL _cmd,id value){
    objc_setAssociatedObject([PingWeakHelper weakHelper:_self], getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void dynamicSetMethod_OBJC_ASSOCIATION_RETAIN(id _self,SEL _cmd,id value){
    objc_setAssociatedObject(_self, getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN);
}


void dynamicSetMethod_OBJC_ASSOCIATION_COPY(id _self,SEL _cmd,id value){
    objc_setAssociatedObject(_self, getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_COPY);
}

void dynamicSetMethod_OBJC_ASSOCIATION_WEAK(id _self,SEL _cmd,id value){
    objc_setAssociatedObject([PingWeakHelper weakHelper:_self], getAssociatedObjectKey(_cmd), value, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - DynamicGet
id dynamicGetMethod_OBJC_ASSOCIATION_AUTO(id _self,SEL _cmd){
    return  objc_getAssociatedObject(_self, _cmd);
}


+ (void)dynamicPropertyClass:(Class<DynamicPropertyDataSource>)class_p{
    
    class_p = [class_p class];
    
    if (![class_p conformsToProtocol:@protocol(DynamicPropertyDataSource)]) {
        NSAssert(false, @"no conforms DynamicPropertyDataSource");
        return;
    }
    
    if (![class_p  respondsToSelector:@selector(dynamicProperty)]) {
        NSAssert(false, @"no implement dynamicProperty");
        return;
    }
    
    NSArray *rawPropertys = [class_p dynamicProperty];
    if (!rawPropertys || rawPropertys.count == 0) {
        return;
    }
    

    unsigned int pty_c = 0;
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableArrayRef raw_ptys = CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
    objc_property_t *ptys = class_copyPropertyList(class_p, &pty_c);
    for (int i = 0; i < pty_c; i++) {
        objc_property_t pty = ptys[i];
        NSString *ptyName = [NSString stringWithCString:property_getName(pty) encoding:NSUTF8StringEncoding];
        for (NSString *raw_ptyName in rawPropertys) {
            if ([raw_ptyName isEqualToString:ptyName]) {
                CFArrayAppendValue(raw_ptys, pty);
                break;
            }
        }
    }
    
    CFIndex raw_pty_c = CFArrayGetCount(raw_ptys);
    for (int i = 0; i < raw_pty_c; i++) {
        objc_property_t raw_pty = (objc_property_t)CFArrayGetValueAtIndex(raw_ptys, i);
        const char  *att_c =  property_getAttributes(raw_pty);
        const char  *name_c = property_getName(raw_pty);
        NSString *att = [NSString stringWithCString:att_c encoding:NSUTF8StringEncoding];
        NSString *name = [NSString stringWithCString:name_c encoding:NSUTF8StringEncoding];
        SEL setSel = synthesizeSetSel(name);
        SEL getSel = synthesizeGetSel(name);
        uintptr_t policy = analyzePolicy(att);
        if (policy == OBJC_ASSOCIATION_UNDEFINE) {
            NSString *description = [NSString stringWithFormat:@"%@'%@' nonsupport dynamic synthesize property",NSStringFromClass(class_p),name];
            NSAssert(false, description);
            continue;
        }
        dispenseSetGetImplementation(policy, setSel, getSel, class_p);
    }
}

@end
