//
//  PingDynamicSynthesizer.m
//  carchat_ios
//
//  Created by JungHsu on 2017/12/4.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "PingDynamicSynthesizer.h"
#import "PingWeakHelper.h"
#import "PingNonObjHelper.h"

#if !__has_feature(objc_arc)
#error
#endif

#define _PING_DYNAMIC_SETTER_METHOD(policy) \
static void _ping_dynamic_setter_method_##policy(id _self, \
SEL _cmd,   \
id value){  \
objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), value, policy);    \
}

#define _PING_DYNAMIC_GETTER_METHOD \
static id _ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK(id _self, \
SEL _cmd){  \
return  objc_getAssociatedObject(_self, _cmd);  \
}

#define _PING_DYNAMIC_SETTER_WEAK_METHOD(policy) \
static void _ping_dynamic_setter_method_##policy(id _self,   \
SEL _cmd,   \
id value){  \
if (policy == OBJC_ASSOCIATION_WEAK){ \
objc_setAssociatedObject(_self,  _ping_get_associated_objectKey(_cmd), [PingWeakHelper weakTarget:value],   \
                         OBJC_ASSOCIATION_RETAIN);   \
}else{  \
objc_setAssociatedObject(_self,  _ping_get_associated_objectKey(_cmd), [PingWeakHelper weakTarget:value],   \
                         OBJC_ASSOCIATION_RETAIN_NONATOMIC);   \
}   \
}

#define _PING_DYNAMIC_GETTER_WEAK_METHOD    \
static id _ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK(id _self,   \
SEL _cmd){  \
PingWeakHelper *helper = (PingWeakHelper *)objc_getAssociatedObject(_self, _cmd);   \
\
if (!objc_getAssociatedObject(_self, _ping_get_associated_objectKey(_cmd))) {   \
return nil; \
}   \
\
if ([helper getTarget] == nil) {    \
objc_setAssociatedObject(_self, _ping_get_associated_objectKey(_cmd), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
return nil; \
}   \
return [helper getTarget];  \
}

#define _PING_DYNAMIC_NON_OBJ_SETTER_METHOD(policy,type) \
static void _ping_dynamic_setter_method_non_obj_##policy##_##type(id _self,  \
SEL _cmd, \
type value){    \
PingNonObjHelper *nonObj = [[PingNonObjHelper alloc]init];  \
nonObj->_var._##type##V = value;   \
objc_setAssociatedObject(_self,  _ping_get_associated_objectKey(_cmd), nonObj,  \
policy);  \
}

#define _PING_DYNAMIC_NON_OBJ_GETTER_METHOD(type) \
static type _ping_dynamic_getter_method_non_obj_##type(id _self,  \
SEL _cmd){    \
if (!objc_getAssociatedObject(_self, _ping_get_associated_objectKey(_cmd))) {   \
return (type)0; \
}   \
PingNonObjHelper *nonObj = (PingNonObjHelper *)objc_getAssociatedObject(_self, _cmd);   \
\
return nonObj->_var._##type##V;  \
}


#define PingDynamicSynthesizerInquiry @"PingDynamicSynthesizerInquiry"

// type encode
#define PING_NONATOMICencode   @"N"
#define PING_ATOMICencode      @""
#define PING_STRONGencode      @"&"
#define PING_COPYencode        @"C"
#define PING_WEAKencode        @"W"
#define PING_DYNAMICencode     @"D"
#define PING_UNSAFE_UNRETAINencode    @""


// define policy magic
#define OBJC_ASSOCIATION_WEAK_NONATOMIC 0x613
#define OBJC_ASSOCIATION_WEAK           0x614
#define OBJC_ASSOCIATION_UNDEFINE       0x615

// obj method encode
#define SET_METHOD_OBJencode "v@:@"
#define GET_METHOD_OBJencode "@@:"



/*******************************************Macro************************************************/

@implementation PingDynamicSynthesizer

static char encodeMap[128];

// static inline methods
static void _ping_createencode_map(){
    encodeMap[(uint8_t)*@encode(BOOL)] = 1;
    encodeMap[(uint8_t)*@encode(char)] = 1;
    encodeMap[(uint8_t)*@encode(short)] = 1;
    encodeMap[(uint8_t)*@encode(int)] = 1;
    encodeMap[(uint8_t)*@encode(long)] = 1;
    encodeMap[(uint8_t)*@encode(long long)] = 1;
    encodeMap[(uint8_t)*@encode(float)] = 1;
    encodeMap[(uint8_t)*@encode(double)] = 1;
    encodeMap[(uint8_t)*@encode(unsigned char)] = 1;
    encodeMap[(uint8_t)*@encode(unsigned short)] = 1;
    encodeMap[(uint8_t)*@encode(unsigned int)] = 1;
    encodeMap[(uint8_t)*@encode(unsigned long)] = 1;
    encodeMap[(uint8_t)*@encode(unsigned long long)] = 1;
    encodeMap[(uint8_t)*@encode(void *)] = 1;
    encodeMap[(uint8_t)*@encode(char *)] = 1;
    encodeMap['@'] = 1;
    encodeMap[(uint8_t)*@encode(Class)] = 1;
}

static inline char * _ping_set_method_encode(char *code){
    char *set_methodencode = NULL;
    if (code[0] == '^' && code[1] == 'v') {
        char newencode[5] = "v@:^v";
        set_methodencode = newencode;
    }else{
        char newencode[4] = "v@:*";
        newencode[3] = code[0];
        set_methodencode = newencode;
    }
    return set_methodencode;
}

static inline char * _ping_get_method_encode(char *code){
    char *get_methodencode = NULL;
    if (code[0] == '^' && code[1] == 'v') {
        char new_ncode[4] = "^v@:";
        get_methodencode = new_ncode;
    }else{
        char newencode[3] = "v@:";
        newencode[0] = code[0];
        get_methodencode = newencode;
    }
    return get_methodencode;
}

static inline SEL _ping_synthesize_setsel(NSString *name){
    NSString *prefixStr = [name substringToIndex:1];
    prefixStr = [prefixStr uppercaseString];
    NSString *suffixStr = [name substringFromIndex:1];
    NSString *selName = [NSString stringWithFormat:@"set%@%@:",prefixStr,suffixStr];
    return NSSelectorFromString(selName);
}

static inline SEL _ping_synthesize_getSel(NSString *name){
    return NSSelectorFromString(name);
}

static inline uintptr_t _ping_analyze_policy(NSString *attr){
    NSInteger attrLen = attr.length;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;
    if ([[attr substringFromIndex:(attrLen - 1)] isEqualToString:PING_NONATOMICencode]) {
        if ([attr rangeOfString:@"&,"].length) {
            policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        }else if ([attr rangeOfString:@"C,"].length){
            policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
        }else if ([attr rangeOfString:@"W,"].length){
            policy = OBJC_ASSOCIATION_WEAK_NONATOMIC;
        }
    }else{
        if ([[attr substringFromIndex:attrLen - 1] isEqualToString:PING_STRONGencode]) {
            policy = OBJC_ASSOCIATION_RETAIN;
        }else if ([[attr substringFromIndex:attrLen - 1] isEqualToString:PING_COPYencode]){
            policy = OBJC_ASSOCIATION_COPY;
        }else if ([[attr substringFromIndex:attrLen - 1] isEqualToString:PING_WEAKencode]){
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
    NSString  *prefixStr = [setSelName substringToIndex:1];
    prefixStr = [prefixStr lowercaseString];
    NSString *suffixStr = [setSelName substringFromIndex:1];
    suffixStr = [suffixStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *getSelName = [NSString stringWithFormat:@"%@%@",prefixStr,suffixStr];
    return (void *)NSSelectorFromString(getSelName);
}

// static methods

static void _ping_dispense_setget_implementation(uintptr_t policy,
                                                 SEL setSel,SEL getSel,
                                                 __nonnull Class class,char *encode){
    
#define _PING_DYNAMIC_NONOBJ_SETTER_IMP(policy,type)   \
(IMP)_ping_dynamic_setter_method_non_obj_##policy##_##type

#define _PING_DYNAMIC_NONOBJ_GETTER_IMP(type)   \
(IMP)_ping_dynamic_getter_method_non_obj_##type
    
    encode ++;
    if (encode[0] == '@' || encode[0] == '#') {
        switch (policy) {
            case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK,_ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_COPY_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY_NONATOMIC, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_WEAK_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK_NONATOMIC, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, _ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_RETAIN:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_COPY:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_WEAK:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, _ping_get_method_encode(encode));
            }
                break;
            case OBJC_ASSOCIATION_ASSIGN:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_ASSIGN, _ping_set_method_encode(encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(encode));
            }
                break;
                
            default:
            {
                NSCAssert(false, @"can't synthesize setter getter methods");
            }
                break;
        }
    }
    else if (encode[0] == @encode(BOOL)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,BOOL), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,BOOL), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(BOOL), _ping_get_method_encode(encode));
    }
    else if (encode[0] == @encode(char)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,char), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,char), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(char), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(char *)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_str), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_str), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_str), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(short)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,short), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,short), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(short), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(int)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,int), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,int), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(int), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(long)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,long), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,long), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(long), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(long long)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_llong), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_llong), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_llong), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(float)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,float), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,float), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(float), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(double)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,double), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,double), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(double), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(unsigned char)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_uchar), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_uchar), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_uchar), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(unsigned short)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ushort), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ushort), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ushort), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(unsigned int)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_uint), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_uint), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_uint), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(unsigned long)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ulong), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ulong), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ulong), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(unsigned long long)[0]){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ullong), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ullong), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ullong), _ping_get_method_encode(encode));
    }else if (encode[0] == @encode(void *)[0] && encode[1] == 'v'){
        if (encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ptr), _ping_set_method_encode(encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ptr), _ping_set_method_encode(encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ptr), _ping_get_method_encode(encode));
    }
}




#pragma mark - DynamicSet

_PING_DYNAMIC_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC)
_PING_DYNAMIC_SETTER_METHOD(OBJC_ASSOCIATION_COPY_NONATOMIC)
_PING_DYNAMIC_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN)
_PING_DYNAMIC_SETTER_METHOD(OBJC_ASSOCIATION_COPY)
_PING_DYNAMIC_SETTER_METHOD(OBJC_ASSOCIATION_ASSIGN)
_PING_DYNAMIC_SETTER_WEAK_METHOD(OBJC_ASSOCIATION_WEAK_NONATOMIC)
_PING_DYNAMIC_SETTER_WEAK_METHOD(OBJC_ASSOCIATION_WEAK)

_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, BOOL)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, char)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, short)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, int)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, long)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_llong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, float)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, double)

_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_uchar)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_ushort)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_uint)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_ulong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_ullong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_str)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_ptr)

_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, BOOL)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, char)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, short)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, int)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, long)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_llong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, float)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, double)

_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_uchar)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_ushort)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_uint)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_ulong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_ullong)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_str)
_PING_DYNAMIC_NON_OBJ_SETTER_METHOD(OBJC_ASSOCIATION_RETAIN, _ping_ptr)




#pragma mark - DynamicGet

_PING_DYNAMIC_GETTER_METHOD
_PING_DYNAMIC_GETTER_WEAK_METHOD

_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(BOOL)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(char)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(short)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(int)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(long)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_llong)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(float)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(double)

_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_uchar)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_ushort)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_uint)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_ulong)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_ullong)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_str)
_PING_DYNAMIC_NON_OBJ_GETTER_METHOD(_ping_ptr)


__attribute__((constructor)) static void _ping_auto_synthesize_entry(){
    _ping_createencode_map();
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
    if (![cls respondsToSelector:@selector(dynamicPropertyKeys)]) {
        unsigned int count = 0;
        objc_property_t *propertys =  class_copyPropertyList(cls, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = propertys[i];
            const char  *attr =  property_getAttributes(property);
            if (attr[0] != 'T' || encodeMap[attr[1]] == 0) {
                continue;
            }
            // 指针类型只支持void *
            if (attr[1] == '^' && attr[2] != 'v') {
                continue;
            }
            
            const char  *_name = property_getName(property);
            NSString *name = [NSString stringWithCString:_name encoding:NSUTF8StringEncoding];
            NSString *attrStr = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
            SEL setSel = _ping_synthesize_setsel(name);
            SEL getSel = _ping_synthesize_getSel(name);
            Method setMethod = class_getInstanceMethod(cls, setSel);
            Method getMethod = class_getInstanceMethod(cls, getSel);
            if (!(setMethod || getMethod)) {
                uintptr_t policy = _ping_analyze_policy(attrStr);
                _ping_dispense_setget_implementation(policy, setSel, getSel, cls,(char *)attr);
            }
        }
        free(propertys);
    }else{
        NSArray *propertys = [cls dynamicPropertyKeys];
        if (!propertys || propertys.count == 0) {
            return;
        }
        
        for (NSString *propertyName in propertys) {
            objc_property_t property = class_getProperty(cls, [propertyName UTF8String]);
            if (property == NULL) {
                continue;
            }
            const char  *attr =  property_getAttributes(property);
            if (attr[0] != 'T' || encodeMap[attr[1]] == 0) {
                continue;
                
            }
            // 指针类型只支持void *
            if (attr[1] == '^' && attr[2] != 'v') {
                continue;
            }
            
            NSString *attrStr = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
            if ([propertys containsObject:propertyName]) {
                SEL setSel = _ping_synthesize_setsel(propertyName);
                SEL getSel = _ping_synthesize_getSel(propertyName);
                uintptr_t policy = _ping_analyze_policy(attrStr);
                _ping_dispense_setget_implementation(policy, setSel, getSel, cls,(char *)attr);
            }
        }
        
    }
}

@end
