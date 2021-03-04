// // 从isolate中读取

// import 'dart:async';
// import 'dart:ffi';
// import 'dart:isolate';

// import 'package:dart_pty/src/unix/cunistd.dart';
// import 'package:ffi/ffi.dart';

// class IsolateRead {
//   IsolateRead() {
//     init();
//   }
//   // 将阻塞ui的方法通过isolate读取并异步返回
//   Isolate isolate;
//   SendPort sendPort;

//   Stream<dynamic> receiveAsBroadcastStream;
//   final ReceivePort receive = ReceivePort();
//   Future<void> init() async {}

//   Future<List<int>> read(
//     int fileDescriptor,
//   ) async {
//     List<int> result = [];
//     isolate ??=
//         await Isolate.spawn(readFileDescriptorIsolate, receive.sendPort);
//     // sendPort = await receive.first as SendPort;
//     receiveAsBroadcastStream ??= receive.asBroadcastStream();
//     if (sendPort == null) {
//       await receiveAsBroadcastStream.every(
//         (dynamic data) {
//           print('来自子isolate的消息====>$data');
//           sendPort = data as SendPort;
//           // return false会马上退出监听
//           return false;
//         },
//       );
//     }
//     // debugPrintWithColor(
//     //   'isolate启动',
//     //   backgroundColor: PrintColor.white,
//     //   fontColor: PrintColor.red,
//     // );
//     // 这个定义是用来接收子isolate那边的SendPort
//     // 发送本次需要读取的文件描述符
//     sendPort?.send(fileDescriptor);
//     // result = await receive.first;
//     // print('来自子isolate的单次消息====>$result');
//     await receiveAsBroadcastStream.every((dynamic data) {
//       print('来自子isolate的消息====>$data');

//       result = data as List<int>;
//       return false;
//     });
//     return result;
//   }
// }

// Future<void> readFileDescriptorIsolate(SendPort sendPort) async {
//   Pointer<Uint8> readSync(int fd, {bool verbose = false}) {
//     CUnistd cunistd = CUnistd(DynamicLibrary.process());
//     //动态申请空间
//     Pointer<Uint8> str = allocate<Uint8>(count: 4097);
//     //read函数返回从fd中读取到字符的长度
//     //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
//     int length = cunistd.read(fd, str.cast(), 4096);
//     print('readFileDescriptorIsolate方法读取数据长度为>>>>>>>$length');
//     if (length == -1) {
//       free(str);
//       return Pointer<Uint8>.fromAddress(0);
//     } else {
//       str[length] = 0;
//       return str;
//     }
//   }

//   print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>子Isolate启动');
//   final ReceivePort receivePort = ReceivePort();
//   // 将这边的一个ReceivePort对象发给主isolate
//   sendPort.send(receivePort.sendPort);
//   receivePort.listen((dynamic message) {
//     print('来自主islate的消息===>$message');
//     print('来自主islate的消息类型===>${message.runtimeType}');
//     Pointer<Uint8> utf8 = readSync(message as int).cast<Uint8>();
//     if (utf8 == null) {
//       return;
//     }
//     int len = 0;
//     while (utf8.elementAt(++len).value != 0) {}
//     List<int> units = List<int>(len);
//     for (int i = 0; i < len; ++i) {
//       units[i] = utf8.elementAt(i).value;
//     }
//     print('units=====>$units');
//     sendPort.send(units);
//     // free(utf8);
//   });
// }
