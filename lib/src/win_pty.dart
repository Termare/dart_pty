// import 'dart:async';
// import 'dart:ffi';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:ffi/ffi.dart';
// // import 'package:pty/src/util/win32_additional.dart';
// import 'package:win32/win32.dart' as win32;

// import 'interface/pseudo_terminal_interface.dart';

// class _NamedPipe {
//   _NamedPipe({bool nowait = false}) {
//     final pipeName = r'\\.\pipe\dart-pty-pipe';
//     final pPipeName = pipeName.toNativeUtf16();

//     final waitMode = nowait ? win32.PIPE_NOWAIT : win32.PIPE_WAIT;

//     final namedPipe = win32.CreateNamedPipe(
//       pPipeName,
//       win32.PIPE_ACCESS_DUPLEX,
//       waitMode | win32.PIPE_READMODE_MESSAGE | win32.PIPE_TYPE_MESSAGE,
//       win32.PIPE_UNLIMITED_INSTANCES,
//       4096,
//       4096,
//       0,
//       nullptr,
//     );

//     if (namedPipe == win32.INVALID_HANDLE_VALUE) {
//       throw PtyException('CreateNamedPipe failed: ${win32.GetLastError()}');
//     }

//     final namedPipeClient = win32.CreateFile(
//       pPipeName,
//       win32.GENERIC_READ | win32.GENERIC_WRITE,
//       0, // no sharing
//       nullptr, // default security attributes
//       win32.OPEN_EXISTING, // opens existing pipe ,
//       0, // default attributes
//       0, // no template file
//     );
//     calloc.free(pPipeName);

//     if (namedPipeClient == win32.INVALID_HANDLE_VALUE) {
//       throw PtyException('CreateFile on named pipe failed');
//     }

//     readSide = namedPipe;
//     writeSide = namedPipeClient;
//   }

//   late final int readSide;
//   late final int writeSide;
// }

// class WinPty implements PseudoTerminal {
//   WinPty({
//     required this.rowLen,
//     required this.columnLen,
//     String? executable,
//     List<String> arguments = const [],
//     String? workingDirectory,
//     Map<String, String> environment = const {},
//     bool blocking = false,
//   }) {
//     // create input pipe
//     out = _out.stream.asBroadcastStream();
//     final hReadPipe = calloc<IntPtr>();
//     final hWritePipe = calloc<IntPtr>();
//     final pipe2 = win32.CreatePipe(hReadPipe, hWritePipe, nullptr, 512);
//     if (pipe2 == win32.INVALID_HANDLE_VALUE) {
//       throw PtyException('CreatePipe failed: ${win32.GetLastError()}');
//     }
//     final inputWriteSide = hWritePipe.value;
//     final inputReadSide = hReadPipe.value;

//     // create output pipe
//     final pipe1 = _NamedPipe(nowait: !blocking);
//     final outputReadSide = pipe1.readSide;
//     final outputWriteSide = pipe1.writeSide;

//     // final pipe2 = _NamedPipe(nowait: false);
//     // final inputWriteSide = pipe2.writeSide;
//     // final inputReadSide = pipe2.readSide;

//     // create pty
//     final hPty = calloc<IntPtr>();
//     final size = calloc<win32.COORD>().ref;
//     size.X = 80;
//     size.Y = 25;
//     final hr = win32.CreatePseudoConsole(
//       size,
//       inputReadSide,
//       outputWriteSide,
//       0,
//       hPty,
//     );

//     if (win32.FAILED(hr)) {
//       throw PtyException('CreatePseudoConsole failed.');
//     }

//     // Setup startup info
//     final si = calloc<win32.STARTUPINFOEX>();
//     si.ref.StartupInfo.cb = sizeOf<win32.STARTUPINFOEX>();

//     // Explicitly set stdio of the child process to NULL. This is required for
//     // ConPTY to work properly.
//     si.ref.StartupInfo.hStdInput = nullptr.address;
//     si.ref.StartupInfo.hStdOutput = nullptr.address;
//     si.ref.StartupInfo.hStdError = nullptr.address;
//     si.ref.StartupInfo.dwFlags = win32.STARTF_USESTDHANDLES;

//     final bytesRequired = calloc<IntPtr>();
//     win32.InitializeProcThreadAttributeList(nullptr, 1, 0, bytesRequired);
//     si.ref.lpAttributeList = calloc<Int8>(bytesRequired.value);

//     var ret = win32.InitializeProcThreadAttributeList(
//         si.ref.lpAttributeList, 1, 0, bytesRequired);

//     if (ret == win32.FALSE) {
//       throw PtyException('InitializeProcThreadAttributeList failed.');
//     }

//     // use pty
//     ret = win32.UpdateProcThreadAttribute(
//       si.ref.lpAttributeList,
//       0,
//       win32.PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE,
//       Pointer.fromAddress(hPty.value),
//       sizeOf<IntPtr>(),
//       nullptr,
//       nullptr,
//     );

//     if (ret == win32.FALSE) {
//       throw PtyException('UpdateProcThreadAttribute failed.');
//     }

//     // build command line
//     final commandBuffer = StringBuffer();
//     commandBuffer.write(executable);
//     if (arguments.isNotEmpty) {
//       for (var argument in arguments) {
//         commandBuffer.write(' ');
//         commandBuffer.write(argument);
//       }
//     }
//     final pCommandLine = commandBuffer.toString().toNativeUtf16();

//     // build current directory
//     Pointer<Utf16> pCurrentDirectory = nullptr;
//     if (workingDirectory != null) {
//       pCurrentDirectory = workingDirectory.toNativeUtf16();
//     }

//     // build environment
//     Pointer<Utf16> pEnvironment = nullptr;
//     if (environment != null && environment.isNotEmpty) {
//       final buffer = StringBuffer();

//       for (var env in environment.entries) {
//         buffer.write(env.key);
//         buffer.write('=');
//         buffer.write(env.value);
//         buffer.write('\u0000');
//       }

//       pEnvironment = buffer.toString().toNativeUtf16();
//     }

//     // start the process.
//     final pi = calloc<win32.PROCESS_INFORMATION>();
//     ret = win32.CreateProcess(
//       nullptr,
//       pCommandLine,
//       nullptr,
//       nullptr,
//       win32.FALSE,
//       win32.EXTENDED_STARTUPINFO_PRESENT | win32.CREATE_UNICODE_ENVIRONMENT,
//       // pass pEnvironment here causes crash
//       // TODO: fix this
//       // pEnvironment,
//       nullptr,
//       pCurrentDirectory,
//       si.cast(),
//       pi,
//     );

//     calloc.free(pCommandLine);

//     if (pCurrentDirectory != nullptr) {
//       calloc.free(pCurrentDirectory);
//     }

//     if (pEnvironment != nullptr) {
//       calloc.free(pEnvironment);
//     }

//     if (ret == 0) {
//       throw PtyException('CreateProcess failed: ${win32.GetLastError()}');
//     }
//     _inputWriteSide = inputWriteSide;
//     _outputReadSide = outputReadSide;
//     _hPty = hPty.value;
//     _hProcess = pi.ref.hProcess;
//   }

//   final int rowLen;
//   final int columnLen;
//   late int _inputWriteSide;
//   late int _outputReadSide;
//   late int _hPty;
//   late int _hProcess;

//   static const _bufferSize = 4096;
//   final _buffer = calloc<Int8>(_bufferSize + 1).address;

//   @override
//   Future<List<int>> read() async {
//     return readSync();
//   }

//   @override
//   int? exitCodeNonBlocking() {
//     final exitCodePtr = calloc<Uint32>();
//     final ret = win32.GetExitCodeProcess(_hProcess, exitCodePtr);

//     final exitCode = exitCodePtr.value;
//     calloc.free(exitCodePtr);

//     const STILL_ACTIVE = 259;
//     if (ret == 0 || exitCode == STILL_ACTIVE) {
//       return null;
//     }

//     return exitCode;
//   }

//   @override
//   int exitCodeBlocking() {
//     const n = 1;
//     final pid = calloc<IntPtr>(n);
//     final infinite = 0xFFFFFFFF;
//     pid.elementAt(0).value = _hProcess;
//     win32.MsgWaitForMultipleObjects(n, pid, 1, infinite, win32.QS_ALLEVENTS);
//     return pid.elementAt(0).value;
//   }

//   @override
//   bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
//     final ret = win32.TerminateProcess(_hProcess, nullptr.address);
//     win32.ClosePseudoConsole(_hPty);
//     return ret != 0;
//   }

//   @override
//   void resize(int width, int height) {
//     final size = calloc<win32.COORD>();
//     size.ref.X = height;
//     size.ref.Y = width;
//     final hr = win32.ResizePseudoConsole(_hPty, size.ref);
//     if (win32.FAILED(hr)) {
//       throw PtyException('ResizePseudoConsole failed.');
//     }
//     calloc.free(size);
//   }

//   // @override
//   // int get pid {
//   //   return _hProcess;
//   // }

//   @override
//   void write(String data) {
//     final buffer = data.toNativeUtf8();
//     final written = calloc<Uint32>();
//     win32.WriteFile(_inputWriteSide, buffer, data.length, written, nullptr);
//     calloc.free(buffer);
//     calloc.free(written);
//   }

//   @override
//   Stream<List<int>>? out;

//   @override
//   late int pseudoTerminalId;

//   @override
//   String getTtyPath() {
//     // TODO: implement getTtyPath
//     throw UnimplementedError();
//   }

//   @override
//   Uint8List? readSync() {
//     final pReadlen = calloc<Uint32>();
//     final buffer = Pointer.fromAddress(_buffer);
//     final ret = win32.ReadFile(
//       _outputReadSide,
//       buffer,
//       _bufferSize,
//       pReadlen,
//       nullptr,
//     );

//     final readlen = pReadlen.value;
//     calloc.free(pReadlen);

//     if (ret == 0) {
//       return [];
//     }

//     if (readlen <= 0) {
//       return [];
//     } else {
//       return buffer.cast<Uint8>().asTypedList(readlen);
//     }
//   }

//   @override
//   void startPolling() {
//     _startPolling();
//   }

//   final _out = StreamController<List<int>>();
//   Future<void> _startPolling() async {
//     while (true) {
//       final List<int> list = readSync();
//       if (list.isNotEmpty) {
//         _out.sink.add(list);
//       }
//       await Future<void>.delayed(const Duration(milliseconds: 20));
//     }
//   }
// }

// // void rawWait(int hProcess) {
// //   // final status = allocate<Int32>();
// //   // unistd.waitpid(pid, status, 0);
// //   final count = 1;
// //   final pids = calloc<IntPtr>(count);
// //   final infinite = 0xFFFFFFFF;
// //   pids.elementAt(0).value = hProcess;
// //   win32.MsgWaitForMultipleObjects(count, pids, 1, infinite, win32.QS_ALLEVENTS);
// // }
// class PtyException implements Exception {
//   PtyException(this.message);

//   final String message;

//   @override
//   String toString() {
//     return message;
//   }
// }
