import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:dart_pty/src/unix_proc.dart';
import 'package:ffi/ffi.dart';
import 'package:signale/signale.dart';

import 'interface/pseudo_terminal_interface.dart';
import 'native_header/generated_bindings.dart';
import 'proc.dart';

import 'unix/termare_native.dart';
import 'utils/custom_utf.dart';

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
    final DynamicLibrary dyLib = DynamicLibrary.process();
    nativeLibrary = NativeLibrary(dyLib);
    pseudoTerminalId = createPseudoTerminal();
    setNonblock(pseudoTerminalId!);
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

  // final NiUtf _niUtf = NiUtf();
  final int rowLen;
  final int columnLen;

  @override
  int? pseudoTerminalId;

  late NativeLibrary nativeLibrary;

  Proc? _createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments = const [],
    Map<String, String> environment = const {},
  }) {
    Pointer<Int8> devname = calloc<Int8>(1);
    // 获得pts路径
    devname = nativeLibrary.ptsname(pseudoTerminalId!).cast();
    int pid = nativeLibrary.fork();
    if (pid < 0) {
      print('fork faild');
    } else if (pid > 0) {
      print('fork 主进程');

      // 这里会返回子进程的pid
      return UnixProc(pid);
    } else {
      print('fork 子进程');
      // Clear signals which the Android java process may have blocked:
      Pointer<Uint32> signals_to_unblock = calloc<Uint32>();
      // sigset_t signals_to_unblock;
      nativeLibrary.sigfillset(signals_to_unblock);
      nativeLibrary.sigprocmask(
        SIG_UNBLOCK,
        signals_to_unblock,
        Pointer.fromAddress(0),
      );
      // sigfillset(&signals_to_unblock);
      // sigprocmask(SIG_UNBLOCK, &signals_to_unblock, 0);
      // unistd.close(ptm);
      // close(ptmfd);
      nativeLibrary.setsid();
      final int pts = nativeLibrary.open(devname, O_RDWR);
      if (pts < 0) {
        return null;
      }
      nativeLibrary.dup2(pts, 0);
      nativeLibrary.dup2(pts, 1);
      nativeLibrary.dup2(pts, 2);

      // Pointer<cdirent.DIR> self_dir =
      //     dirent.opendir(Utf8.toUtf8('/proc/self/fd').cast<Int8>());
      // if (self_dir.address != 0) {
      //   int self_dir_fd = dirent.dirfd(self_dir);
      //   Pointer<cdirent.dirent> entry = allocate();
      //   (entry = dirent.readdir(self_dir));
      //   int fd = stdlib.atoi(entry.ref.d_name);
      //   if (fd > 2 && fd != self_dir_fd) unistd.close(fd);

      //   dirent.closedir(self_dir);
      // }
      Log.d('初始化环境变量');
      print('test');
      final Map<String, String> platformEnvironment = Map.from(
        Platform.environment,
      );
      for (final String key in environment.keys) {
        platformEnvironment[key] = environment[key]!;
      }
      // environment['PATH'] = (Platform.isAndroid
      //         ? '/data/data/com.nightmare/files/usr/bin:'
      //         : FileSystemEntity.parentOf(Platform.resolvedExecutable) +
      //             '/data/usr/bin:') +
      // environment['PATH'];
      for (int i = 0; i < platformEnvironment.keys.length; i++) {
        final String env =
            '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}';
        nativeLibrary.putenv(env.toNativeUtf8().cast());
      }
      nativeLibrary.chdir(workingDirectory.toNativeUtf8().cast());

      final Pointer<Pointer<Utf8>> argv = calloc<Pointer<Utf8>>(
        platformEnvironment.length + 1,
      );
      for (int i = 0; i < arguments.length; i++) {
        argv[i] = arguments[i].toNativeUtf8();
      }
      nativeLibrary.execvp(
        executable.toNativeUtf8().cast(),
        argv.cast(),
      );
      // Pointer<Utf8> error_message;
      // if (stdio.asprintf(error_message, "exec(\"%s\")", cmd) == -1)
      //   error_message = "exec()";
      // stdio.perror(error_message);
      // _exit(1);
      // if (chdir(cwd) != 0)
      // {
      //     char *error_message;
      //     // No need to free asprintf()-allocated memory since doing execvp() or exit() below.
      //     if (asprintf(&error_message, "chdir(\"%s\")", cwd) == -1)
      //         error_message = "chdir()";
      //     perror(error_message);
      //     fflush(stderr);
      // }
      // //执行程序
      // execvp(cmd, argv);

      // // Show terminal output about failing exec() call:
      // char *error_message;
      // if (asprintf(&error_message, "exec(\"%s\")", cmd) == -1)
      //     error_message = "exec()";
      // perror(error_message);
      // _exit(1);
    }
  }

  void setNonblock(int fd, {bool verbose = true}) {
    int flag = -1;
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('>>>>>>>> 当前flag = $flag');
    flag |= O_NONBLOCK; //设置新falg
    Log.d('>>>>>>>> 设置新flag = $flag');
    nativeLibrary.fcntl(fd, F_SETFL, flag); //更新flag
    flag = nativeLibrary.fcntl(fd, F_GETFL, 0); //获取当前flag
    Log.d('>>>>>>>> 再次获取到的flag = $flag');
  }

  final _out = StreamController<List<int>>();
  @override
  Stream<List<int>> get out => _out.stream.asBroadcastStream();
  @override
  List<int> readSync() {
    // print('读取');
    //动态申请空间
    final Pointer<Uint8> resultPoint = calloc<Uint8>(4097);
    //read函数返回从fd中读取到字符的长度
    //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
    final int length = nativeLibrary.read(
      pseudoTerminalId!,
      resultPoint.cast(),
      4096,
    );
    if (length == -1) {
      // free(resultPoint);
      return [];
    } else {
      resultPoint.elementAt(4096).value = 0;

      return resultPoint.asTypedList(length);
    }
    // 代表空指针
  }

  @override
  void write(String data) {
    final Pointer<Utf8> utf8Pointer = data.toNativeUtf8();
    nativeLibrary.write(
      pseudoTerminalId!,
      utf8Pointer.cast(),
      nativeLibrary.strlen(utf8Pointer.cast()),
    );
  }

  @override
  String getTtyPath() {
    Pointer<Int8> devname = calloc<Int8>();
    // 获得pts路径
    devname = nativeLibrary.ptsname(pseudoTerminalId!);
    final String result = devname.cast<Utf8>().toDartString();
    // 下面代码引发crash
    // calloc.free(devname);
    return result;
  }

  @override
  void resize(int row, int column) {
    // String libPath = Platform.resolvedExecutable.replaceAll(
    //   RegExp('\\.app/.*'),
    //   r'.app/',
    // );
    // libPath += 'Contents/Frameworks/App.framework/';
    // libPath += 'Resources/flutter_assets/assets/lib/libterm.dylib';
    // DynamicLibrary dynamicLibrary = DynamicLibrary.open(libPath);
    // TermareNative termareNative = TermareNative(dynamicLibrary);
    // termareNative.setPtyWindowSize(pseudoTerminalId!, row, column);
    // return;
    print('$this resize');
    final Pointer<winsize> size = malloc<winsize>();
    size.ref.ws_row = row;
    size.ref.ws_col = column;
    nativeLibrary.ioctl(
      pseudoTerminalId!,
      TIOCSWINSZ,
      size,
    );
  }

  @override
  Future<List<int>> read() async {
    return readSync();
  }

  @override
  void startPolling() {
    _startPolling();
  }

  Future<void> _startPolling() async {
    while (true) {
      final List<int> list = readSync();
      if (list.isNotEmpty) {
        _out.sink.add(list);
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  set out(Stream<List<int>>? _out) {}
}
