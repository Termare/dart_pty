import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_pty/dart_pty.dart';
import 'package:dart_pty/src/foundation/file_descriptor.dart';
import 'package:dart_pty/src/unix_proc.dart';
import 'package:ffi/ffi.dart';
import 'package:signale/signale.dart';

import 'interface/pseudo_terminal_interface.dart';
import 'native_header/generated_bindings.dart';
import 'proc.dart';

// TODO
// termare;

class UnixPty implements PseudoTerminal {
  UnixPty({
    required this.rowLen,
    required this.columnLen,
    String? executable,
    String workingDirectory = '',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
    this.useIsolate = false,
  }) {
    out = _out.stream.asBroadcastStream();
    // 这个函数实现的功能是完整的
    pseudoTerminalId = createPseudoTerminal();
    fd = FileDescriptor(pseudoTerminalId, nativeLibrary);
    if (!useIsolate) {
      fd.setNonblock(pseudoTerminalId);
    }
    _createSubprocess(
      executable!,
      workingDirectory: workingDirectory,
      arguments: arguments,
      environment: environment,
    );
  }
  Isolate? readIsolate;
  // 创建一个pty，返回它的ptm文本描述符，这个ptm在之后的读写，fork子进程还会用到
  int createPseudoTerminal() {
    Log.d('Create Start', tag: 'Term');
    final ptmxPath = '/dev/ptmx'.toNativeUtf8();
    final int ptm = nativeLibrary.open(
      ptmxPath.cast<Int8>(),
      O_RDWR | O_CLOEXEC,
    );
    if (nativeLibrary.grantpt(ptm) != 0 || nativeLibrary.unlockpt(ptm) != 0) {
      // 说明二者有一个失败
      Log.e('Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx');
      return -1;
    }
    final Pointer<termios> tios = calloc<termios>();
    // addressOf 可以获取指针
    nativeLibrary.tcgetattr(ptm, tios);
    tios.ref.c_iflag |= IUTF8;
    tios.ref.c_iflag &= ~(IXON | IXOFF);
    nativeLibrary.tcsetattr(ptm, TCSANOW, tios);
    // free(tios);
    // =========== 设置终端大小 =============
    final Pointer<winsize> size = calloc<winsize>();
    size.ref.ws_row = rowLen;
    size.ref.ws_col = columnLen;
    nativeLibrary.ioctl(
      ptm,
      TIOCSWINSZ,
      size,
    );
    calloc.free(size);
    // free(ptmxPath);

    Log.d('Create End', tag: 'Term');
    Log.d('Ptm = $ptm', tag: 'Term');
    return ptm;
    // nativeLibrary.grantpt()
  }

  final bool useIsolate;
  late FileDescriptor fd;
  // final NiUtf _niUtf = NiUtf();
  final int rowLen;
  final int columnLen;

  @override
  late int pseudoTerminalId;
  late int pid;
  Proc? _createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
  }) {
    final List<String> fullArg = [executable, ...arguments];
    Pointer<Int8> devname = calloc<Int8>();
    // 获得pts路径
    devname = nativeLibrary.ptsname(pseudoTerminalId).cast();
    Log.d(devname.cast<Utf8>().toDartString());
    final int pid = nativeLibrary.fork();
    if (pid < 0) {
      Log.i('fork faild');
    } else if (pid > 0) {
      Log.i('fork 主进程');
      this.pid = pid;
      // 这里会返回子进程的pid
      return UnixProc(pid);
    } else {
      Log.i('fork 子进程');
      // Clear signals which the Android java process may have blocked:
      final Pointer<Uint32> signalsToUnblock = calloc<Uint32>();
      // sigset_t signals_to_unblock;
      Log.i('sigfillset start');
      nativeLibrary.sigfillset(signalsToUnblock);
      Log.i('sigfillset done');
      nativeLibrary.sigprocmask(
        SIG_UNBLOCK,
        signalsToUnblock,
        nullptr,
      );
      Log.i('sigprocmask done');
      nativeLibrary.close(pseudoTerminalId);
      Log.i('close done');
      nativeLibrary.setsid();
      Log.i('setsid done');
      final int pts = nativeLibrary.open(devname, O_RDWR);
      if (pts < 0) {
        return null;
      }
      nativeLibrary.dup2(pts, 0);
      nativeLibrary.dup2(pts, 1);
      nativeLibrary.dup2(pts, 2);
      Log.i('dup2 done');
      // final Pointer<DIR> selfDir = nativeLibrary.opendir(
      //   '/proc/self/fd'.toNativeUtf8().cast(),
      // );

      // if (selfDir.address != 0) {
      //   final int selfDirFd = nativeLibrary.dirfd(selfDir);
      //   Pointer<dirent> entry = calloc();
      //   entry = nativeLibrary.readdir(selfDir);
      //   while (entry != nullptr) {
      //     final int fd = nativeLibrary.atoi(entry.ref.d_name);
      //     if (fd > 2 && fd != selfDirFd) {
      //       nativeLibrary.close(fd);
      //     }
      //   }

      //   nativeLibrary.closedir(selfDir);
      // }
      // Log.d('初始化环境变量');
      // print('test');
      final Map<String, String> platformEnvironment = Map.from(
        Platform.environment,
      );
      for (final String key in environment.keys) {
        platformEnvironment[key] = environment[key]!;
      }

      for (int i = 0; i < platformEnvironment.keys.length; i++) {
        final String env =
            '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}';
        nativeLibrary.putenv(env.toNativeUtf8().cast());
      }

      final Pointer<Pointer<Utf8>> argv = calloc<Pointer<Utf8>>(
        fullArg.length + 1,
      );
      // Log.e('fullArg -> $fullArg');
      for (int i = 0; i < fullArg.length; i++) {
        argv[i] = fullArg[i].toNativeUtf8();
      }
      argv[fullArg.length] = nullptr;
      if (nativeLibrary.chdir(workingDirectory.toNativeUtf8().cast()) != 0) {
        // nativeLibrary.perror('切换工作目录失败'.toNativeUtf8().cast());
        // nativeLibrary.fflush(stderr);
        Log.e('切换工作目录失败');
        // stdout.flush();
        // stderr.write('\x1b[31m切换工作目录失败\x1b[0m');
        // stderr.flush();
        // stdout.write('切换工作目录失败');
        // stdout.flush();
      }
      nativeLibrary.execvp(
        executable.toNativeUtf8().cast(),
        argv.cast(),
      );
      Log.e('执行$executable命令失败');
    }
  }

  final _out = StreamController<String>();

  @override
  Stream<String>? out;

  static const bufferLimit = 81920;

  @override
  Uint8List? readSync() => fd.read(bufferLimit);

  @override
  void write(String data) {
    final Pointer<Utf8> utf8Pointer = data.toNativeUtf8();
    nativeLibrary.write(
      pseudoTerminalId,
      utf8Pointer.cast(),
      nativeLibrary.strlen(utf8Pointer.cast()),
    );
  }

  @override
  String getTtyPath() {
    Pointer<Int8> devname = calloc<Int8>();
    // 获得pts路径
    devname = nativeLibrary.ptsname(pseudoTerminalId);
    final String result = devname.cast<Utf8>().toDartString();
    // 下面代码引发crash
    // calloc.free(devname);
    return result;
  }

  @override
  void resize(int row, int column) {
    print('$this resize');
    final Pointer<winsize> size = calloc<winsize>();
    size.ref.ws_row = row;
    size.ref.ws_col = column;
    nativeLibrary.ioctl(
      pseudoTerminalId,
      Platform.isAndroid ? TIOCSWINSZ_ANDROID : TIOCSWINSZ,
      size,
    );
  }

  @override
  Uint8List? read() {
    return readSync();
  }

  bool pollingIsStart = false;
  @override
  void startPolling() {
    _startPolling();
  }

  SendPort? sendPort;
  Future<void> _startPolling() async {
    if (pollingIsStart) {
      return;
    }
    pollingIsStart = true;
    if (useIsolate) {
      final ReceivePort receivePort = ReceivePort();
      receivePort.listen((dynamic msg) {
        // Log.e('msg -> $msg ${msg.runtimeType}');
        if (sendPort == null) {
          sendPort = msg as SendPort;
          // 先让子 isolate 先读一次数据
          sendPort?.send(true);
        } else {
          _out.sink.add(msg as String);
        }
      });
      readIsolate = await Isolate.spawn<_IsolateArgs>(
        isolateRead,
        _IsolateArgs<int>(receivePort.sendPort, pseudoTerminalId),
      );
      // Log.e('readIsolate -> $readIsolate');
      // readIsolate.kill()
      return;
    }
    final input = StreamController<List<int>>(sync: true);
    input.stream.transform(utf8.decoder).listen(_out.sink.add);
    while (true) {
      // Log.w('轮训...');
      final Uint8List? list = readSync();
      if (list != null) {
        input.sink.add(list);
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  void schedulingRead() {
    sendPort?.send(true);
  }

  @override
  void close() {
    sendPort?.send(false);
    readIsolate?.kill(priority: Isolate.immediate);
    nativeLibrary.kill(pid, SIGKILL);
  }
}

class _IsolateArgs<T> {
  _IsolateArgs(
    this.sendPort,
    this.arg,
  );

  final SendPort sendPort;
  final T arg;
}

// 新isolate的入口函数
Future<void> isolateRead(_IsolateArgs args) async {
  // 实例化一个ReceivePort 以接收消息
  final ReceivePort receivePort = ReceivePort();
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  args.sendPort.send(receivePort.sendPort);
  final FileDescriptor fd = FileDescriptor(args.arg as int, nativeLibrary);

  final input = StreamController<List<int>>(sync: true);

  input.stream.transform(utf8.decoder).listen(args.sendPort.send);

  await for (final dynamic action in receivePort) {
    if (!(action as bool)) {
      Log.w('收到退出指令');
      break;
    }
    final Uint8List? result = fd.read(81920);
    // Log.w('读取...$result');
    if (result != null) {
      input.sink.add(result);
    }
  }
}
