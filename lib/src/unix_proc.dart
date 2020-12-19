import 'dart:ffi';

import 'proc.dart';

class UnixProc implements Proc {
  UnixProc(this.pid);

  final int pid;

  @override
  void waitSync() {
    rawWait(pid);
  }

  @override
  Future<void> wait() async {
    // return executor.submitCallable(rawWait, hProcess);
  }

  @override
  void kill() {
    // unistd.kill(hProcess, SIGKILL);
  }
}

void rawWait(int pid) {
  // final status = allocate<Int32>();
  // unistd.waitpid(pid, status, 0);
  // unistd.waitpid(pid, nullptr, 0);
}
