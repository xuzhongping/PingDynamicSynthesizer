//
//  ViewController.m
//  PingDynamicSynthesizerDemo
//
//  Created by JungHsu on 2017/12/10.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "ViewController.h"
#import "Person+Extra.h"
#import "PingNonObjHelper.h"
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSObject *obj = [NSObject new];
    NSObject *value = [NSObject new];
    objc_setAssociatedObject(obj, @"testSEL", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSLog(@"%@",objc_getAssociatedObject(obj, @"testSEL"));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
