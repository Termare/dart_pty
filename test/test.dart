import 'dart:io';

import 'package:dart_pty/src/pseudo_terminal.dart';
import 'package:dart_pty/src/unix_pty_c.dart';

Future<void> main() async {
  Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  PseudoTerminal pseudoTerminal = PseudoTerminal();
  String executable = 'sh';
  if (Platform.isWindows) {
    executable = 'cmd';
  }
  pseudoTerminal.createSubprocess(
    executable,
    environment: environment,
  );
  print('pseudoTerminal -> ${pseudoTerminal.getTtyPath()}');
  await Future.delayed(Duration(milliseconds: 100));
  String result;
  print('第一次进程的输出为:${pseudoTerminal.readSync()}');
  await Future.delayed(Duration(milliseconds: 100), () async {
    while (true) {
      print('请向终端输入一些东西');
      String input = stdin.readLineSync();
      pseudoTerminal.write(input + '\n');
      await Future.delayed(Duration(milliseconds: 200));
      result = pseudoTerminal.readSync();
      print('\x1b[31m' + '-' * 20 + 'result' + '-' * 20);
      print('result -> $result');
      print('-' * 20 + 'result' + '-' * 20 + '\x1b[0m');
      await Future.delayed(Duration(milliseconds: 100));
    }
  });
}
