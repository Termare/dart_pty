import 'dart:ffi';

import 'unix/term.dart';
import 'utils/custom_utf.dart';

final NiUtf _niUtf = NiUtf();

class FileDescriptor {
  static CTermare cTermare;
  static String readSync(int fd) {
    if (cTermare == null) {
      const String libPath = 'libterm.so';
      DynamicLibrary dynamicLibrary;
      if (libPath != null) {
        dynamicLibrary = DynamicLibrary.open(libPath);
      } else {
        dynamicLibrary = DynamicLibrary.process();
      }
      cTermare = CTermare(dynamicLibrary);
    }
    // print('读取');
    final Pointer<Uint8> resultPoint = cTermare.get_output_from_fd(fd).cast();
    // 代表空指针
    if (resultPoint.address == 0) {
      // 释放内存
      // free(resultPoint);
      return '';
    }
    final String result = _niUtf.cStringtoString(resultPoint);
    return result;
  }
}
