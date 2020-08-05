// 从isolate中读取

import 'dart:ffi';
import 'dart:isolate';

import 'package:dart_pty/src/unix/cunistd.dart';
import 'package:ffi/ffi.dart';

Pointer<Int8> readSync(int fd, {bool verbose = false}) {
  CUnistd cunistd = CUnistd(DynamicLibrary.process());
  //动态申请空间
  Pointer<Int8> str = allocate(count: 4097);
  //read函数返回从fd中读取到字符的长度
  //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
  int length = cunistd.read(fd, str.cast(), 4096);
  if (length == -1) {
    free(str);
    return Pointer<Int8>.fromAddress(0);
  } else {
    str[length] = 0;
    return str;
  }
}

class IsolateRead {
  // 将阻塞ui的方法通过isolate读取并异步返回
  Isolate isolate;
  SendPort sendPort;

  Stream<dynamic> receiveAsBroadcastStream;
  Future<List<int>> read(
    int fileDescriptor,
  ) async {
    final ReceivePort receive = ReceivePort();
    isolate ??= await Isolate.spawn(runTimer, receive.sendPort);
    receiveAsBroadcastStream ??= receive.asBroadcastStream();
    // 这个定义是用来接收子isolate那边的SendPort
    List<int> result = [];
    print('isolate启动');
    if (sendPort == null) {
      await receiveAsBroadcastStream.every(
        (dynamic data) {
          print('来自子isolate的消息====>$data');
          sendPort = data as SendPort;
          return false;
        },
      );
    }
    sendPort?.send(fileDescriptor);
    await receiveAsBroadcastStream.every((dynamic data) {
      print('来自子isolate的消息====>$data');
      if (sendPort == null) {
        sendPort = data as SendPort;
        return true;
      } else {
        result = data as List<int>;
        return false;
      }
    });
    return result;
  }
}

Future<void> runTimer(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  // 将这边的一个ReceivePort对象发给主isolate
  sendPort.send(receivePort.sendPort);
  receivePort.listen((dynamic message) {
    print('来自主islate的消息===>$message');
    print('来自主islate的消息类型===>${message.runtimeType}');
    Pointer<Int8> utf8 = readSync(message as int).cast();
    if (utf8 == null) {
      return null;
    }
    int len = 0;
    while (utf8.elementAt(++len).value != 0) {}
    List<int> units = List<int>(len);
    for (int i = 0; i < len; ++i) {
      units[i] = utf8.elementAt(i).value;
    }
    print('units=====>$units');
    sendPort.send(units);
  });
}
