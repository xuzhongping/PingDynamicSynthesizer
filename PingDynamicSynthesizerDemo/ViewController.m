//
//  ViewController.m
//  PingDynamicSynthesizerDemo
//
//  Created by JungHsu on 2017/12/10.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "ViewController.h"
#import "Person+Extra.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PingDynamicSynthesizer dynamicPropertyClass:[Person class]];
    
    Person *p = [Person new];
//    [p setName:@"xiaoming"];
    [p setValue:@"zhangsan" forKey:@"name"];
    NSLog(@"%@",p.name);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end