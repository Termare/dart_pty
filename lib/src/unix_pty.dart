import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:dart_pty/src/unix_proc.dart';
import 'package:ffi/ffi.dart';
import 'proc.dart';
import 'pseudo_terminal.dart';
import 'unix/cstring.dart';
import 'unix/cdirent.dart';
import 'unix/cfcntl.dart';
import 'unix/cioctl.dart';
import 'unix/csignal.dart';
import 'unix/cstdlib.dart' hide SIG_UNBLOCK;
// 存在ctermios与cioctl都有这个结构体的情况
import 'unix/ctermios.dart' hide winsize, TIOCSWINSZ;
import 'unix/cwait.dart' hide SIG_UNBLOCK;
import 'unix/cstdio.dart';
import 'unix/cunistd.dart';
import 'utils/custom_utf.dart';
import 'utils/isolate_read.dart';

// TODO
// termare;
class UnixPty implements PseudoTerminal {
  DynamicLibrary dynamicLibrary;
  CFcntl cfcntl;
  CDirent cdirent;
  CSignal csignal;
  CStdio cstdio;
  CStdlib cstdlib;
  CString cstring;
  CIoctl cioctl;
  CWait cwait;
  CTermios ctermios;
  CUnistd cunistd;
  final NiUtf _niUtf = NiUtf();
  final Map<String, String> environment;
  final int rowLen;
  final int columnLen;
  final String exec;
  int pseudoTerminalId;
  UnixPty({
    this.environment = const <String, String>{
      'TERM': 'screen-256color',
    },
    this.rowLen = 25,
    this.columnLen = 80,
    this.exec = 'sh',
  }) {
    dynamicLibrary = DynamicLibrary.process();
    cfcntl = CFcntl(dynamicLibrary);
    cdirent = CDirent(dynamicLibrary);
    csignal = CSignal(dynamicLibrary);
    cstdio = CStdio(dynamicLibrary);
    cstdlib = CStdlib(dynamicLibrary);
    cstring = CString(dynamicLibrary);
    cioctl = CIoctl(dynamicLibrary);
    cwait = CWait(dynamicLibrary);
    ctermios = CTermios(dynamicLibrary);
    cunistd = CUnistd(dynamicLibrary);
    pseudoTerminalId = createPseudoTerminal();

    setNonblock(pseudoTerminalId);
  }
  // 创建一个pty，返回它的ptm文本描述符，这个ptm在之后的读写，fork子进程还会用到
  int createPseudoTerminal({bool verbose = true}) {
    if (verbose) print('>>>>>>>>>>>>>>> Create Start');
    final ptmxPath = Utf8.toUtf8('/dev/ptmx');
    int ptm = cfcntl.open(ptmxPath.cast<Int8>(), O_RDWR | O_CLOEXEC);
    if (cstdlib.grantpt(ptm) != 0 || cstdlib.unlockpt(ptm) != 0) {
      // 说明二者有一个失败
      print('Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx');
      return -1;
    }
    Pointer<termios> tios = allocate<termios>();
    // addressOf 可以获取指针
    ctermios.tcgetattr(ptm, tios);
    tios.ref.c_iflag |= IUTF8;
    tios.ref.c_iflag &= ~(IXON | IXOFF);
    ctermios.tcsetattr(ptm, TCSANOW, tios);
    // free(tios);
    // =========== 设置终端大小 =============
    Pointer<winsize> size = allocate<winsize>();
    size.ref.ws_row = rowLen;
    size.ref.ws_col = columnLen;
    cioctl.ioctl(
      ptm,
      TIOCSWINSZ,
      winsize,
    );
    free(size);
    // =========== 设置终端大小 =============
    // free(ptmxPath);

    if (verbose) print('>>>>>>>>>>>>>>> Create End');
    if (verbose) print('>>>>>>>>>>>>>>> Ptm = $ptm');

    return ptm;
    // nativeLibrary.grantpt()
  }

  Proc createSubprocess(
    String executable, {
    String workingDirectory = '.',
    List<String> arguments,
    Map<String, String> environment = const <String, String>{
      'TERM': 'screen-256color',
    },
  }) {
    Pointer<Int8> devname = allocate<Int8>();
    // 获得pts路径
    devname = cstdlib.ptsname(pseudoTerminalId).cast();
    print('pts路径=========>${devname.cast<Utf8>().ref}');
    int pid = cunistd.fork();
    if (pid < 0) {
      print('fork gg');
      return null;
    } else if (pid > 0) {
      print('fork 主进程');

      /// 这里会返回子进程的pid
      return UnixProc(pid);
    } else {
      print('fork 子进程');
      // Clear signals which the Android java process may have blocked:
      Pointer<Uint32> signals_to_unblock = allocate<Uint32>();
      // sigset_t signals_to_unblock;
      csignal.sigfillset(signals_to_unblock);
      csignal.sigprocmask(
        SIG_UNBLOCK,
        signals_to_unblock,
        Pointer.fromAddress(0),
      );
      // sigfillset(&signals_to_unblock);
      // sigprocmask(SIG_UNBLOCK, &signals_to_unblock, 0);
      // unistd.close(ptm);
      // close(ptmfd);
      cunistd.setsid();
      int pts = cfcntl.open(devname, O_RDWR);
      print('pts的文件描述符====>$pts');
      if (pts < 0) return null;
      cunistd.dup2(pts, 0);
      cunistd.dup2(pts, 1);
      cunistd.dup2(pts, 2);

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
      print('初始化环境变量');
      final Map<String, String> platformEnvironment = Map.from(
        Platform.environment,
      );
      for (String key in environment.keys) {
        platformEnvironment[key] = environment[key];
      }
      // environment['PATH'] = (Platform.isAndroid
      //         ? '/data/data/com.nightmare/files/usr/bin:'
      //         : FileSystemEntity.parentOf(Platform.resolvedExecutable) +
      //             '/data/usr/bin:') +
      // environment['PATH'];
      for (int i = 0; i < environment.keys.length; i++) {
        print(
            '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}');
        cstdlib.putenv(
          Utf8.toUtf8(
                  '${platformEnvironment.keys.elementAt(i)}=${platformEnvironment[platformEnvironment.keys.elementAt(i)]}')
              .cast(),
        );
      }
      // cunistd.chdir(Utf8.toUtf8('/data/data/com.nightmare').cast());
      cunistd.execvp(Utf8.toUtf8('sh').cast(), Pointer.fromAddress(0));
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
    flag = cfcntl.fcntl(fd, F_GETFL, 0); //获取当前flag
    if (verbose) print('>>>>>>>> 当前flag = $flag');
    flag |= O_NONBLOCK; //设置新falg
    if (verbose) print('>>>>>>>> 设置新flag = $flag');
    cfcntl.fcntl(fd, F_SETFL, flag); //更新flag
    flag = cfcntl.fcntl(fd, F_GETFL, 0); //获取当前flag
    if (verbose) print('>>>>>>>> 再次获取到的flag = $flag');
  }

  @override
  String readSync() {
    // print('读取');
    //动态申请空间
    final Pointer<Uint8> resultPoint = allocate<Uint8>(count: 4097);
    //read函数返回从fd中读取到字符的长度
    //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
    final int length = cunistd.read(pseudoTerminalId, resultPoint.cast(), 4096);
    if (length == -1) {
      // free(resultPoint);
      return '';
    } else {
      resultPoint.elementAt(4096).value = 0;
      final String result = _niUtf.cStringtoString(resultPoint.cast());
      free(resultPoint);
      return result;
    }
    // 代表空指针
  }

  void write(String data) {
    Pointer<Utf8> utf8Pointer = Utf8.toUtf8(data);
    cunistd.write(
      pseudoTerminalId,
      utf8Pointer.cast(),
      cstring.strlen(utf8Pointer.cast()),
    );
  }

  @override
  String getTtyPath() {
    Pointer<Int8> devname = allocate<Int8>();
    // 获得pts路径
    devname = cstdlib.ptsname(pseudoTerminalId).cast();
    final String result = Utf8.fromUtf8(devname.cast());
    free(devname);
    return result;
  }

  @override
  void resize(int row, int column) {
    // TODO: implement resize
  }

  @override
  Future<String> read() async {
    return readSync();
  }
}
