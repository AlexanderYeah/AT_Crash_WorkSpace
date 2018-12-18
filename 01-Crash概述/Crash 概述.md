### Crash 概述

### 1  产生原因

一般是由Mach 异常 或者Objective-C 异常引起的crash

![]()

* 1 Mach 异常是最底层的内核级异常。如EXC_BAD_ACCESS（内存访问异常)
* 2 Unix Signal是Unix系统中的一种异步通知机制，Mach异常在host层被ux_exception转换为相应的Unix Signal，并通过threadsignal将信号投递到出错的线程
* 3 NSException是OC层，由iOS库或者各种第三方库或Runtime验证出错误而抛出的异常。如NSRangeException（数组越界异常）
* 4 当错误发生时候，先在最底层产生Mach异常；Mach异常在host层被转换为相应的Unix Signal; 
  在OC层如果有对应的NSException（OC异常），就转换成OC异常，OC异常可以在OC层得到处理；如果OC异常一直得不到处理，程序会强行发送SIGABRT信号中断程序。在OC层如果没有对应的NSException，就只能让Unix标准的signal机制来处理了。
* 5 在捕获Crash事件时，优选Mach异常。因为Mach异常处理会先于Unix信号处理发生，如果Mach异常的handler让程序exit了，那么Unix信号就永远不会到达这个进程了。而转换Unix信号是为了兼容更为流行的POSIX标准(SUS规范)，这样就不必了解Mach内核也可以通过Unix信号的方式来兼容开发。



### Mach 异常

Mach操作系统微内核，是许多新操作系统的设计基础。Mach微内核中有几个基础概念：

* Tasks 拥有一组系统资源的对象，允许"thread"在其中执行。
* Threads，执行的基本单位，拥有task的上下文，并共享其资源。
* Ports，task之间通讯的一组受保护的消息队列；task可对任何port发送/接收数据。
* Message，有类型的数据对象集合，只可以发送到port。



Mach 异常是指最底层的内核级异常，被定义在 <mach/exception_types.h>下。`mach`异常由处理器陷阱引发，在异常发生后会被异常处理程序转换成`Mach消息`，接着依次投递到`thread、task和host端口`。如果没有一个端口处理这个异常并返回`KERN_SUCCESS`，那么应用将被终止。每个端口拥有一个异常端口数组，系统暴露了后缀为`_set_exception_ports`的多个`API`让我们注册对应的异常处理到端口中





### Objective-C 异常引起的crash,处理signal

 使用Objective-C的异常处理是不能得到signal的，如果要处理它，我们还要利用unix标准的signal机制，注册SIGABRT, SIGBUS, SIGSEGV等信号发生时的处理函数。该函数中我们可以输出栈信息，版本信息等其他一切我们所想要的。

常见的一下几种信号：

|    名称     |                       解释                       |
| :---------: | :----------------------------------------------: |
| **SIGABRT** |                  调用abort产生                   |
| **SIGBUS**  | 非法地址。比如错误的内存类型访问、内存地址对齐等 |
| **SIGSEGV** | 非法地址。访问未分配内存、写入没有写权限的内存等 |
| **SIGFPE**  |     致命的算术运算。比如数值溢出、NaN数值等      |
| **SIGILL**  |    执行了非法指令，一般是可执行文件出现了错误    |
|   SIGTRAP   |           断点指令或者其他trap指令产生           |



### crash 信息收集 

demo 中已经封装了两个类方法，直接在AppDelegate 中进行调用即可

```objective-c

// 监听对应的crash原因，当发生crash的时候会进行调用对应的方法，可以将log 卸载本地，然后上传至服务器

void InstallSignalHandler(void)
{
    // SignalExceptionHandler为 对应的方法
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

// 导入#include <execinfo.h> 调用 backtrace backtrace_symbols 和方法

// 1 backtrace可以在程序运行的任何地方被调用，返回各个调用函数的返回地址，可以限制最大调用栈返回层数。

// 2 在backtrace拿到函数返回地址之后，backtrace_symbols可以将其转换为编译符号，这些符号是编译期间就确定的
// 3 根据backtrace_symbols返回的编译符号，abi::__cxa_demangle可以找到具体地函数方法
// crash 发生回调的方法
void SignalExceptionHandler(int signal)
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Stack:\n"];
    void* callstack[128];
  
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
    // log 写入本地
//    [SignalHandler saveCreash:mstr];
    
}


```



### 常见的NSException异常

- 1、unrecognized selector crash
- 2、KVO crash
- 3、NSNotification crash
- 4、NSTimer crash
- 5、Container crash（数组越界，插nil等）
- 6、NSString crash （字符串操作的crash）
- 7、Bad Access crash （野指针）
- 8、UI not on Main Thread Crash (非主线程刷UI(机制待改善))



