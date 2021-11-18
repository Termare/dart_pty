import 'dart:io';
import 'dart:typed_data';
import '../unix_pty.dart';

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
    bool? useIsolate,
  }) {
    // TODO
    if (Platform.isMacOS) {
    } else if (Platform.isLinux) {
    } else if (Platform.isAndroid) {
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
      useIsolate: useIsolate ?? const bool.fromEnvironment('dart.vm.product'),
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
  void close();

  void startPolling();
  void schedulingRead();
}
