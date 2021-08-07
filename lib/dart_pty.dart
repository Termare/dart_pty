library dart_pty;

import 'dart:ffi';

import 'package:dart_pty/src/native_header/generated_bindings.dart';

export 'src/interface/pseudo_terminal_interface.dart';

NativeLibrary? _nativeLibrary;
NativeLibrary get nativeLibrary {
  _nativeLibrary ??= NativeLibrary(DynamicLibrary.process());
  return _nativeLibrary!;
}
