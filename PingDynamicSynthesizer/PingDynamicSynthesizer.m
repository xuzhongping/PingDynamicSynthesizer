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
#define PING_NONATOMIC_ENCODE   @"N"
#define PING_ATOMIC_ENCODE      @""
#define PING_STRONG_ENCODE      @"&"
#define PING_COPY_ENCODE        @"C"
#define PING_WEAK_ENCODE        @"W"
#define PING_DYNAMIC_ENCODE     @"D"
#define PING_UNSAFE_UNRETAIN_ENCODE    @""


// define policy magic
#define OBJC_ASSOCIATION_WEAK_NONATOMIC 0x613
#define OBJC_ASSOCIATION_WEAK           0x614
#define OBJC_ASSOCIATION_UNDEFINE       0x615

// obj method encode
#define SET_METHOD_OBJ_ENCODE "v@:@"
#define GET_METHOD_OBJ_ENCODE "@@:"



/*******************************************Macro************************************************/

@implementation PingDynamicSynthesizer

static char _encodeMap[128];

// static inline methods
static void _ping_create_encode_map(){
    _encodeMap[(uint8_t)*@encode(BOOL)] = 1;
    _encodeMap[(uint8_t)*@encode(char)] = 1;
    _encodeMap[(uint8_t)*@encode(short)] = 1;
    _encodeMap[(uint8_t)*@encode(int)] = 1;
    _encodeMap[(uint8_t)*@encode(long)] = 1;
    _encodeMap[(uint8_t)*@encode(long long)] = 1;
    _encodeMap[(uint8_t)*@encode(float)] = 1;
    _encodeMap[(uint8_t)*@encode(double)] = 1;
    _encodeMap[(uint8_t)*@encode(unsigned char)] = 1;
    _encodeMap[(uint8_t)*@encode(unsigned short)] = 1;
    _encodeMap[(uint8_t)*@encode(unsigned int)] = 1;
    _encodeMap[(uint8_t)*@encode(unsigned long)] = 1;
    _encodeMap[(uint8_t)*@encode(unsigned long long)] = 1;
    _encodeMap[(uint8_t)*@encode(void *)] = 1;
    _encodeMap[(uint8_t)*@encode(char *)] = 1;
    _encodeMap['@'] = 1;
}

static inline char * _ping_set_method_encode(char *code){
    char *_set_method_encode = NULL;
    if (code[0] == '^' && code[1] == 'v') {
        char _encode[5] = "v@:^v";
        _set_method_encode = _encode;
    }else{
        char _encode[4] = "v@:*";
        _encode[3] = code[0];
        _set_method_encode = _encode;
    }
    return _set_method_encode;
}

static inline char * _ping_get_method_encode(char *code){
    char *_get_method_encode = NULL;
    if (code[0] == '^' && code[1] == 'v') {
        char _encode[4] = "^v@:";
        _get_method_encode = _encode;
    }else{
        char _encode[3] = "v@:";
        _encode[0] = code[0];
        _get_method_encode = _encode;
    }
    return _get_method_encode;
}

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

static void _ping_dispense_setget_implementation(uintptr_t policy,
                                                 SEL setSel,SEL getSel,
                                                 __nonnull Class class,char *_encode){
    
#define _PING_DYNAMIC_NONOBJ_SETTER_IMP(policy,type)   \
(IMP)_ping_dynamic_setter_method_non_obj_##policy##_##type

#define _PING_DYNAMIC_NONOBJ_GETTER_IMP(type)   \
(IMP)_ping_dynamic_getter_method_non_obj_##type
    
    _encode ++;
    if (_encode[0] == '@') {
        switch (policy) {
            case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK,_ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_COPY_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY_NONATOMIC, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_WEAK_NONATOMIC:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK_NONATOMIC, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, _ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_RETAIN:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_RETAIN, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_COPY:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_COPY, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_WEAK:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_WEAK, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_WEAK, _ping_get_method_encode(_encode));
            }
                break;
            case OBJC_ASSOCIATION_ASSIGN:
            {
                class_addMethod(class, setSel, (IMP)_ping_dynamic_setter_method_OBJC_ASSOCIATION_ASSIGN, _ping_set_method_encode(_encode));
                class_addMethod(class, getSel, (IMP)_ping_dynamic_getter_method_OBJC_ASSOCIATION_AUTO_NOTWEAK, _ping_get_method_encode(_encode));
            }
                break;
                
            default:
            {
                NSCAssert(false, @"can't synthesize setter getter methods");
            }
                break;
        }
    }
    else if (_encode[0] == @encode(BOOL)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,BOOL), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,BOOL), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(BOOL), _ping_get_method_encode(_encode));
    }
    else if (_encode[0] == @encode(char)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,char), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,char), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(char), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(char *)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_str), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_str), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_str), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(short)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,short), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,short), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(short), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(int)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,int), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,int), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(int), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(long)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,long), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,long), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(long), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(long long)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_llong), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_llong), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_llong), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(float)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,float), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,float), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(float), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(double)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,double), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,double), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(double), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(unsigned char)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_uchar), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_uchar), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_uchar), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(unsigned short)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ushort), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ushort), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ushort), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(unsigned int)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_uint), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_uint), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_uint), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(unsigned long)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ulong), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ulong), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ulong), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(unsigned long long)[0]){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ullong), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ullong), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ullong), _ping_get_method_encode(_encode));
    }else if (_encode[0] == @encode(void *)[0] && _encode[1] == 'v'){
        if (_encode[1] == 'N') {
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN_NONATOMIC,_ping_ptr), _ping_set_method_encode(_encode));
        }else{
            class_addMethod(class, setSel, _PING_DYNAMIC_NONOBJ_SETTER_IMP(OBJC_ASSOCIATION_RETAIN,_ping_ptr), _ping_set_method_encode(_encode));
        }
        class_addMethod(class, getSel, _PING_DYNAMIC_NONOBJ_GETTER_IMP(_ping_ptr), _ping_get_method_encode(_encode));
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
    _ping_create_encode_map();
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
        unsigned int pty_count = 0;
        objc_property_t *ptys =  class_copyPropertyList(cls, &pty_count);
        for (int i = 0; i < pty_count; i++) {
            objc_property_t pty = ptys[i];
            const char  *_att =  property_getAttributes(pty);
            if (_att[0] != 'T' || _encodeMap[_att[1]] == 0) {continue;}
            // 指针类型只支持void *
            if (_att[1] == '^' && _att[2] != 'v') {continue;}
            
            const char  *_name = property_getName(pty);
            NSString *name = [NSString stringWithCString:_name encoding:NSUTF8StringEncoding];
            NSString *att = [NSString stringWithCString:_att encoding:NSUTF8StringEncoding];
            SEL setSel = _ping_synthesize_setsel(name);
            SEL getSel = _ping_synthesize_getSel(name);
            Method setMethod = class_getInstanceMethod(cls, setSel);
            Method getMethod = class_getInstanceMethod(cls, getSel);
            if (!(setMethod || getMethod)) {
                uintptr_t policy = _ping_analyze_policy(att);
                _ping_dispense_setget_implementation(policy, setSel, getSel, cls,(char *)_att);
            }
        }
        free(ptys);
    }else{
        NSArray *rawPropertys = [cls dynamicPropertyKeys];
        if (!rawPropertys || rawPropertys.count == 0) {
            return;
        }
        
        for (NSString *ptyName in rawPropertys) {
            objc_property_t pty = class_getProperty(cls, [ptyName UTF8String]);
            if (pty == NULL) {
                continue;
            }
            const char  *_att =  property_getAttributes(pty);
            if (_att[0] != 'T' || _encodeMap[_att[1]] == 0) {continue;}
            // 指针类型只支持void *
            if (_att[1] == '^' && _att[2] != 'v') {continue;}
            NSString *att = [NSString stringWithCString:_att encoding:NSUTF8StringEncoding];
            if ([rawPropertys containsObject:ptyName]) {
                SEL setSel = _ping_synthesize_setsel(ptyName);
                SEL getSel = _ping_synthesize_getSel(ptyName);
                uintptr_t policy = _ping_analyze_policy(att);
                _ping_dispense_setget_implementation(policy, setSel, getSel, cls,(char *)_att);
            }
        }
        
    }
}

@end
