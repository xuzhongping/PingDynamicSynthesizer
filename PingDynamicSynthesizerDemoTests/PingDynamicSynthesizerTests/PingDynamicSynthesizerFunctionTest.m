//
//  PingDynamicSynthesizerTest.m
//  PingDynamicSynthesizerDemoTests
//
//  Created by 徐仲平 on 2019/3/25.
//  Copyright © 2019 徐仲平. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PingDynamicSynthesizer.h"
#import "Fizz+Ex1.h"

@interface PingDynamicSynthesizerFunctionTest : XCTestCase

@end

@implementation PingDynamicSynthesizerFunctionTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    }];
}


- (void)testPing_dynamicProperty_nonatomicStrong{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.strongObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 2);
    XCTAssertEqual(f.strongObj, obj);
}

- (void)testPing_dynamicProperty_nonatomicWeak{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.weakObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 1);
    XCTAssertEqual(f.weakObj, obj);
}

- (void)testPing_dynamicProperty_nonatomicAssign{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.assignObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 1);
    XCTAssertNotNil(f.assignObj);
    XCTAssertEqual(f.assignObj, obj);
}

- (void)testPing_dynamicProperty_nonatomicCopy{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSMutableString *obj = [@"123" mutableCopy];
    f.copyObj = obj;
    XCTAssertNotEqual(f.copyObj, obj);
}



- (void)testPing_dynamicProperty_atomicStrong{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.atomicStrongObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 2);
    XCTAssertEqual(f.atomicStrongObj, obj);
}

- (void)testPing_dynamicProperty_atomicWeak{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.atomicWeakObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 1);
    XCTAssertEqual(f.atomicWeakObj, obj);
}

- (void)testPing_dynamicProperty_atomicAssign{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSObject *obj = [NSObject new];
    f.atomicAssignObj = obj;
    XCTAssert([[obj valueForKey:@"retainCount"] integerValue] == 1);
    XCTAssertEqual(f.atomicAssignObj, obj);
}

- (void)testPing_dynamicProperty_atomicCopy{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    NSMutableString *obj = [@"123" mutableCopy];
    f.atomicCopyObj = obj;
    XCTAssertNotEqual(f.atomicCopyObj, obj);
}





- (void)testPing_dynamicProperty_boolValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    BOOL value = YES;
    f.boolValue = value;
    XCTAssertEqual(f.boolValue, value);
}

- (void)testPing_dynamicProperty_charValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    char value = 'A';
    f.charValue = value;
    XCTAssertEqual(f.charValue, value);
}

- (void)testPing_dynamicProperty_shortValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    short value = 22;
    f.shortValue = value;
    XCTAssertEqual(f.shortValue, value);
}

- (void)testPing_dynamicProperty_intValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    int value = INT_MAX;
    f.intValue = value;
    XCTAssertEqual(f.intValue, value);
}

- (void)testPing_dynamicProperty_longValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    long value = LONG_MAX;
    f.longValue = value;
    XCTAssertEqual(f.longValue, value);
}

- (void)testPing_dynamicProperty_dlongValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    long long value = LONG_LONG_MAX;
    f.dlongValue = value;
    XCTAssertEqual(f.dlongValue, value);
}

- (void)testPing_dynamicProperty_floatValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    float value = 1.234;
    f.floatValue = value;
    XCTAssertEqual(f.floatValue, value);
}

- (void)testPing_dynamicProperty_doubleValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    double value = 1.234;
    f.doubleValue = value;
    XCTAssertEqual(f.doubleValue, value);
}

- (void)testPing_dynamicProperty_ucharValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    unsigned char value = 'A';
    f.ucharValue = value;
    XCTAssertEqual(f.ucharValue, value);
}


- (void)testPing_dynamicProperty_ushortValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    unsigned short value = 123;
    f.ucharValue = value;
    XCTAssertEqual(f.ucharValue, value);
}

- (void)testPing_dynamicProperty_uintValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    unsigned int value = UINT_MAX;
    f.uintValue = value;
    XCTAssertEqual(f.uintValue, value);
}

- (void)testPing_dynamicProperty_ulongValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    unsigned long value = ULONG_MAX;
    f.ulongValue = value;
    XCTAssertEqual(f.ulongValue, value);
}

- (void)testPing_dynamicProperty_udlongValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    unsigned long long value = ULLONG_MAX;
    f.udlongValue = value;
    XCTAssertEqual(f.udlongValue, value);
}

- (void)testPing_dynamicProperty_cStrValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    char *value = "PING";
    f.cStrValue = value;
    XCTAssertEqual(f.cStrValue, value);
}


- (void)testPing_dynamicProperty_voidPValue{
    [PingDynamicSynthesizer ping_dynamicProperty:[Fizz class]];
    Fizz *f = [Fizz new];
    void *value = (void *)0x123;
    f.voidPValue = value;
    XCTAssertEqual(f.voidPValue, value);
}

- (void)testPing_dynamicProperty_pointValue{

    
}

@end
