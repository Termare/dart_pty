import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
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
import 'utils/isolate_read.dart';

// TODO
// termare;
class UnixPty {
  static DynamicLibrary dynamicLibrary = DynamicLibrary.process();
  static CFcntl cfcntl = CFcntl(dynamicLibrary);
  static CDirent cdirent = CDirent(dynamicLibrary);
  static CSignal csignal = CSignal(dynamicLibrary);
  static CStdio cstdio = CStdio(dynamicLibrary);
  static CStdlib cstdlib = CStdlib(dynamicLibrary);
  static CString cstring = CString(dynamicLibrary);
  static CIoctl cioctl = CIoctl(dynamicLibrary);
  static CWait cwait = CWait(dynamicLibrary);
  static CTermios ctermios = CTermios(dynamicLibrary);
  static CUnistd cunistd = CUnistd(dynamicLibrary);
  // 创建一个pty，返回它的ptm文本描述符，这个ptm在之后的读写，fork子进程还会用到
  static int createPseudoTerminal({bool verbose = false}) {
    if (verbose) print('>>>>>>>>>>>>>>> Create Start');
    Pointer<Int8> ptmxPath = Utf8.toUtf8("/dev/ptmx").cast<Int8>();
    int ptm = cfcntl.open(ptmxPath, O_RDWR | O_CLOEXEC);
    if (cstdlib.grantpt(ptm) != 0 || cstdlib.unlockpt(ptm) != 0) {
      // 说明二者有一个失败
      print("Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx");
      return -1;
    }
    Pointer<termios> tios = allocate();
    // addressOf 可以获取指针
    ctermios.tcgetattr(ptm, tios);
    tios.ref.c_iflag |= IUTF8;
    tios.ref.c_iflag &= ~(IXON | IXOFF);
    ctermios.tcsetattr(ptm, TCSANOW, tios);
    // =========== 设置终端大小 =============
    Pointer<winsize> size = allocate();
    size.ref.ws_row = 30;
    size.ref.ws_col = 54;
    cioctl.ioctl(
      ptm,
      TIOCSWINSZ,
      winsize,
    );
    // =========== 设置终端大小 =============
    free(ptmxPath);

    if (verbose) print('>>>>>>>>>>>>>>> Create End');
    if (verbose) print('>>>>>>>>>>>>>>> Ptm = $ptm');
    setNonblock(ptm, verbose: true);
    return ptm;
    // nativeLibrary.grantpt()
  }

  static int createSubprocess(int ptm) {
    Pointer<Int8> devname = allocate();
    // 获得pts路径
    devname = cstdlib.ptsname(ptm).cast();
    print('pts路径=========>${devname.cast<Utf8>().ref}');
    int pid = cunistd.fork();
    if (pid < 0) {
      print('fork gg');
      return -1;
    } else if (pid > 0) {
      print('fork 主进程');
      return pid;
    } else {
      print('fork 子进程');
      // Clear signals which the Android java process may have blocked:
      Pointer<Uint32> signals_to_unblock = allocate();
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
      if (pts < 0) return -1;
      cunistd.dup2(pts, 0);
      cunistd.dup2(pts, 1);
      cunistd.dup2(pts, 2);
      String a;

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
      Map<String, String> environment =
          Map<String, String>.from(Platform.environment);
      for (int i = 0; i < environment.keys.length; i++) {
        print(
            '${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}');
        cstdlib.putenv(
          Utf8.toUtf8(
                  '${environment.keys.elementAt(i)}=${environment[environment.keys.elementAt(i)]}')
              .cast(),
        );
      }
      cunistd.chdir(Utf8.toUtf8('/data/data/com.nightmare').cast());
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

  static void setNonblock(int fd, {bool verbose = false}) {
    int flag = -1;
    flag = cfcntl.fcntl(fd, F_GETFL, 0); //获取当前flag
    if (verbose) print('>>>>>>>> 当前flag = $flag');
    flag |= O_NONBLOCK; //设置新falg
    if (verbose) print('>>>>>>>> 设置新flag = $flag');
    cfcntl.fcntl(fd, F_SETFL, flag); //更新flag
    flag = cfcntl.fcntl(fd, F_GETFL, 0); //获取当前flag
    if (verbose) print('>>>>>>>> 再次获取到的flag = $flag');
  }

  static Pointer<Utf8> readSync(int fd, {bool verbose = false}) {
    //动态申请空间
    Pointer<Utf8> str = allocate(count: 4097);
    //read函数返回从fd中读取到字符的长度
    //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
    int length = cunistd.read(fd, str.cast(), 4096);
    if (length == -1) {
      free(str);
      return Pointer<Utf8>.fromAddress(0);
    } else {
      // str[length] = '\0';
      return str;
    }
  }

  static void write(int fd, String data) {
    Pointer<Utf8> utf8Pointer = Utf8.toUtf8(data);
    cunistd.write(fd, utf8Pointer.cast(), cstring.strlen(utf8Pointer.cast()));
  }

  static IsolateRead isolateRead;
  static Future<List<int>> read(int fd) async {
    isolateRead ??= IsolateRead();
    return isolateRead.read(fd);
  }
}

void main() {
  int ptm = UnixPty.createPseudoTerminal();
  UnixPty.setNonblock(ptm, verbose: true);
  // UnixPty.createSubprocess(ptm);
  // init(ptm);
  print('ptm=====$ptm');
}

Future<void> runTimer(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((dynamic message) {
    UnixPty.createSubprocess(message as int);
    print('来自主islate的消息===>$message');
  });
  sendPort.send('message');
}

Future<void> init(int ptm) async {
  final ReceivePort receive = ReceivePort();
  final Isolate isolate = await Isolate.spawn(runTimer, receive.sendPort);
  SendPort sendPort;

  print('isolate启动');
  void listen(SendPort data) {
    sendPort = data;
    sendPort.send(ptm);
  }

  receive.listen((dynamic data) {
    if (sendPort == null) {
      listen(data as SendPort);
    }
    print('来自子isolate的消息====>$data');
  });
}
