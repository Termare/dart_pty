import 'dart:io';
import 'dart:typed_data';

import '../proc.dart';
import '../unix_pty.dart';
import '../unix_pty_c.dart';
import '../win_pty.dart';

// 抽象函数的思想完全借鉴 pty 的代码.
abstract class PseudoTerminal {
  factory PseudoTerminal({
    int row = 25,
    int column = 80,
    String? executable,
    String workingDirectory = '.',
    List<String> arguments = const [],
    Map<String, String> environment = const <String, String>{
      'TERM': 'xterm-256color',
    },
    String? libPath,
    bool useIsolate = false,
  }) {
    // TODO
    if (Platform.isMacOS) {
      // print('\x1b[32m您将 dart_paty 运行在 macOS 下，请注意 so 库的引入 ');
      // libPath = Platform.resolvedExecutable.replaceAll(
      //   RegExp('\\.app/.*'),
      //   r'.app/',
      // );
      // libPath += 'Contents/Frameworks/App.framework/';
      // libPath += 'Resources/flutter_assets/assets/lib/libterm.dylib';
      return UnixPty(
        rowLen: row,
        columnLen: column,
        workingDirectory: workingDirectory,
        executable: executable,
        arguments: arguments,
        environment: environment,
        useIsolate: true,
      );
    } else if (Platform.isLinux) {
      libPath ??= 'dynamic_library/libterm.so';
    } else if (Platform.isAndroid) {
      libPath = 'libterm.so';
    } else if (Platform.isWindows) {
      // return WinPty(
      //   rowLen: row,
      //   columnLen: column,
      //   workingDirectory: workingDirectory,
      //   executable: executable,
      //   arguments: arguments,
      //   environment: environment,
      // );
    }

    return UnixPty(
      rowLen: row,
      columnLen: column,
      workingDirectory: workingDirectory,
      executable: executable,
      arguments: arguments,
      environment: environment,
      useIsolate: const bool.fromEnvironment('dart.vm.product'),
    );
  }

  late int pseudoTerminalId;
  Stream<String>? out;

  Uint8List? readSync();

  Uint8List? read();

  void write(String data);

  void resize(int row, int column);

  // Proc createSubprocess(
  //   String executable, {
  //   String workingDirectory = '.',
  //   List<String> arguments,
  //   Map<String, String> environment,
  // });

  String getTtyPath();
  // void close();

  void startPolling();
  void schedulingRead();
}
