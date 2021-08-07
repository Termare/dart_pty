import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_pty/src/native_header/generated_bindings.dart';
import 'package:ffi/ffi.dart';

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
}
