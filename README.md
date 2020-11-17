# dart_pty

Language: [English](README.md) | 中文简体

## 介绍

创建一个伪终端并执行一个子进程。

## 使用方法
```dart
Map<String,String> environment = {'TEST':'TEST_VALUE'};
UnixPtyC unixPthC = UnixPtyC(environment: environment);
unixPthC.write('env');
String result = unixPthC.read();
```