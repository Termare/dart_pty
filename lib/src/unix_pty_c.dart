// 整个代码是c写的，dart负责调用
import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:dart_pty/src/proc.dart';
import 'package:ffi/ffi.dart';

import 'interface/pseudo_terminal_interface.dart';
import 'unix/termare_native.dart';
import 'unix_proc.dart';
import 'utils/custom_utf.dart';

// 这个需要配合c语言实现

void dartCallback(Pointer<Int8> int8) {
  Pointer<Utf8> utf8Pointer = int8.cast();
  print(utf8Pointer.toDartString());
}

class UnixPtyC implements PseudoTerminal {
  UnixPtyC({
    required this.rowLen,
    required this.columnLen,
    this.libPath,
    String? executable,
    String workingDirectory = '',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
  }) {
    out = _out.stream.asBroadcastStream();
    DynamicLibrary dynamicLibrary;
    if (libPath != null) {
      dynamicLibrary = DynamicLibrary.open(libPath!);
    } else {
      dynamicLibrary = DynamicLibrary.process();
    }

    termareNative = TermareNative(dynamicLibrary);
    Pointer<NativeFunction<Callback>> callback =
        Pointer.fromFunction<Callback>(dartCallback);
    termareNative.init_dart_print(callback);
    pseudoTerminalId = termareNative.create_ptm(rowLen, columnLen);
    print('<- pseudoTerminalId : $pseudoTerminalId ->');
    _createSubprocess(
      executable!,
      workingDirectory: workingDirectory,
      arguments: arguments,
      environment: environment,
    );
  }
  final NiUtf _niUtf = NiUtf();
  final String? libPath;
  final int rowLen;
  final int columnLen;
  late TermareNative termareNative;

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
    termareNative.write_to_fd(pseudoTerminalId!, data.toNativeUtf8().cast());
  }

  @override
  List<int> readSync() {
    // print('读取');
    final Pointer<Uint8> resultPoint =
        termareNative.get_output_from_fd(pseudoTerminalId!).cast();
    // 代表空指针
    if (resultPoint.address == 0) {
      // 释放内存
      // free(resultPoint);
      return [];
    }
    final List<int> result = _niUtf.getCodeUnits(resultPoint)!;
    return result;
  }

  Proc _createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
  }) {
    print('executable -> $executable');
    print('arguments -> $arguments');
    final Pointer<Pointer<Utf8>> argv = calloc<Pointer<Utf8>>(
      arguments.length + 1,
    );
    for (int i = 0; i < arguments.length; i++) {
      argv[i] = arguments[i].toNativeUtf8();
    }
    argv[arguments.length] = nullptr;

    ///    将双重指针的第一个一级指针赋值为空
    ///    等价于
    ///    char **p = (char **)malloc(1);
    ///    p[1] = 0;    p[1] = NULL;    *p = 0;   *p = NULL;
    ///    上一行的4个语句都是等价的
    ///    将第一个指针赋值为空的原因是C语言端遍历这个argv的方法是通过判断当前指针是否为空作为循环的退出条件
    // argv[0] = nullptr;

    /// 定义一个二级指针，用来保存当前终端的环境信息，这个二级指针对应C语言中的二维数组

    ///
    final Map<String, String> platformEnvironment = Map.from(
      Platform.environment,
    );
    platformEnvironment['LANG'] = 'en_US.UTF-8';
    for (final String key in environment.keys) {
      platformEnvironment[key] = environment[key]!;
    }

    final Pointer<Pointer<Utf8>> envp = calloc<Pointer<Utf8>>(
      platformEnvironment.length + 1,
    );

    /// 将Map内容拷贝到二维数组
    for (int i = 0; i < platformEnvironment.keys.length; i++) {
      envp[i] =
          '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}'
              .toNativeUtf8();
    }

    ///  末元素赋值空指针
    envp[platformEnvironment.length] = nullptr;

    /// 定义一个指向int的指针
    /// 是C语言中常用的方法，指针为双向传递，可以由调用的函数来直接更改这个值
    final Pointer<Int32> processId = calloc<Int32>(1);

    /// 初始化为0
    processId.value = 0;

    termareNative.create_subprocess(
      nullptr,
      executable.toNativeUtf8().cast(),
      workingDirectory.toNativeUtf8().cast(),
      argv.cast(),
      envp.cast(),
      processId,
      pseudoTerminalId!,
    );
    // Pointer<NativeFunction<Callback>> callback =
    //     Pointer.fromFunction<Callback>(dartCallback);
    // cTermare.post_thread(pseudoTerminalId, callback);
    termareNative.setNonblock(pseudoTerminalId!);

    /// 释放动态申请的空间
    calloc.free(argv);
    calloc.free(envp);
    // malloc.free(processId);
    print('<- processId.value : ${processId.value} ->');
    // read();
    return UnixProc(pid);
  }

  @override
  void resize(int row, int column) {
    termareNative.setPtyWindowSize(pseudoTerminalId!, row, column);
  }

  @override
  Future<List<int>> read() async {
    return readSync();
  }

  @override
  String getTtyPath() {
    throw UnimplementedError();
    // CStdlib cstdlib;
    // DynamicLibrary dynamicLibrary = DynamicLibrary.process();
    // cstdlib = CStdlib(dynamicLibrary);
    // Pointer<Int8> devname = allocate<Int8>();
    // // 获得pts路径
    // devname = cstdlib.ptsname(pseudoTerminalId).cast();
    // String result = Utf8.fromUtf8(devname.cast());
    // free(devname);
    // return result;
  }

  @override
  int? pseudoTerminalId;

  @override
  void startPolling() {
    _startPolling();
  }

  final _out = StreamController<List<int>>();
  Future<void> _startPolling() async {
    while (true) {
      final List<int> list = readSync();
      if (list.isNotEmpty) {
        _out.sink.add(list);
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  Stream<List<int>>? out;
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! PseudoTerminal) {
      return false;
    }
    if (other is PseudoTerminal) {
      return other.hashCode == hashCode;
    }
    return false;
  }

  @override
  int get hashCode => pseudoTerminalId.hashCode;
}
