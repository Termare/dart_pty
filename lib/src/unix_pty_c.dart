// 整个代码是c写的，dart负责调用
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'unix/term.dart';
import 'utils/custom_utf.dart';

class UnixPtyC {
  final NiUtf _niUtf = NiUtf();
  final Map<String, String> environment;
  CTermare cTermare;
  int pseudoTerminalId;
  UnixPtyC({
    this.environment = const <String, String>{
      'TERM': 'screen-256color',
    },
  }) {
    DynamicLibrary dynamicLibrary;
    if (!Platform.isAndroid) {
      dynamicLibrary = DynamicLibrary.open(
        '/Users/nightmare/Desktop/termare-space/dart_pty/lib/src/libterm.dylib',
      );
    } else {
      dynamicLibrary = DynamicLibrary.open(
        'libterm.so',
      );
    }
    cTermare = CTermare(dynamicLibrary);
    pseudoTerminalId = cTermare.create_ptm(51, 47);
    print('<- pseudoTerminalId:$pseudoTerminalId ->');
    final Pointer<Pointer<Utf8>> argv = allocate<Pointer<Utf8>>(count: 1);

    ///    将双重指针的第一个一级指针赋值为空
    ///    等价于
    ///    char **p = (char **)malloc(1);
    ///    p[1] = 0;    p[1] = NULL;    *p = 0;   *p = NULL;
    ///    上一行的4个语句都是等价的
    ///    将第一个指针赋值为空的原因是C语言端遍历这个argv的方法是通过判断当前指针是否为空作为循环的退出条件
    argv[0] = Pointer<Utf8>.fromAddress(0);

    /// 定义一个二级指针，用来保存当前终端的环境信息，这个二级指针对应C语言中的二维数组
    Pointer<Pointer<Utf8>> envp;

    ///
    final Map<String, String> platformEnvironment = Map.from(
      Platform.environment,
    );
    for (String key in environment.keys) {
      platformEnvironment[key] = environment[key];
    }

    /// 将当前App的bin目录也添加进这个环境变量
    // environment['PATH'] = (Platform.isAndroid
    //         ? '${EnvirPath.filesPath}/usr/bin:'
    //         : FileSystemEntity.parentOf(Platform.resolvedExecutable) +
    //             '/data/usr/bin:') +
    //     environment['PATH'];

    /// 申请内存空间，空间数为列元素个数加1，最后的空间用来设置空指针，好让原生的循环退出
    // int envpLength = environment.length + 1 + platformEnvironment.length;
    // envp = allocate<Pointer<Utf8>>(
    //   count: envpLength,
    // );

    // /// 将Map内容拷贝到二维数组
    // for (int i = 0; i < platformEnvironment.keys.length; i++) {
    //   envp[i] = Utf8.toUtf8(
    //     '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}',
    //   );
    // }
    // for (int i = 0; i < environment.keys.length; i++) {
    //   envp[i] = Utf8.toUtf8(
    //     '${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}',
    //   );
    // }
    // // 设置当前终端的类型
    // // envp[environment.keys.length] = Utf8.toUtf8('TERM=screen');

    // ///  末元素赋值空指针
    // envp[envpLength - 1] = Pointer<Utf8>.fromAddress(0);
    envp = allocate<Pointer<Utf8>>(count: platformEnvironment.keys.length + 1);

    /// 将Map内容拷贝到二维数组
    for (int i = 0; i < platformEnvironment.keys.length; i++) {
      envp[i] = Utf8.toUtf8(
        '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}',
      );
    }
    // 设置当前终端的类型
    // envp[environment.keys.length] = Utf8.toUtf8('TERM=screen');

    ///  末元素赋值空指针
    envp[platformEnvironment.keys.length] = Pointer<Utf8>.fromAddress(0);

    /// 定义一个指向int的指针
    /// 是C语言中常用的方法，指针为双向传递，可以由调用的函数来直接更改这个值
    final Pointer<Int32> processId = allocate();

    /// 初始化为0
    processId.value = 0;

    /// shPath为需要C Native 执行的程序路径
    /// 由终端的特性，这个命令一般是sh或者bash或其他类似的程序
    /// 并且一般不带参数，所以上面的argv为空
    String shPath;

    /// 即使是在安卓设备上，sh也是能在环境变量中找到的
    /// 由于在App的数据目录中可能会存在busybox链接出来的sh，它与系统自带的sh存在差异
    /// 如果直接执行sh就会优先执行数据目录的sh，所以指定为/system/bin/sh
    ///
    ///
    if (Platform.isAndroid) {
      if (File('/data/data/com.nightmare/files/usr/bin/login').existsSync()) {
        shPath = 'login';
      } else
        shPath = '/system/bin/sh';
    } else
      shPath = 'bash';
    cTermare.create_subprocess(
      Pointer<Int8>.fromAddress(0),
      Utf8.toUtf8(shPath).cast(),
      Utf8.toUtf8('/').cast(),
      argv.cast(),
      envp.cast(),
      processId,
      pseudoTerminalId,
    );
    cTermare.setNonblock(pseudoTerminalId);

    /// 释放动态申请的空间
    // free(argv);
    // free(envp);
    // free(processId);
    print('processId.value->${processId.value}');
    // read();
  }

  // void read() async {
  //   while (true) {
  //     await Future.delayed(Duration(milliseconds: 300));
  //     print('读取');
  //     final Pointer<Uint8> resultPoint =
  //         cTermare.get_output_from_fd(pseudoTerminalId).cast();

  //     // 代表空指针
  //     if (resultPoint.address == 0) {
  //       // 释放内存
  //       // free(resultPoint);
  //       continue;
  //     }
  //     String result = _niUtf.cStringtoString(resultPoint);
  //     print('result->$result');
  //   }
  // }
  void write(String data) {
    cTermare.write_to_fd(pseudoTerminalId, Utf8.toUtf8(data).cast());
  }

  String read() {
    // print('读取');
    final Pointer<Uint8> resultPoint =
        cTermare.get_output_from_fd(pseudoTerminalId).cast();
    // 代表空指针
    if (resultPoint.address == 0) {
      // 释放内存
      // free(resultPoint);
      return '';
    }
    String result = _niUtf.cStringtoString(resultPoint);
    return result;
  }
}

// /// 返回子进程的进程id
// int createProcess(int pseudoTerminalId) {
//   // _initFFI();
//   DynamicLibrary _dylib;
//   String libPath;
//   if (libPath == null) {
//     if (Platform.isMacOS) {
//       libPath =
//           '${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/libterm.dylib';
//     } else if (Platform.isLinux) {
//       libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
//           '/lib/libterm.so';
//       print(libPath);
//     } else if (Platform.isAndroid) {
//       libPath = 'libterm.so';
//     }
//   }
//   _dylib ??= DynamicLibrary.open(libPath);
//   //    找到在当前终端对创建子程序的原生指针，指向C语言中create_subprocess这个函数
//   final Pointer<NativeFunction<create_subprocess>> createSubprocessPointer =
//       _dylib.lookup<NativeFunction<create_subprocess>>('create_subprocess');

//   ///    将上面的指针转换为dart可执行的方法
//   final CreateSubprocess createSubprocess =
//       createSubprocessPointer.asFunction<CreateSubprocess>();
//   //    创建一个对应原生char的二级指针并申请一个字节长度的空间
//   final Pointer<Pointer<Utf8>> argv = allocate<Pointer<Utf8>>(count: 1);

//   ///    将双重指针的第一个一级指针赋值为空
//   ///    等价于
//   ///    char **p = (char **)malloc(1);
//   ///    p[1] = 0;    p[1] = NULL;    *p = 0;   *p = NULL;
//   ///    上一行的4个语句都是等价的
//   ///    将第一个指针赋值为空的原因是C语言端遍历这个argv的方法是通过判断当前指针是否为空作为循环的退出条件
//   argv[0] = Pointer<Utf8>.fromAddress(0);

//   /// 定义一个二级指针，用来保存当前终端的环境信息，这个二级指针对应C语言中的二维数组
//   Pointer<Pointer<Utf8>> envp;

//   ///
//   final Map<String, String> environment = <String, String>{};
//   environment.addAll(Platform.environment);

//   /// 将当前App的bin目录也添加进这个环境变量
//   environment['PATH'] = (Platform.isAndroid
//           ? '${EnvirPath.filesPath}/usr/bin:'
//           : FileSystemEntity.parentOf(Platform.resolvedExecutable) +
//               '/data/usr/bin:') +
//       environment['PATH'];

//   /// 申请内存空间，空间数为列元素个数加1，最后的空间用来设置空指针，好让原生的循环退出
//   envp = allocate<Pointer<Utf8>>(count: environment.keys.length + 1 + 1);

//   /// 将Map内容拷贝到二维数组
//   for (int i = 0; i < environment.keys.length; i++) {
//     envp[i] = Utf8.toUtf8(
//         '${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}');
//   }
//   // 设置当前终端的类型
//   // envp[environment.keys.length] = Utf8.toUtf8('TERM=screen');

//   envp[environment.keys.length] = Utf8.toUtf8('TERM=screen-256color');

//   ///  末元素赋值空指针
//   envp[environment.keys.length + 1] = Pointer<Utf8>.fromAddress(0);

//   /// 定义一个指向int的指针
//   /// 是C语言中常用的方法，指针为双向传递，可以由调用的函数来直接更改这个值
//   final Pointer<Int32> processId = allocate();

//   /// 初始化为0
//   processId.value = 0;

//   /// shPath为需要C Native 执行的程序路径
//   /// 由终端的特性，这个命令一般是sh或者bash或其他类似的程序
//   /// 并且一般不带参数，所以上面的argv为空
//   String shPath;

//   /// 即使是在安卓设备上，sh也是能在环境变量中找到的
//   /// 由于在App的数据目录中可能会存在busybox链接出来的sh，它与系统自带的sh存在差异
//   /// 如果直接执行sh就会优先执行数据目录的sh，所以指定为/system/bin/sh
//   ///
//   ///
//   if (Platform.isAndroid) {
//     if (File('${EnvirPath.binPath}/login').existsSync()) {
//       shPath = 'login';
//     } else
//       shPath = '/system/bin/sh';
//   } else
//     shPath = 'bash';
//   createSubprocess(
//     Pointer<Utf8>.fromAddress(0),
//     Utf8.toUtf8(shPath),
//     Utf8.toUtf8('/'),
//     argv,
//     envp,
//     processId,
//     pseudoTerminalId,
//   );

//   /// 释放动态申请的空间
//   free(argv);
//   free(envp);
//   free(processId);
//   return processId.value;
// }
