import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
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
  }) {
    out = _out.stream.asBroadcastStream();
    // 这个函数实现的功能是完整的
    pseudoTerminalId = createPseudoTerminal();
    fd = FileDescriptor(pseudoTerminalId, nativeLibrary);
    setNonblock(pseudoTerminalId);
    _createSubprocess(
      executable!,
      workingDirectory: workingDirectory,
      arguments: arguments,
      environment: environment,
    );
  }
  // 创建一个pty，返回它的ptm文本描述符，这个ptm在之后的读写，fork子进程还会用到
  int createPseudoTerminal({bool verbose = true}) {
    Log.d('Create Start');
    final ptmxPath = '/dev/ptmx'.toNativeUtf8();
    final int ptm = nativeLibrary.open(
      ptmxPath.cast<Int8>(),
      O_RDWR | O_CLOEXEC,
    );
    if (nativeLibrary.grantpt(ptm) != 0 || nativeLibrary.unlockpt(ptm) != 0) {
      // 说明二者有一个失败
      print('Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx');
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

    Log.d('Create End');
    Log.d('Ptm = $ptm');
    return ptm;
    // nativeLibrary.grantpt()
  }

  late FileDescriptor fd;
  // final NiUtf _niUtf = NiUtf();
  final int rowLen;
  final int columnLen;

  @override
  late int pseudoTerminalId;

  Proc? _createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
  }) {
    Pointer<Int8> devname = calloc<Int8>(1);
    // 获得pts路径
    devname = nativeLibrary.ptsname(pseudoTerminalId).cast();
    final int pid = nativeLibrary.fork();
    if (pid < 0) {
      print('fork faild');
    } else if (pid > 0) {
      print('fork 主进程');

      // 这里会返回子进程的pid
      return UnixProc(pid);
    } else {
      print('fork 子进程');
      // Clear signals which the Android java process may have blocked:
      final Pointer<Uint32> signalsToUnblock = calloc<Uint32>();
      // sigset_t signals_to_unblock;
      nativeLibrary.sigfillset(signalsToUnblock);
      nativeLibrary.sigprocmask(
        SIG_UNBLOCK,
        signalsToUnblock,
        Pointer.fromAddress(0),
      );
      nativeLibrary.close(pseudoTerminalId);
      nativeLibrary.setsid();
      final int pts = nativeLibrary.open(devname, O_RDWR);
      if (pts < 0) {
        return null;
      }
      nativeLibrary.dup2(pts, 0);
      nativeLibrary.dup2(pts, 1);
      nativeLibrary.dup2(pts, 2);
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
        platformEnvironment.length + 1,
      );
      for (int i = 0; i < arguments.length; i++) {
        argv[i] = arguments[i].toNativeUtf8();
      }
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

  void setNonblock(int fd, {bool verbose = true}) {
    int flag = -1;
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('> 当前flag = $flag');
    flag |= Platform.isAndroid ? O_NONBLOCK_ANDROID : O_NONBLOCK; //设置新falg
    Log.d('> 设置新flag = $flag');
    nativeLibrary.fcntl(fd, F_SETFL, flag); //更新flag
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('> 再次获取到的flag = $flag');
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
    final Pointer<winsize> size = malloc<winsize>();
    size.ref.ws_row = row;
    size.ref.ws_col = column;
    nativeLibrary.ioctl(
      pseudoTerminalId,
      TIOCSWINSZ,
      size,
    );
  }

  @override
  Uint8List? read() {
    return readSync();
  }

  @override
  void startPolling() {
    _startPolling();
  }

  Future<void> _startPolling() async {
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
    // TODO: implement schedulingRead
  }
}
