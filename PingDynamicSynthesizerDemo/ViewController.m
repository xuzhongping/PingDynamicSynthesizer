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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    Person *p = [Person new];
    
    p.num = 5;
    p.fl = 0.2;
    p.longNum = 20;

    NSLog(@"%d %f %ld",p.num,p.fl,p.longNum);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
