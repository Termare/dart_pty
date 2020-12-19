import 'dart:io';

import 'proc.dart';
import 'unix_pty_c.dart';
import 'win_pty.dart';

// 抽象函数的思想完全借鉴 pty 的代码.
abstract class PseudoTerminal {
  factory PseudoTerminal({
    int row = 25,
    int column = 80,
  }) {
    if (Platform.isWindows) {
      return WinPty();
    } else {
      // TODO
      String dylibPath = '';
      if (Platform.isMacOS) {
        dylibPath =
            '/Users/nightmare/Desktop/termare-space/dart_pty/dynamic_library/libterm.dylib';
      } else if (Platform.isLinux) {
        dylibPath = 'dynamic_library/libterm.so';
      } else if (Platform.isAndroid) {
        dylibPath = 'libterm.so';
      }
      return UnixPtyC(
        rowLen: row,
        columnLen: column,
        libPath: dylibPath,
      );
    }
  }

  String readSync();

  Future<String> read();

  void write(String data);

  void resize(int row, int column);

  Proc createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments,
    Map<String, String> environment,
  });

  String getTtyPath();
  // void close();
}
