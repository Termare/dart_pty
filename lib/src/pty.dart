import 'dart:io';

import 'proc.dart';
import 'win_pty.dart';

abstract class Pty {
  factory Pty() {
    if (Platform.isWindows) {
      return WinPty();
    }
  }

  String readSync();

  Future<String> read();

  void write(String data);

  void resize(int width, int height);

  Proc exec(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments,
    List<String> environment,
  });

  // void close();
}
