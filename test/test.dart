import 'dart:io';

import 'package:dart_pty/src/pseudo_terminal.dart';

Future<void> main() async {
  final Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  String executable = 'sh';
  if (Platform.isWindows) {
    executable = 'cmd';
  }
  final PseudoTerminal pseudoTerminal = PseudoTerminal(
    executable: executable,
    environment: environment,
  );
  print('pseudoTerminal -> ${pseudoTerminal.getTtyPath()}');
  await Future<void>.delayed(const Duration(milliseconds: 100));
  String result;
  print('第一次进程的输出为:${await pseudoTerminal.read()}');
  // return;
  await Future.delayed(const Duration(milliseconds: 100), () async {
    while (true) {
      print('请向终端输入一些东西');
      final String input = stdin.readLineSync();
      input.split('').forEach((element) {
        pseudoTerminal.write(element);
      });
      pseudoTerminal.write('\r\n');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      result = await pseudoTerminal.read();
      print('\x1b[31m' + '-' * 20 + 'result' + '-' * 20);
      print('result -> $result');
      print('-' * 20 + 'result' + '-' * 20 + '\x1b[0m');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
}
