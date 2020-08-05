/// AUTO GENERATED FILE, DO NOT EDIT.
///
/// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// sys/wait.h头文件在dart的移植.
class CWait {
  /// Holds the Dynamic library.
  final ffi.DynamicLibrary _dylib;

  /// The symbols are looked up in [dynamicLibrary].
  CWait(ffi.DynamicLibrary dynamicLibrary) : _dylib = dynamicLibrary;

// ffi.Pointer<ffi.NativeFunction<_typedefC_5>> signal(
//   int arg0,
//   ffi.Pointer<ffi.NativeFunction<_typedefC_6>> arg1,
// ) {
// _signal ??= _dylib.lookupFunction<_c_signal,_dart_signal>('signal');
//   return _signal(
//     arg0,
//     arg1,
//   );
// }
// _dart_signal _signal;

  int getpriority(
    int arg0,
    int arg1,
  ) {
    _getpriority ??=
        _dylib.lookupFunction<_c_getpriority, _dart_getpriority>('getpriority');
    return _getpriority(
      arg0,
      arg1,
    );
  }

  _dart_getpriority _getpriority;

  int getiopolicy_np(
    int arg0,
    int arg1,
  ) {
    _getiopolicy_np ??=
        _dylib.lookupFunction<_c_getiopolicy_np, _dart_getiopolicy_np>(
            'getiopolicy_np');
    return _getiopolicy_np(
      arg0,
      arg1,
    );
  }

  _dart_getiopolicy_np _getiopolicy_np;

  int getrlimit(
    int arg0,
    ffi.Pointer<rlimit> arg1,
  ) {
    _getrlimit ??=
        _dylib.lookupFunction<_c_getrlimit, _dart_getrlimit>('getrlimit');
    return _getrlimit(
      arg0,
      arg1,
    );
  }

  _dart_getrlimit _getrlimit;

  int getrusage(
    int arg0,
    ffi.Pointer<rusage> arg1,
  ) {
    _getrusage ??=
        _dylib.lookupFunction<_c_getrusage, _dart_getrusage>('getrusage');
    return _getrusage(
      arg0,
      arg1,
    );
  }

  _dart_getrusage _getrusage;

  int setpriority(
    int arg0,
    int arg1,
    int arg2,
  ) {
    _setpriority ??=
        _dylib.lookupFunction<_c_setpriority, _dart_setpriority>('setpriority');
    return _setpriority(
      arg0,
      arg1,
      arg2,
    );
  }

  _dart_setpriority _setpriority;

  int setiopolicy_np(
    int arg0,
    int arg1,
    int arg2,
  ) {
    _setiopolicy_np ??=
        _dylib.lookupFunction<_c_setiopolicy_np, _dart_setiopolicy_np>(
            'setiopolicy_np');
    return _setiopolicy_np(
      arg0,
      arg1,
      arg2,
    );
  }

  _dart_setiopolicy_np _setiopolicy_np;

  int setrlimit(
    int arg0,
    ffi.Pointer<rlimit> arg1,
  ) {
    _setrlimit ??=
        _dylib.lookupFunction<_c_setrlimit, _dart_setrlimit>('setrlimit');
    return _setrlimit(
      arg0,
      arg1,
    );
  }

  _dart_setrlimit _setrlimit;

  int _OSSwapInt16(
    int _data,
  ) {
    __OSSwapInt16 ??= _dylib
        .lookupFunction<_c__OSSwapInt16, _dart__OSSwapInt16>('_OSSwapInt16');
    return __OSSwapInt16(
      _data,
    );
  }

  _dart__OSSwapInt16 __OSSwapInt16;

  int _OSSwapInt32(
    int _data,
  ) {
    __OSSwapInt32 ??= _dylib
        .lookupFunction<_c__OSSwapInt32, _dart__OSSwapInt32>('_OSSwapInt32');
    return __OSSwapInt32(
      _data,
    );
  }

  _dart__OSSwapInt32 __OSSwapInt32;

  int _OSSwapInt64(
    int _data,
  ) {
    __OSSwapInt64 ??= _dylib
        .lookupFunction<_c__OSSwapInt64, _dart__OSSwapInt64>('_OSSwapInt64');
    return __OSSwapInt64(
      _data,
    );
  }

  _dart__OSSwapInt64 __OSSwapInt64;

  int wait(
    ffi.Pointer<ffi.Int32> arg0,
  ) {
    _wait ??= _dylib.lookupFunction<_c_wait, _dart_wait>('wait');
    return _wait(
      arg0,
    );
  }

  _dart_wait _wait;

  int waitpid(
    int arg0,
    ffi.Pointer<ffi.Int32> arg1,
    int arg2,
  ) {
    _waitpid ??= _dylib.lookupFunction<_c_waitpid, _dart_waitpid>('waitpid');
    return _waitpid(
      arg0,
      arg1,
      arg2,
    );
  }

  _dart_waitpid _waitpid;

  int waitid(
    int arg0,
    int arg1,
    ffi.Pointer<__siginfo> arg2,
    int arg3,
  ) {
    _waitid ??= _dylib.lookupFunction<_c_waitid, _dart_waitid>('waitid');
    return _waitid(
      arg0,
      arg1,
      arg2,
      arg3,
    );
  }

  _dart_waitid _waitid;

  int wait3(
    ffi.Pointer<ffi.Int32> arg0,
    int arg1,
    ffi.Pointer<rusage> arg2,
  ) {
    _wait3 ??= _dylib.lookupFunction<_c_wait3, _dart_wait3>('wait3');
    return _wait3(
      arg0,
      arg1,
      arg2,
    );
  }

  _dart_wait3 _wait3;

  int wait4(
    int arg0,
    ffi.Pointer<ffi.Int32> arg1,
    int arg2,
    ffi.Pointer<rusage> arg3,
  ) {
    _wait4 ??= _dylib.lookupFunction<_c_wait4, _dart_wait4>('wait4');
    return _wait4(
      arg0,
      arg1,
      arg2,
      arg3,
    );
  }

  _dart_wait4 _wait4;
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

abstract class idtype_t {
  static const int P_ALL = 0;
  static const int P_PID = 1;
  static const int P_PGID = 2;
}

class __darwin_i386_thread_state extends ffi.Struct {
  @ffi.Uint32()
  int __eax;

  @ffi.Uint32()
  int __ebx;

  @ffi.Uint32()
  int __ecx;

  @ffi.Uint32()
  int __edx;

  @ffi.Uint32()
  int __edi;

  @ffi.Uint32()
  int __esi;

  @ffi.Uint32()
  int __ebp;

  @ffi.Uint32()
  int __esp;

  @ffi.Uint32()
  int __ss;

  @ffi.Uint32()
  int __eflags;

  @ffi.Uint32()
  int __eip;

  @ffi.Uint32()
  int __cs;

  @ffi.Uint32()
  int __ds;

  @ffi.Uint32()
  int __es;

  @ffi.Uint32()
  int __fs;

  @ffi.Uint32()
  int __gs;
}

// class __darwin_fp_control extends ffi.Struct{
//   @ffi.Uint16()
//   int __invalid;

//   @ffi.Uint16()
//   int __denorm;

//   @ffi.Uint16()
//   int __zdiv;

//   @ffi.Uint16()
//   int __ovrfl;

//   @ffi.Uint16()
//   int __undfl;

//   @ffi.Uint16()
//   int __precis;

//   @ffi.Uint16()
//   int ;

//   @ffi.Uint16()
//   int __pc;

//   @ffi.Uint16()
//   int __rc;

//   @ffi.Uint16()
//   int _1;

//   @ffi.Uint16()
//   int _2;

// }

class __darwin_fp_status extends ffi.Struct {
  @ffi.Uint16()
  int __invalid;

  @ffi.Uint16()
  int __denorm;

  @ffi.Uint16()
  int __zdiv;

  @ffi.Uint16()
  int __ovrfl;

  @ffi.Uint16()
  int __undfl;

  @ffi.Uint16()
  int __precis;

  @ffi.Uint16()
  int __stkflt;

  @ffi.Uint16()
  int __errsumm;

  @ffi.Uint16()
  int __c0;

  @ffi.Uint16()
  int __c1;

  @ffi.Uint16()
  int __c2;

  @ffi.Uint16()
  int __tos;

  @ffi.Uint16()
  int __c3;

  @ffi.Uint16()
  int __busy;
}

class __darwin_mmst_reg extends ffi.Struct {}

class __darwin_xmm_reg extends ffi.Struct {}

class __darwin_ymm_reg extends ffi.Struct {}

class __darwin_zmm_reg extends ffi.Struct {}

class __darwin_opmask_reg extends ffi.Struct {}

class __darwin_i386_float_state extends ffi.Struct {}

class __darwin_i386_avx_state extends ffi.Struct {}

class __darwin_i386_avx512_state extends ffi.Struct {}

class __darwin_i386_exception_state extends ffi.Struct {
  @ffi.Uint16()
  int __trapno;

  @ffi.Uint16()
  int __cpu;

  @ffi.Uint32()
  int __err;

  @ffi.Uint32()
  int __faultvaddr;
}

class __darwin_x86_debug_state32 extends ffi.Struct {
  @ffi.Uint32()
  int __dr0;

  @ffi.Uint32()
  int __dr1;

  @ffi.Uint32()
  int __dr2;

  @ffi.Uint32()
  int __dr3;

  @ffi.Uint32()
  int __dr4;

  @ffi.Uint32()
  int __dr5;

  @ffi.Uint32()
  int __dr6;

  @ffi.Uint32()
  int __dr7;
}

class __x86_pagein_state extends ffi.Struct {
  @ffi.Int32()
  int __pagein_error;
}

class __darwin_x86_thread_state64 extends ffi.Struct {
  @ffi.Uint64()
  int __rax;

  @ffi.Uint64()
  int __rbx;

  @ffi.Uint64()
  int __rcx;

  @ffi.Uint64()
  int __rdx;

  @ffi.Uint64()
  int __rdi;

  @ffi.Uint64()
  int __rsi;

  @ffi.Uint64()
  int __rbp;

  @ffi.Uint64()
  int __rsp;

  @ffi.Uint64()
  int __r8;

  @ffi.Uint64()
  int __r9;

  @ffi.Uint64()
  int __r10;

  @ffi.Uint64()
  int __r11;

  @ffi.Uint64()
  int __r12;

  @ffi.Uint64()
  int __r13;

  @ffi.Uint64()
  int __r14;

  @ffi.Uint64()
  int __r15;

  @ffi.Uint64()
  int __rip;

  @ffi.Uint64()
  int __rflags;

  @ffi.Uint64()
  int __cs;

  @ffi.Uint64()
  int __fs;

  @ffi.Uint64()
  int __gs;
}

class __darwin_x86_thread_full_state64 extends ffi.Struct {}

class __darwin_x86_float_state64 extends ffi.Struct {}

class __darwin_x86_avx_state64 extends ffi.Struct {}

class __darwin_x86_avx512_state64 extends ffi.Struct {}

class __darwin_x86_exception_state64 extends ffi.Struct {
  @ffi.Uint16()
  int __trapno;

  @ffi.Uint16()
  int __cpu;

  @ffi.Uint32()
  int __err;

  @ffi.Uint64()
  int __faultvaddr;
}

class __darwin_x86_debug_state64 extends ffi.Struct {
  @ffi.Uint64()
  int __dr0;

  @ffi.Uint64()
  int __dr1;

  @ffi.Uint64()
  int __dr2;

  @ffi.Uint64()
  int __dr3;

  @ffi.Uint64()
  int __dr4;

  @ffi.Uint64()
  int __dr5;

  @ffi.Uint64()
  int __dr6;

  @ffi.Uint64()
  int __dr7;
}

class __darwin_x86_cpmu_state64 extends ffi.Struct {}

class __darwin_mcontext32 extends ffi.Struct {}

class __darwin_mcontext_avx32 extends ffi.Struct {}

class __darwin_mcontext_avx512_32 extends ffi.Struct {}

class __darwin_mcontext64 extends ffi.Struct {}

class __darwin_mcontext64_full extends ffi.Struct {}

class __darwin_mcontext_avx64 extends ffi.Struct {}

class __darwin_mcontext_avx64_full extends ffi.Struct {}

class __darwin_mcontext_avx512_64 extends ffi.Struct {}

class __darwin_mcontext_avx512_64_full extends ffi.Struct {}

class __darwin_sigaltstack extends ffi.Struct {
  ffi.Pointer<ffi.Void> ss_sp;

  @ffi.Uint64()
  int ss_size;

  @ffi.Int32()
  int ss_flags;
}

class __darwin_ucontext extends ffi.Struct {}

class sigevent extends ffi.Struct {}

class __siginfo extends ffi.Struct {}

class siginfo_t extends ffi.Struct {}

class __sigaction extends ffi.Struct {}

class sigaction extends ffi.Struct {}

class sigvec extends ffi.Struct {
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> sv_handler;

  @ffi.Int32()
  int sv_mask;

  @ffi.Int32()
  int sv_flags;
}

class sigstack extends ffi.Struct {
  ffi.Pointer<ffi.Int8> ss_sp;

  @ffi.Int32()
  int ss_onstack;
}

class timeval extends ffi.Struct {
  @ffi.Int64()
  int tv_sec;

  @ffi.Int32()
  int tv_usec;
}

class rusage extends ffi.Struct {}

class rusage_info_v0 extends ffi.Struct {}

class rusage_info_v1 extends ffi.Struct {}

class rusage_info_v2 extends ffi.Struct {}

class rusage_info_v3 extends ffi.Struct {}

class rusage_info_v4 extends ffi.Struct {}

class rlimit extends ffi.Struct {
  @ffi.Uint64()
  int rlim_cur;

  @ffi.Uint64()
  int rlim_max;
}

class proc_rlimit_control_wakeupmon extends ffi.Struct {
  @ffi.Uint32()
  int wm_flags;

  @ffi.Int32()
  int wm_rate;
}

const int __DARWIN_ONLY_64_BIT_INO_T = 0;

const int __DARWIN_ONLY_VERS_1050 = 0;

const int __DARWIN_ONLY_UNIX_CONFORMANCE = 1;

const int __DARWIN_UNIX03 = 1;

const int __DARWIN_64_BIT_INO_T = 1;

const int __DARWIN_VERS_1050 = 1;

const int __DARWIN_NON_CANCELABLE = 0;

// const String __DARWIN_SUF_64_BIT_INO_T = '$INODE64';

// const String __DARWIN_SUF_1050 = '$1050';

// const String __DARWIN_SUF_EXTSN = '$DARWIN_EXTSN';

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

const int __API_TO_BE_DEPRECATED = 100000;

const int __MAC_10_0 = 1000;

const int __MAC_10_1 = 1010;

const int __MAC_10_2 = 1020;

const int __MAC_10_3 = 1030;

const int __MAC_10_4 = 1040;

const int __MAC_10_5 = 1050;

const int __MAC_10_6 = 1060;

const int __MAC_10_7 = 1070;

const int __MAC_10_8 = 1080;

const int __MAC_10_9 = 1090;

const int __MAC_10_10 = 101000;

const int __MAC_10_10_2 = 101002;

const int __MAC_10_10_3 = 101003;

const int __MAC_10_11 = 101100;

const int __MAC_10_11_2 = 101102;

const int __MAC_10_11_3 = 101103;

const int __MAC_10_11_4 = 101104;

const int __MAC_10_12 = 101200;

const int __MAC_10_12_1 = 101201;

const int __MAC_10_12_2 = 101202;

const int __MAC_10_12_4 = 101204;

const int __MAC_10_13 = 101300;

const int __MAC_10_13_1 = 101301;

const int __MAC_10_13_2 = 101302;

const int __MAC_10_13_4 = 101304;

const int __MAC_10_14 = 101400;

const int __MAC_10_14_1 = 101401;

const int __MAC_10_14_4 = 101404;

const int __MAC_10_15 = 101500;

const int __MAC_10_15_1 = 101501;

const int __MAC_10_15_4 = 101504;

const int __IPHONE_2_0 = 20000;

const int __IPHONE_2_1 = 20100;

const int __IPHONE_2_2 = 20200;

const int __IPHONE_3_0 = 30000;

const int __IPHONE_3_1 = 30100;

const int __IPHONE_3_2 = 30200;

const int __IPHONE_4_0 = 40000;

const int __IPHONE_4_1 = 40100;

const int __IPHONE_4_2 = 40200;

const int __IPHONE_4_3 = 40300;

const int __IPHONE_5_0 = 50000;

const int __IPHONE_5_1 = 50100;

const int __IPHONE_6_0 = 60000;

const int __IPHONE_6_1 = 60100;

const int __IPHONE_7_0 = 70000;

const int __IPHONE_7_1 = 70100;

const int __IPHONE_8_0 = 80000;

const int __IPHONE_8_1 = 80100;

const int __IPHONE_8_2 = 80200;

const int __IPHONE_8_3 = 80300;

const int __IPHONE_8_4 = 80400;

const int __IPHONE_9_0 = 90000;

const int __IPHONE_9_1 = 90100;

const int __IPHONE_9_2 = 90200;

const int __IPHONE_9_3 = 90300;

const int __IPHONE_10_0 = 100000;

const int __IPHONE_10_1 = 100100;

const int __IPHONE_10_2 = 100200;

const int __IPHONE_10_3 = 100300;

const int __IPHONE_11_0 = 110000;

const int __IPHONE_11_1 = 110100;

const int __IPHONE_11_2 = 110200;

const int __IPHONE_11_3 = 110300;

const int __IPHONE_11_4 = 110400;

const int __IPHONE_12_0 = 120000;

const int __IPHONE_12_1 = 120100;

const int __IPHONE_12_2 = 120200;

const int __IPHONE_12_3 = 120300;

const int __IPHONE_13_0 = 130000;

const int __IPHONE_13_1 = 130100;

const int __IPHONE_13_2 = 130200;

const int __IPHONE_13_3 = 130300;

const int __IPHONE_13_4 = 130400;

const int __TVOS_9_0 = 90000;

const int __TVOS_9_1 = 90100;

const int __TVOS_9_2 = 90200;

const int __TVOS_10_0 = 100000;

const int __TVOS_10_0_1 = 100001;

const int __TVOS_10_1 = 100100;

const int __TVOS_10_2 = 100200;

const int __TVOS_11_0 = 110000;

const int __TVOS_11_1 = 110100;

const int __TVOS_11_2 = 110200;

const int __TVOS_11_3 = 110300;

const int __TVOS_11_4 = 110400;

const int __TVOS_12_0 = 120000;

const int __TVOS_12_1 = 120100;

const int __TVOS_12_2 = 120200;

const int __TVOS_12_3 = 120300;

const int __TVOS_13_0 = 130000;

const int __TVOS_13_2 = 130200;

const int __TVOS_13_3 = 130300;

const int __TVOS_13_4 = 130400;

const int __WATCHOS_1_0 = 10000;

const int __WATCHOS_2_0 = 20000;

const int __WATCHOS_2_1 = 20100;

const int __WATCHOS_2_2 = 20200;

const int __WATCHOS_3_0 = 30000;

const int __WATCHOS_3_1 = 30100;

const int __WATCHOS_3_1_1 = 30101;

const int __WATCHOS_3_2 = 30200;

const int __WATCHOS_4_0 = 40000;

const int __WATCHOS_4_1 = 40100;

const int __WATCHOS_4_2 = 40200;

const int __WATCHOS_4_3 = 40300;

const int __WATCHOS_5_0 = 50000;

const int __WATCHOS_5_1 = 50100;

const int __WATCHOS_5_2 = 50200;

const int __WATCHOS_6_0 = 60000;

const int __WATCHOS_6_1 = 60100;

const int __WATCHOS_6_2 = 60200;

const int __DRIVERKIT_19_0 = 190000;

const int __MAC_OS_X_VERSION_MIN_REQUIRED = 101500;

const int __MAC_OS_X_VERSION_MAX_ALLOWED = 101500;

const int __ENABLE_LEGACY_MAC_AVAILABILITY = 1;

const int __DARWIN_NSIG = 32;

const int NSIG = 32;

const int _I386_SIGNAL_H_ = 1;

const int SIGHUP = 1;

const int SIGINT = 2;

const int SIGQUIT = 3;

const int SIGILL = 4;

const int SIGTRAP = 5;

const int SIGABRT = 6;

const int SIGIOT = 6;

const int SIGEMT = 7;

const int SIGFPE = 8;

const int SIGKILL = 9;

const int SIGBUS = 10;

const int SIGSEGV = 11;

const int SIGSYS = 12;

const int SIGPIPE = 13;

const int SIGALRM = 14;

const int SIGTERM = 15;

const int SIGURG = 16;

const int SIGSTOP = 17;

const int SIGTSTP = 18;

const int SIGCONT = 19;

const int SIGCHLD = 20;

const int SIGTTIN = 21;

const int SIGTTOU = 22;

const int SIGIO = 23;

const int SIGXCPU = 24;

const int SIGXFSZ = 25;

const int SIGVTALRM = 26;

const int SIGPROF = 27;

const int SIGWINCH = 28;

const int SIGINFO = 29;

const int SIGUSR1 = 30;

const int SIGUSR2 = 31;

const int USER_ADDR_NULL = 0;

const int FP_PREC_24B = 0;

const int FP_PREC_53B = 2;

const int FP_PREC_64B = 3;

const int FP_RND_NEAR = 0;

const int FP_RND_DOWN = 1;

const int FP_RND_UP = 2;

const int FP_CHOP = 3;

const int FP_STATE_BYTES = 512;

const int SIGEV_NONE = 0;

const int SIGEV_SIGNAL = 1;

const int SIGEV_THREAD = 3;

const int ILL_NOOP = 0;

const int ILL_ILLOPC = 1;

const int ILL_ILLTRP = 2;

const int ILL_PRVOPC = 3;

const int ILL_ILLOPN = 4;

const int ILL_ILLADR = 5;

const int ILL_PRVREG = 6;

const int ILL_COPROC = 7;

const int ILL_BADSTK = 8;

const int FPE_NOOP = 0;

const int FPE_FLTDIV = 1;

const int FPE_FLTOVF = 2;

const int FPE_FLTUND = 3;

const int FPE_FLTRES = 4;

const int FPE_FLTINV = 5;

const int FPE_FLTSUB = 6;

const int FPE_INTDIV = 7;

const int FPE_INTOVF = 8;

const int SEGV_NOOP = 0;

const int SEGV_MAPERR = 1;

const int SEGV_ACCERR = 2;

const int BUS_NOOP = 0;

const int BUS_ADRALN = 1;

const int BUS_ADRERR = 2;

const int BUS_OBJERR = 3;

const int TRAP_BRKPT = 1;

const int TRAP_TRACE = 2;

const int CLD_NOOP = 0;

const int CLD_EXITED = 1;

const int CLD_KILLED = 2;

const int CLD_DUMPED = 3;

const int CLD_TRAPPED = 4;

const int CLD_STOPPED = 5;

const int CLD_CONTINUED = 6;

const int POLL_IN = 1;

const int POLL_OUT = 2;

const int POLL_MSG = 3;

const int POLL_ERR = 4;

const int POLL_PRI = 5;

const int POLL_HUP = 6;

const int SA_ONSTACK = 1;

const int SA_RESTART = 2;

const int SA_RESETHAND = 4;

const int SA_NOCLDSTOP = 8;

const int SA_NODEFER = 16;

const int SA_NOCLDWAIT = 32;

const int SA_SIGINFO = 64;

const int SA_USERTRAMP = 256;

const int SA_64REGSET = 512;

const int SA_USERSPACE_MASK = 127;

const int SIG_BLOCK = 1;

const int SIG_UNBLOCK = 2;

const int SIG_SETMASK = 3;

const int SI_USER = 65537;

const int SI_QUEUE = 65538;

const int SI_TIMER = 65539;

const int SI_ASYNCIO = 65540;

const int SI_MESGQ = 65541;

const int SS_ONSTACK = 1;

const int SS_DISABLE = 4;

const int MINSIGSTKSZ = 32768;

const int SIGSTKSZ = 131072;

const int SV_ONSTACK = 1;

const int SV_INTERRUPT = 2;

const int SV_RESETHAND = 4;

const int SV_NODEFER = 16;

const int SV_NOCLDSTOP = 8;

const int SV_SIGINFO = 64;

const int __WORDSIZE = 64;

const int INT8_MAX = 127;

const int INT16_MAX = 32767;

const int INT32_MAX = 2147483647;

const int INT64_MAX = 9223372036854775807;

const int INT8_MIN = -128;

const int INT16_MIN = -32768;

const int INT32_MIN = -2147483648;

const int INT64_MIN = -9223372036854775808;

const int UINT8_MAX = 255;

const int UINT16_MAX = 65535;

const int UINT32_MAX = 4294967295;

const int UINT64_MAX = -1;

const int INT_LEAST8_MIN = -128;

const int INT_LEAST16_MIN = -32768;

const int INT_LEAST32_MIN = -2147483648;

const int INT_LEAST64_MIN = -9223372036854775808;

const int INT_LEAST8_MAX = 127;

const int INT_LEAST16_MAX = 32767;

const int INT_LEAST32_MAX = 2147483647;

const int INT_LEAST64_MAX = 9223372036854775807;

const int UINT_LEAST8_MAX = 255;

const int UINT_LEAST16_MAX = 65535;

const int UINT_LEAST32_MAX = 4294967295;

const int UINT_LEAST64_MAX = -1;

const int INT_FAST8_MIN = -128;

const int INT_FAST16_MIN = -32768;

const int INT_FAST32_MIN = -2147483648;

const int INT_FAST64_MIN = -9223372036854775808;

const int INT_FAST8_MAX = 127;

const int INT_FAST16_MAX = 32767;

const int INT_FAST32_MAX = 2147483647;

const int INT_FAST64_MAX = 9223372036854775807;

const int UINT_FAST8_MAX = 255;

const int UINT_FAST16_MAX = 65535;

const int UINT_FAST32_MAX = 4294967295;

const int UINT_FAST64_MAX = -1;

const int INTPTR_MAX = 9223372036854775807;

const int INTPTR_MIN = -9223372036854775808;

const int UINTPTR_MAX = -1;

const int INTMAX_MAX = 9223372036854775807;

const int UINTMAX_MAX = -1;

const int INTMAX_MIN = -9223372036854775808;

const int PTRDIFF_MIN = -9223372036854775808;

const int PTRDIFF_MAX = 9223372036854775807;

const int SIZE_MAX = -1;

const int RSIZE_MAX = 9223372036854775807;

const int WCHAR_MAX = 2147483647;

const int WCHAR_MIN = -2147483648;

const int WINT_MIN = -2147483648;

const int WINT_MAX = 2147483647;

const int SIG_ATOMIC_MIN = -2147483648;

const int SIG_ATOMIC_MAX = 2147483647;

const int PRIO_PROCESS = 0;

const int PRIO_PGRP = 1;

const int PRIO_USER = 2;

const int PRIO_DARWIN_THREAD = 3;

const int PRIO_DARWIN_PROCESS = 4;

const int PRIO_MIN = -20;

const int PRIO_MAX = 20;

const int PRIO_DARWIN_BG = 4096;

const int PRIO_DARWIN_NONUI = 4097;

const int RUSAGE_SELF = 0;

const int RUSAGE_CHILDREN = -1;

const int RUSAGE_INFO_V0 = 0;

const int RUSAGE_INFO_V1 = 1;

const int RUSAGE_INFO_V2 = 2;

const int RUSAGE_INFO_V3 = 3;

const int RUSAGE_INFO_V4 = 4;

const int RUSAGE_INFO_CURRENT = 4;

const int RLIM_INFINITY = 9223372036854775807;

const int RLIM_SAVED_MAX = 9223372036854775807;

const int RLIM_SAVED_CUR = 9223372036854775807;

const int RLIMIT_CPU = 0;

const int RLIMIT_FSIZE = 1;

const int RLIMIT_DATA = 2;

const int RLIMIT_STACK = 3;

const int RLIMIT_CORE = 4;

const int RLIMIT_AS = 5;

const int RLIMIT_RSS = 5;

const int RLIMIT_MEMLOCK = 6;

const int RLIMIT_NPROC = 7;

const int RLIMIT_NOFILE = 8;

const int RLIM_NLIMITS = 9;

const int _RLIMIT_POSIX_FLAG = 4096;

const int RLIMIT_WAKEUPS_MONITOR = 1;

const int RLIMIT_CPU_USAGE_MONITOR = 2;

const int RLIMIT_THREAD_CPULIMITS = 3;

const int RLIMIT_FOOTPRINT_INTERVAL = 4;

const int WAKEMON_ENABLE = 1;

const int WAKEMON_DISABLE = 2;

const int WAKEMON_GET_PARAMS = 4;

const int WAKEMON_SET_DEFAULTS = 8;

const int WAKEMON_MAKE_FATAL = 16;

const int CPUMON_MAKE_FATAL = 4096;

const int FOOTPRINT_INTERVAL_RESET = 1;

const int IOPOL_TYPE_DISK = 0;

const int IOPOL_TYPE_VFS_ATIME_UPDATES = 2;

const int IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES = 3;

const int IOPOL_TYPE_VFS_STATFS_NO_DATA_VOLUME = 4;

const int IOPOL_SCOPE_PROCESS = 0;

const int IOPOL_SCOPE_THREAD = 1;

const int IOPOL_SCOPE_DARWIN_BG = 2;

const int IOPOL_DEFAULT = 0;

const int IOPOL_IMPORTANT = 1;

const int IOPOL_PASSIVE = 2;

const int IOPOL_THROTTLE = 3;

const int IOPOL_UTILITY = 4;

const int IOPOL_STANDARD = 5;

const int IOPOL_APPLICATION = 5;

const int IOPOL_NORMAL = 1;

const int IOPOL_ATIME_UPDATES_DEFAULT = 0;

const int IOPOL_ATIME_UPDATES_OFF = 1;

const int IOPOL_MATERIALIZE_DATALESS_FILES_DEFAULT = 0;

const int IOPOL_MATERIALIZE_DATALESS_FILES_OFF = 1;

const int IOPOL_MATERIALIZE_DATALESS_FILES_ON = 2;

const int IOPOL_VFS_STATFS_NO_DATA_VOLUME_DEFAULT = 0;

const int IOPOL_VFS_STATFS_FORCE_NO_DATA_VOLUME = 1;

const int WNOHANG = 1;

const int WUNTRACED = 2;

const int WCOREFLAG = 128;

const int _WSTOPPED = 127;

const int WEXITED = 4;

const int WSTOPPED = 8;

const int WCONTINUED = 16;

const int WNOWAIT = 32;

const int WAIT_ANY = -1;

const int WAIT_MYPGRP = 0;

const int _QUAD_HIGHWORD = 1;

const int _QUAD_LOWWORD = 0;

const int __DARWIN_LITTLE_ENDIAN = 1234;

const int __DARWIN_BIG_ENDIAN = 4321;

const int __DARWIN_PDP_ENDIAN = 3412;

const int __DARWIN_BYTE_ORDER = 1234;

const int LITTLE_ENDIAN = 1234;

const int BIG_ENDIAN = 4321;

const int PDP_ENDIAN = 3412;

const int BYTE_ORDER = 1234;

typedef _typedefC_6 = ffi.Void Function(
  ffi.Int32,
);

// typedef _c_signal = ffi.Pointer<ffi.NativeFunction<_typedefC_5>> Function(
//   ffi.Int32 arg0,
//   ffi.Pointer<ffi.NativeFunction<_typedefC_6>> arg1,
// );

// typedef _dart_signal = ffi.Pointer<ffi.NativeFunction<_typedefC_5>> Function(
//   int arg0,
//   ffi.Pointer<ffi.NativeFunction<_typedefC_6>> arg1,
// );

typedef _c_getpriority = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Uint32 arg1,
);

typedef _dart_getpriority = int Function(
  int arg0,
  int arg1,
);

typedef _c_getiopolicy_np = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Int32 arg1,
);

typedef _dart_getiopolicy_np = int Function(
  int arg0,
  int arg1,
);

typedef _c_getrlimit = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Pointer<rlimit> arg1,
);

typedef _dart_getrlimit = int Function(
  int arg0,
  ffi.Pointer<rlimit> arg1,
);

typedef _c_getrusage = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Pointer<rusage> arg1,
);

typedef _dart_getrusage = int Function(
  int arg0,
  ffi.Pointer<rusage> arg1,
);

typedef _c_setpriority = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Uint32 arg1,
  ffi.Int32 arg2,
);

typedef _dart_setpriority = int Function(
  int arg0,
  int arg1,
  int arg2,
);

typedef _c_setiopolicy_np = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Int32 arg1,
  ffi.Int32 arg2,
);

typedef _dart_setiopolicy_np = int Function(
  int arg0,
  int arg1,
  int arg2,
);

typedef _c_setrlimit = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Pointer<rlimit> arg1,
);

typedef _dart_setrlimit = int Function(
  int arg0,
  ffi.Pointer<rlimit> arg1,
);

typedef _c__OSSwapInt16 = ffi.Uint16 Function(
  ffi.Uint16 _data,
);

typedef _dart__OSSwapInt16 = int Function(
  int _data,
);

typedef _c__OSSwapInt32 = ffi.Uint32 Function(
  ffi.Uint32 _data,
);

typedef _dart__OSSwapInt32 = int Function(
  int _data,
);

typedef _c__OSSwapInt64 = ffi.Uint64 Function(
  ffi.Uint64 _data,
);

typedef _dart__OSSwapInt64 = int Function(
  int _data,
);

typedef _c_wait = ffi.Int32 Function(
  ffi.Pointer<ffi.Int32> arg0,
);

typedef _dart_wait = int Function(
  ffi.Pointer<ffi.Int32> arg0,
);

typedef _c_waitpid = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Pointer<ffi.Int32> arg1,
  ffi.Int32 arg2,
);

typedef _dart_waitpid = int Function(
  int arg0,
  ffi.Pointer<ffi.Int32> arg1,
  int arg2,
);

typedef _c_waitid = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Uint32 arg1,
  ffi.Pointer<__siginfo> arg2,
  ffi.Int32 arg3,
);

typedef _dart_waitid = int Function(
  int arg0,
  int arg1,
  ffi.Pointer<__siginfo> arg2,
  int arg3,
);

typedef _c_wait3 = ffi.Int32 Function(
  ffi.Pointer<ffi.Int32> arg0,
  ffi.Int32 arg1,
  ffi.Pointer<rusage> arg2,
);

typedef _dart_wait3 = int Function(
  ffi.Pointer<ffi.Int32> arg0,
  int arg1,
  ffi.Pointer<rusage> arg2,
);

typedef _c_wait4 = ffi.Int32 Function(
  ffi.Int32 arg0,
  ffi.Pointer<ffi.Int32> arg1,
  ffi.Int32 arg2,
  ffi.Pointer<rusage> arg3,
);

typedef _dart_wait4 = int Function(
  int arg0,
  ffi.Pointer<ffi.Int32> arg1,
  int arg2,
  ffi.Pointer<rusage> arg3,
);

typedef _typedefC_1 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_4 = ffi.Void Function(
  ffi.Int32,
);
