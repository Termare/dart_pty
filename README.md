# dart_pty

Language: [English](README.md) | 中文简体

## 介绍

创建一个伪终端并执行一个子进程。

## 使用方法
参考 [test.dart](test/test.dart)
```dart
Future<void> main() async {
  Map<String, String> environment = {'TEST': 'TEST_VALUE'};
  UnixPtyC unixPthC = UnixPtyC(
    environment: environment,
    libPath: 'dynamic_library/libterm.dylib',
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
      print('-' * 20 + 'result' + '-' * 20);
      print('result -> $result');
      print('-' * 20 + 'result' + '-' * 20);
      await Future.delayed(Duration(milliseconds: 100));
    }
  });
}
```
[截图](screencap/screencap.png)