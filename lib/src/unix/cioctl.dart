/// AUTO GENERATED FILE, DO NOT EDIT.
///
/// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// sys/ioctl.h头文件在dart的移植.
class CIoctl {
  /// Holds the Dynamic library.
  final ffi.DynamicLibrary _dylib;

  /// The symbols are looked up in [dynamicLibrary].
  CIoctl(ffi.DynamicLibrary dynamicLibrary) : _dylib = dynamicLibrary;

  int ioctl(int arg0, int arg1, dynamic arg3) {
    _ioctl ??= _dylib.lookupFunction<_c_ioctl, _dart_ioctl>('ioctl');
    return _ioctl(
      arg0,
      arg1,
    );
  }

  _dart_ioctl _ioctl;
}

class __darwin_pthread_handler_rec extends ffi.Struct {
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> __routine;

  ffi.Pointer<ffi.Void> __arg;

  ffi.Pointer<__darwin_pthread_handler_rec> __next;
}

class _opaque_pthread_attr_t extends ffi.Struct {}

class _opaque_pthread_cond_t extends ffi.Struct {}

class _opaque_pthread_condattr_t extends ffi.Struct {}

class _opaque_pthread_mutex_t extends ffi.Struct {}

class _opaque_pthread_mutexattr_t extends ffi.Struct {}

class _opaque_pthread_once_t extends ffi.Struct {}

class _opaque_pthread_rwlock_t extends ffi.Struct {}

class _opaque_pthread_rwlockattr_t extends ffi.Struct {}

class _opaque_pthread_t extends ffi.Struct {}

class winsize extends ffi.Struct {
  @ffi.Uint16()
  int ws_row;

  @ffi.Uint16()
  int ws_col;

  @ffi.Uint16()
  int ws_xpixel;

  @ffi.Uint16()
  int ws_ypixel;
}

class ttysize extends ffi.Struct {
  @ffi.Uint16()
  int ts_lines;

  @ffi.Uint16()
  int ts_cols;

  @ffi.Uint16()
  int ts_xxx;

  @ffi.Uint16()
  int ts_yyy;
}

const int __DARWIN_ONLY_64_BIT_INO_T = 0;

const int __DARWIN_ONLY_VERS_1050 = 0;

const int __DARWIN_ONLY_UNIX_CONFORMANCE = 1;

const int __DARWIN_UNIX03 = 1;

const int __DARWIN_64_BIT_INO_T = 1;

const int __DARWIN_VERS_1050 = 1;

const int __DARWIN_NON_CANCELABLE = 0;

const int __DARWIN_C_ANSI = 4096;

const int __DARWIN_C_FULL = 900000;

const int __DARWIN_C_LEVEL = 900000;

const int __STDC_WANT_LIB_EXT1__ = 1;

const int __DARWIN_NO_LONG_LONG = 0;

const int _DARWIN_FEATURE_64_BIT_INODE = 1;

const int _DARWIN_FEATURE_ONLY_UNIX_CONFORMANCE = 1;

const int _DARWIN_FEATURE_UNIX_CONFORMANCE = 3;

const int __DARWIN_NULL = 0;

const int __PTHREAD_SIZE__ = 8176;

const int __PTHREAD_ATTR_SIZE__ = 56;

const int __PTHREAD_MUTEXATTR_SIZE__ = 8;

const int __PTHREAD_MUTEX_SIZE__ = 56;

const int __PTHREAD_CONDATTR_SIZE__ = 8;

const int __PTHREAD_COND_SIZE__ = 40;

const int __PTHREAD_ONCE_SIZE__ = 8;

const int __PTHREAD_RWLOCK_SIZE__ = 192;

const int __PTHREAD_RWLOCKATTR_SIZE__ = 16;

const int IOCPARM_MASK = 8191;

const int IOCPARM_MAX = 8192;

const int IOC_VOID = 536870912;

const int IOC_OUT = 1073741824;

const int IOC_IN = 2147483648;

const int IOC_INOUT = 3221225472;

const int IOC_DIRMASK = 3758096384;

const int TIOCMODG = 1074033667;

const int TIOCMODS = 2147775492;

const int TIOCM_LE = 1;

const int TIOCM_DTR = 2;

const int TIOCM_RTS = 4;

const int TIOCM_ST = 8;

const int TIOCM_SR = 16;

const int TIOCM_CTS = 32;

const int TIOCM_CAR = 64;

const int TIOCM_CD = 64;

const int TIOCM_RNG = 128;

const int TIOCM_RI = 128;

const int TIOCM_DSR = 256;

const int TIOCEXCL = 536900621;

const int TIOCNXCL = 536900622;

const int TIOCFLUSH = 2147775504;

const int TIOCGETD = 1074033690;

const int TIOCSETD = 2147775515;

const int TIOCIXON = 536900737;

const int TIOCIXOFF = 536900736;

const int TIOCSBRK = 536900731;

const int TIOCCBRK = 536900730;

const int TIOCSDTR = 536900729;

const int TIOCCDTR = 536900728;

const int TIOCGPGRP = 1074033783;

const int TIOCSPGRP = 2147775606;

const int TIOCOUTQ = 1074033779;

const int TIOCSTI = 2147578994;

const int TIOCNOTTY = 536900721;

const int TIOCPKT = 2147775600;

const int TIOCPKT_DATA = 0;

const int TIOCPKT_FLUSHREAD = 1;

const int TIOCPKT_FLUSHWRITE = 2;

const int TIOCPKT_STOP = 4;

const int TIOCPKT_START = 8;

const int TIOCPKT_NOSTOP = 16;

const int TIOCPKT_DOSTOP = 32;

const int TIOCPKT_IOCTL = 64;

const int TIOCSTOP = 536900719;

const int TIOCSTART = 536900718;

const int TIOCMSET = 2147775597;

const int TIOCMBIS = 2147775596;

const int TIOCMBIC = 2147775595;

const int TIOCMGET = 1074033770;

const int TIOCREMOTE = 2147775593;

const int TIOCGWINSZ = 1074295912;

const int TIOCSWINSZ = 2148037735;

const int TIOCUCNTL = 2147775590;

const int TIOCSTAT = 536900709;

const int TIOCSCONS = 536900707;

const int TIOCCONS = 2147775586;

const int TIOCSCTTY = 536900705;

const int TIOCEXT = 2147775584;

const int TIOCSIG = 536900703;

const int TIOCDRAIN = 536900702;

const int TIOCMSDTRWAIT = 2147775579;

const int TIOCMGDTRWAIT = 1074033754;

const int TIOCSDRAINWAIT = 2147775575;

const int TIOCGDRAINWAIT = 1074033750;

const int TIOCDSIMICROCODE = 536900693;

const int TIOCPTYGRANT = 536900692;

const int TIOCPTYGNAME = 1082160211;

const int TIOCPTYUNLK = 536900690;

const int TTYDISC = 0;

const int TABLDISC = 3;

const int SLIPDISC = 4;

const int PPPDISC = 5;

const int TIOCGSIZE = 1074295912;

const int TIOCSSIZE = 2148037735;

const int FIOCLEX = 536897025;

const int FIONCLEX = 536897026;

const int FIONREAD = 1074030207;

const int FIONBIO = 2147772030;

const int FIOASYNC = 2147772029;

const int FIOSETOWN = 2147772028;

const int FIOGETOWN = 1074030203;

const int FIODTYPE = 1074030202;

const int SIOCSHIWAT = 2147775232;

const int SIOCGHIWAT = 1074033409;

const int SIOCSLOWAT = 2147775234;

const int SIOCGLOWAT = 1074033411;

const int SIOCATMARK = 1074033415;

const int SIOCSPGRP = 2147775240;

const int SIOCGPGRP = 1074033417;

typedef _c_ioctl = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Uint64 arg1,
);

typedef _dart_ioctl = int Function(
  int arg0,
  int arg1,
);

typedef _typedefC_1 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
);