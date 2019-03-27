//
//  PingDynamicSynthesizerPerformanceTest.m
//  PingDynamicSynthesizerDemoTests
//
//  Created by 徐仲平 on 2019/3/27.
//  Copyright © 2019 徐仲平. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PingDynamicSynthesizer.h"

#import "PingCase1.h"
#import "PingCase2.h"
#import "PingCase3.h"
#import "PingCase4.h"
#import "PingCase5.h"
#import "PingCase6.h"
#import "PingCase7.h"
#import "PingCase8.h"
#import "PingCase9.h"
#import "PingCase10.h"
#import "PingCase11.h"
#import "PingCase12.h"
#import "PingCase13.h"
#import "PingCase14.h"
#import "PingCase15.h"
#import "PingCase16.h"
#import "PingCase17.h"
#import "PingCase18.h"
#import "PingCase19.h"
#import "PingCase20.h"
#import "PingCase21.h"
#import "PingCase22.h"
#import "PingCase23.h"
#import "PingCase24.h"
#import "PingCase25.h"
#import "PingCase26.h"
#import "PingCase27.h"
#import "PingCase28.h"
#import "PingCase29.h"
#import "PingCase30.h"


@interface PingDynamicSynthesizerPerformanceTest : XCTestCase

@end

@implementation PingDynamicSynthesizerPerformanceTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

- (void)testPerformance{

    
   uint64_t t = dispatch_benchmark(1, ^{
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase1 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase2 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase3 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase4 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase5 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase6 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase7 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase8 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase9 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase10 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase11 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase12 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase13 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase14 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase15 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase16 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase17 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase18 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase19 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase20 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase21 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase22 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase23 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase24 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase25 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase26 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase27 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase28 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase29 class]];
       [PingDynamicSynthesizer ping_dynamicProperty:[PingCase30 class]];
    });
    NSLog(@"Avg. Runtime: %llu ns", t);
}

@end
