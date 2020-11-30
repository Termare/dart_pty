# dart_pty

Language: English | [中文简体](README-CN.md)

## introduction

create pseudo terminal and fork process use dart.

## Usage
```dart
Map<String,String> environment = {'TEST':'TEST_VALUE'};
UnixPtyC unixPthC = UnixPtyC(environment: environment);
unixPthC.write('env');
String result = unixPthC.read();
```