//
//  ViewController.m
//  AT_Crash_Demo1
//
//  Created by Coder on 2018/12/18.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


typedef struct Test
{
    int a;
    int b;
}Test;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
}

// 不要在debug环境下测试。因为系统的debug会优先去拦截。我们要运行一次后，关闭debug状态。应该直接在模拟器上点击我们build上去的app去运行。而UncaughtExceptionHandler可以在调试状态下捕捉

- (IBAction)btnClick2:(id)sender {
    //1.信号量
    Test *pTest = {1,2};
    
    //导致SIGABRT的错误，因为内存中根本就没有这个空间，哪来的free，就在栈中的对象而已
    free(pTest);
    pTest->a = 5;
}

// 做一个数组越界的测试
- (IBAction)btnClick1:(id)sender {
    
    
    NSMutableArray *numArr = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3"]];
    // 数组越界
    [numArr removeObjectAtIndex:5];
    
}

@end
