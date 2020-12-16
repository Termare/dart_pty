import 'dart:io';

import 'package:dart_pty/src/pty.dart';
import 'package:dart_pty/src/unix_pty_c.dart';

Future<void> main() async {
  if (Platform.isWindows) {
    Pty pty = Pty();
    pty.exec('C:\\windows\\system32\\cmd.exe');
    await Future.delayed(Duration(milliseconds: 100));
    String result;
    // pty.read();
    await Future.delayed(Duration(milliseconds: 100), () async {
      while (true) {
        print('请向终端输入一些东西');
        String input = stdin.readLineSync();
        pty.write(input + '\n\r');
        await Future.delayed(Duration(milliseconds: 200));
        result = await pty.read();
        print('\x1b[31m' + '-' * 20 + 'result' + '-' * 20);
        print('result -> $result');
        print('-' * 20 + 'result' + '-' * 20 + '\x1b[0m');
        await Future.delayed(Duration(milliseconds: 100));
      }
    });
    return;
  }
  Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  UnixPtyC unixPthC = UnixPtyC(
    environment: environment,
    libPath: Platform.isMacOS
        ? 'dynamic_library/libterm.dylib'
        : 'dynamic_library/libterm.so',
  );
  await Future.delayed(Duration(milliseconds: 100));
  String result;
  unixPthC.read();
  await Future.delayed(Duration(milliseconds: 100), () async {
    while (true) {
      print('请向终端输入一些东西');
      String input = stdin.readLineSync();
      unixPthC.write(input + '\n');
      await Future.delayed(Duration(milliseconds: 200));
      result = unixPthC.read();
      print('\x1b[31m' + '-' * 20 + 'result' + '-' * 20);
      print('result -> $result');
      print('-' * 20 + 'result' + '-' * 20 + '\x1b[0m');
      await Future.delayed(Duration(milliseconds: 100));
    }
  });
}
