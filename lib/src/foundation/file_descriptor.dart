import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pty/src/native_header/generated_bindings.dart';
import 'package:ffi/ffi.dart';
import 'package:signale/signale.dart';

class FileDescriptor {
  const FileDescriptor(this.fd, this.nativeLibrary);
  final int fd;
  final NativeLibrary nativeLibrary;

  Uint8List? read(int length) {
    //动态申请空间
    final Pointer<Uint8> resultPoint = calloc<Uint8>(length + 1);
    final int len = nativeLibrary.read(fd, resultPoint.cast(), length);
    if (len <= 0) {
      calloc.free(resultPoint);
      return null;
    } else {
      return resultPoint.asTypedList(len);
    }
  }

  void setNonblock(int fd, {bool verbose = true}) {
    int flag = -1;
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('当前flag = $flag', tag: 'FileDescriptor');
    flag |= Platform.isAndroid ? O_NONBLOCK_ANDROID : O_NONBLOCK; //设置新falg
    Log.d('设置新flag = $flag', tag: 'FileDescriptor');
    nativeLibrary.fcntl(fd, F_SETFL, flag); //更新flag
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('再次获取到的flag = $flag', tag: 'FileDescriptor');
  }
}
