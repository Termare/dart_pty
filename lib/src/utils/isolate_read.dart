// 从isolate中读取

import 'dart:isolate';

import 'package:ffi/ffi.dart';

// class IsolateRead {
//   // 将阻塞ui的方法通过isolate读取并异步返回
//   static Future<Utf8> read(
//     Utf8 Function(int fd) string,
//     int fileDescriptor,
//   ) async {
//     final ReceivePort receive = ReceivePort();
//     final Isolate isolate = await Isolate.spawn(runTimer, receive.sendPort);
//     SendPort sendPort;

//     print('isolate启动');
//     void listen(SendPort data) {
//       sendPort = data;
//       sendPort.send(fileDescriptor);
//     }

//     receive.listen((dynamic data) {
//       if (sendPort == null) {
//         listen(data as SendPort);
//       } else {}
//       print('来自子isolate的消息====>$data');
//     });
//   }
// }

// Future<void> runTimer(SendPort sendPort) async {
//   final ReceivePort receivePort = ReceivePort();
//   sendPort.send(receivePort.sendPort);
//   receivePort.listen((dynamic message) {
//     Utf8 utf8=await string();
//     print('来自主islate的消息===>$message');
//   });
//   sendPort.send('message');
// }
