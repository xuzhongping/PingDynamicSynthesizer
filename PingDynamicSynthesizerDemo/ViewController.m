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
        
    Person *p = [Person new];
    [p setName:@"xiaoming"];
    
    [p setSs:[UIView new]];
    
    [p setSafe:@"safe"];
    
    NSLog(@"%@ %@ %@",p.ss,p.name,p.safe);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
