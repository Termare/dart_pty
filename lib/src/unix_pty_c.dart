// 整个代码是c写的，dart负责调用
import 'dart:ffi';
import 'dart:io';

import 'package:dart_pty/src/proc.dart';
import 'package:ffi/ffi.dart';

import 'pseudo_terminal.dart';
import 'unix/term.dart';
import 'utils/custom_utf.dart';

// 这个需要配合c语言实现
class UnixPtyC implements PseudoTerminal {
  final NiUtf _niUtf = NiUtf();
  final String libPath;
  final int rowLen;
  final int columnLen;
  CTermare cTermare;
  int pseudoTerminalId;

  UnixPtyC({
    this.rowLen,
    this.columnLen,
    this.libPath,
  }) {
    DynamicLibrary dynamicLibrary;
    if (libPath != null) {
      dynamicLibrary = DynamicLibrary.open(libPath);
    } else {
      dynamicLibrary = DynamicLibrary.process();
    }
    cTermare = CTermare(dynamicLibrary);
    pseudoTerminalId = cTermare.create_ptm(rowLen, columnLen);
    print('<- pseudoTerminalId : $pseudoTerminalId ->');
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

  String readSync() {
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

  @override
  Proc createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments,
    Map<String, String> environment = const <String, String>{
      'TERM': 'screen-256color',
    },
  }) {
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

    cTermare.create_subprocess(
      Pointer<Int8>.fromAddress(0),
      Utf8.toUtf8(executable).cast(),
      Utf8.toUtf8('/').cast(),
      argv.cast(),
      envp.cast(),
      processId,
      pseudoTerminalId,
    );
    cTermare.setNonblock(pseudoTerminalId);
    // TODO
    /// 释放动态申请的空间
    // free(argv);
    // free(envp);
    // free(processId);
    print('<- processId.value : ${processId.value} ->');
    // read();
  }

  @override
  void resize(int row, int column) {
    // TODO: implement resize
  }

  @override
  Future<String> read() {
    // TODO: implement read
    throw UnimplementedError();
  }
}
