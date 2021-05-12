import 'dart:convert';
import 'dart:io';

import 'package:dart_pty/src/interface/pseudo_terminal_interface.dart';

Future<void> main() async {
  final Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  String executable = 'sh';
  if (Platform.isWindows) {
    executable = 'wsl';
  }
  final PseudoTerminal pseudoTerminal = PseudoTerminal(
    executable: executable,
    environment: environment,
    libPath: './dynamic_library/libterm.dylib',
    workingDirectory: '/',
  );
  print('pseudoTerminal -> ${pseudoTerminal.getTtyPath()}');
  await Future<void>.delayed(const Duration(milliseconds: 100));

  final String result = utf8.decode(await pseudoTerminal.read());
  print('第一次进程的输出为:$result');
  pseudoTerminal.out!.transform(utf8.decoder).listen((line) {
    print('\x1b[31m' + '-' * 20 + 'result' + '-' * 20);
    print('\x1b[32m$line\x1b[31m');
    print('-' * 20 + 'result' + '-' * 20 + '\x1b[0m');
  });
  pseudoTerminal.startPolling();
  await Future.delayed(const Duration(milliseconds: 100), () async {
    while (true) {
      print('请向终端输入一些东西');
      final String input = stdin.readLineSync()!;
      input.split('').forEach((element) {
        pseudoTerminal.write(element);
      });
      pseudoTerminal.write('\n');

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
}
