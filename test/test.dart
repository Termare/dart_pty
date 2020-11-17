import 'package:dart_pty/src/unix_pty_c.dart';

Future<void> main() async {
  Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  UnixPtyC unixPthC = UnixPtyC(environment: environment);
  unixPthC.write('env\n');
  await Future.delayed(Duration(milliseconds: 100));
  String result;
  // result = unixPthC.read();
  // print('result->$result');
  unixPthC.write('echo \$TEST\n');
  await Future.delayed(Duration(milliseconds: 100));
  result = unixPthC.read();
  print('result->$result');
}
