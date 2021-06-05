
int create_ptm(
    int rows,
    int columns);
void create_subprocess(char *env,
                       char const *cmd,
                       char const *cwd,
                       char *const argv[],
                       char **envp,
                       int *pProcessId,
                       int ptmfd);
void write_to_fd(int fd, char *str);
void setNonblock(int fd);
char *get_output_from_fd(int fd);
char *getFilePathFromFd(int fd);
typedef void (*Callback)(char *p);
void setPtyWindowSize(int fd, int rows, int cols);
void init_dart_print(Callback callback);
void post_thread(int ptmfd, Callback callback);
int waitFor(int pid);