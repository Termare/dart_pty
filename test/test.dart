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
    executable: 'ssh',
    environment: environment,
    workingDirectory: '/',
    arguments:
        '-o PreferredAuthentications=password -o PubkeyAuthentication=no -o PasswordAuthentication=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null nightmare@nightmare.fun'
            .split(' '),
    useIsolate: true,
  );
  await Future<void>.delayed(const Duration(milliseconds: 100));
  pseudoTerminal.startPolling();
  pseudoTerminal.out!.listen((line) {
    print('--->$line');
    if (RegExp('yes/no').hasMatch(line)) {
      pseudoTerminal.write('yes\n');
    } else if (RegExp('assword:').hasMatch(line)) {
      pseudoTerminal.write('xxx\n');
    } else if (RegExp('Select account').hasMatch(line)) {
      pseudoTerminal.write('2\n');
    } else if (RegExp('~]').hasMatch(line)) {
      pseudoTerminal.write('./run.sh\n');
    } else {
      print(line);
    }

    pseudoTerminal.schedulingRead();
  });
}
