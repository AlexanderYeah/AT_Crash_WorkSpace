//
//  AppDelegate.m
//  AT_Crash_Demo1
//
//  Created by TrimbleZhang on 2018/12/18.
//  Copyright © 2018 AlexanderYeah. All rights reserved.
//

#import "AppDelegate.h"
#include <execinfo.h>
#import "SignalHandler.h"
#import "UncaughtExceptionHandler.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // 捕获crash 信息
    InstallUncaughtExceptionHandler();
    
    return YES;
}

// 1 backtrace可以在程序运行的任何地方被调用，返回各个调用函数的返回地址，可以限制最大调用栈返回层数。

// 2 在backtrace拿到函数返回地址之后，backtrace_symbols可以将其转换为编译符号，这些符号是编译期间就确定的
// 3 根据backtrace_symbols返回的编译符号，abi::__cxa_demangle可以找到具体地函数方法
//
void SignalExceptionHandler(int signal)
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Stack:\n"];
    void* callstack[128];
    // 导入#include <execinfo.h> 调用 backtrace backtrace_symbols 和方法
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
//    [SignalHandler saveCreash:mstr];
    
}
//
//
//void InstallSignalHandler(void)
//{
//
//    signal(SIGHUP, SignalExceptionHandler);
//    signal(SIGINT, SignalExceptionHandler);
//    signal(SIGQUIT, SignalExceptionHandler);
//    signal(SIGABRT, SignalExceptionHandler);
//    signal(SIGILL, SignalExceptionHandler);
//    signal(SIGSEGV, SignalExceptionHandler);
//    signal(SIGFPE, SignalExceptionHandler);
//    signal(SIGBUS, SignalExceptionHandler);
//    signal(SIGPIPE, SignalExceptionHandler);
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
