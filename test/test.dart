import 'dart:io';

import 'package:dart_pty/src/interface/pseudo_terminal_interface.dart';

Future<void> main() async {
  final Map<String, String> environment = {
    'TERM': 'xterm-256color',
  };
  String executable = 'bash';
  if (Platform.isWindows) {
    executable = 'wsl';
  }
  final PseudoTerminal pseudoTerminal = PseudoTerminal(
    executable: executable,
    environment: environment,
    workingDirectory: '/',
  );
  await Future<void>.delayed(const Duration(milliseconds: 100));
  pseudoTerminal.out!.listen((line) {
    print('\x1b[31m' + '>' * 40);
    print('\x1b[32m$line');
    print('\x1b[31m' + '<' * 40);
  });
  pseudoTerminal.startPolling();
  await Future.delayed(const Duration(milliseconds: 100), () async {
    while (true) {
      final String input = stdin.readLineSync()!;
      if(input=='exit'){
        pseudoTerminal.close();
      }
      input.split('').forEach((element) {
        pseudoTerminal.write(element);
      });
      pseudoTerminal.write('\n');
      pseudoTerminal.schedulingRead();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
}
